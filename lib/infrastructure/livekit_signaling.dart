import 'dart:async';
import 'dart:convert';

import 'package:livekit_client/livekit_client.dart' as lk;

import '../config/kaicall_config.dart';
import '../domain/call_models.dart';
import '../domain/ports.dart';

/// Kênh báo cuộc gọi, dựng trên chính LiveKit — không có backend, không FCM
/// (DECISIONS.md 2026-08-20).
///
/// Cách hoạt động: cả hai máy vào sẵn phòng chờ `kaicall-lobby` khi mở app,
/// KHÔNG bật mic/cam ở đó (phòng chờ chỉ để nhắn tin). Bấm gọi = gửi một gói
/// JSON qua data channel. Máy kia nhận được thì hiện màn cuộc gọi đến.
///
/// Giới hạn đã biết và đã chấp nhận: cả hai app phải đang mở. App đóng thì
/// lời mời rơi vào hư không — vì vậy bên gọi có timeout 30 giây
/// (ARCHITECTURE.md §7a). Muốn đổ chuông khi app đóng thì cần FCM, đã cắt
/// khỏi vòng 1 ở PRD.md §5.
class LiveKitSignaling implements SignalingPort {
  LiveKitSignaling({required this.config, required this.tokens});

  final KaiCallConfig config;
  final TokenProvider tokens;

  lk.Room? _room;
  lk.EventsListener<lk.RoomEvent>? _listener;

  final StreamController<CallInvite> _invites = StreamController<CallInvite>.broadcast();
  final StreamController<CallInvite> _rejections = StreamController<CallInvite>.broadcast();
  final StreamController<CallInvite> _cancellations = StreamController<CallInvite>.broadcast();
  final StreamController<LobbyStatus> _lobby = StreamController<LobbyStatus>.broadcast();

  @override
  Stream<CallInvite> get invites => _invites.stream;
  @override
  Stream<CallInvite> get rejections => _rejections.stream;
  @override
  Stream<CallInvite> get cancellations => _cancellations.stream;
  @override
  Stream<LobbyStatus> get lobby => _lobby.stream;

  @override
  Future<void> connect({required String selfId, required String displayName}) async {
    await disconnect();

    final lk.Room room = lk.Room();
    _room = room;
    _listener = room.createListener()
      ..on<lk.DataReceivedEvent>(_onData)
      ..on<lk.RoomDisconnectedEvent>((lk.RoomDisconnectedEvent e) {
        // GIỮ LẤY reason. Vứt nó đi là người dùng nhận một câu "mất kết nối"
        // không nói được phải làm gì — đúng lỗi dogfood bắt được 2026-08-21.
        _lobby.add(LobbyStatus.disconnected(
          duplicateIdentity: e.reason == lk.DisconnectReason.duplicateIdentity,
        ));
      })
      ..on<lk.RoomReconnectedEvent>((_) => _lobby.add(const LobbyStatus.connected()));

    final String token = await tokens.tokenFor(
      roomName: kLobbyRoom,
      identity: selfId,
      displayName: displayName,
    );
    try {
      await room.connect(config.serverUrl.trim(), token);
    } catch (e) {
      // Ném tiếp kèm địa chỉ đang thử — nuốt lỗi ở đây là để người dùng nhìn
      // banner "chưa kết nối được" mà không bao giờ biết vì sao.
      throw Exception('Không vào được phòng chờ ${config.serverUrl.trim()} — $e');
    }
    _lobby.add(const LobbyStatus.connected());
  }

  void _onData(lk.DataReceivedEvent event) {
    final Map<String, dynamic> msg;
    try {
      msg = json.decode(utf8.decode(event.data)) as Map<String, dynamic>;
    } catch (_) {
      return; // Gói lạ thì bỏ qua — không làm chết phòng chờ.
    }
    final CallInvite invite = CallInvite(
      fromId: msg['from'] as String? ?? '',
      toId: msg['to'] as String? ?? '',
      roomName: msg['room'] as String? ?? '',
    );
    if (invite.fromId.isEmpty || invite.toId.isEmpty) return;

    switch (msg['type']) {
      case 'invite':
        _invites.add(invite);
      case 'reject':
        _rejections.add(invite);
      case 'cancel':
        _cancellations.add(invite);
    }
  }

  Future<void> _send(String type, CallInvite invite) async {
    final lk.LocalParticipant? me = _room?.localParticipant;
    if (me == null) return;
    await me.publishData(
      utf8.encode(json.encode(<String, dynamic>{
        'type': type,
        'from': invite.fromId,
        'to': invite.toId,
        'room': invite.roomName,
      })),
      // reliable: lời mời gọi mất gói là mất cả cuộc gọi, không được dùng lossy.
      reliable: true,
    );
  }

  @override
  Future<void> invite(CallInvite invite) => _send('invite', invite);
  @override
  Future<void> reject(CallInvite invite) => _send('reject', invite);
  @override
  Future<void> cancel(CallInvite invite) => _send('cancel', invite);

  @override
  Future<void> disconnect() async {
    await _listener?.dispose();
    _listener = null;
    await _room?.disconnect();
    await _room?.dispose();
    _room = null;
  }
}
