import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

import '../config/kaicall_config.dart';
import '../domain/call_models.dart';
import '../domain/ports.dart';

/// Phiên gọi thật — tiếng + hình. Tách hẳn khỏi phòng chờ: đây là `Room` thứ
/// hai, chạy song song (challenge pha I đã xác nhận SDK cho phép).
///
/// Lớp này CHỈ dịch sự kiện của SDK sang kiểu của domain. Không quyết định gì
/// về luồng — chuyển trạng thái là việc của CallBloc (ARCHITECTURE.md §8).
class LiveKitCallSession implements CallSessionPort {
  LiveKitCallSession({required this.config, required this.tokens});

  final KaiCallConfig config;
  final TokenProvider tokens;

  lk.Room? _room;
  lk.EventsListener<lk.RoomEvent>? _listener;
  final StreamController<CallSessionEvent> _events =
      StreamController<CallSessionEvent>.broadcast();

  @override
  Stream<CallSessionEvent> get events => _events.stream;

  /// Phòng đang gọi — UI cần nó để vẽ video. Đây là chỗ duy nhất kiểu của SDK
  /// lọt ra ngoài infrastructure, và là đánh đổi có chủ ý: bọc lại
  /// `VideoTrack` cho thuần domain thì phải bọc luôn cả renderer của SDK,
  /// tốn hơn nhiều so với thứ nó mua được.
  lk.Room? get room => _room;

  @override
  Future<void> join({
    required String roomName,
    required String identity,
    required String displayName,
  }) async {
    await leave();

    final lk.Room room = lk.Room();
    _room = room;
    _listener = room.createListener()
      ..on<lk.ParticipantConnectedEvent>((_) => _events.add(const PeerJoined()))
      ..on<lk.ParticipantDisconnectedEvent>((_) => _events.add(const PeerLeft()))
      ..on<lk.TrackSubscribedEvent>((lk.TrackSubscribedEvent e) {
        if (e.track is lk.VideoTrack) {
          _events.add(const PeerVideoChanged(hasVideo: true));
        }
      })
      ..on<lk.TrackUnsubscribedEvent>((lk.TrackUnsubscribedEvent e) {
        if (e.track is lk.VideoTrack) {
          _events.add(const PeerVideoChanged(hasVideo: false));
        }
      })
      ..on<lk.RoomReconnectingEvent>((_) => _events.add(const Reconnecting()))
      ..on<lk.RoomReconnectedEvent>((_) => _events.add(const Reconnected()))
      ..on<lk.RoomDisconnectedEvent>((lk.RoomDisconnectedEvent e) {
        // duplicateIdentity = bản cũ của CHÍNH MÌNH bị đá ra vì mình vừa vào
        // lại phòng (challenge pha V mục c). Không phải lỗi, cũng không phải
        // bên kia thoát — báo hangUp cho gọn.
        _events.add(SessionEnded(
          e.reason == lk.DisconnectReason.duplicateIdentity
              ? CallEndReason.hangUp
              : CallEndReason.connectionLost,
        ));
      });

    final String token = await tokens.tokenFor(
      roomName: roomName,
      identity: identity,
      displayName: displayName,
    );

    try {
      await room.connect(config.serverUrl.trim(), token);
    } catch (e) {
      _events.add(const SessionEnded(CallEndReason.failed));
      rethrow;
    }

    // Bật mic + cam SAU khi đã vào phòng, và từng cái một, KHÔNG để lỗi ở đây
    // đánh sập cuộc gọi. Một cuộc gọi không có hình vẫn là một cuộc gọi.
    //
    // Vì sao quan trọng: camera giả của emulator có thể ném lỗi. Bản đầu gộp
    // chung với connect trong một try nên lỗi bật cam bị hiểu là "không vào
    // được phòng" — máy đó rời phòng, máy kia thấy đối phương thoát rồi cũng
    // về danh bạ. MỘT lỗi camera ở một đầu kéo sập cả hai. Tìm ra khi chạy
    // thật trên emulator + máy Honor 2026-08-21.
    try {
      await room.localParticipant?.setMicrophoneEnabled(true);
    } catch (e) {
      debugPrint('KaiCall — không bật được mic, vẫn ở trong cuộc gọi: $e');
    }
    try {
      await room.localParticipant?.setCameraEnabled(true);
    } catch (e) {
      debugPrint('KaiCall — không bật được camera, vẫn ở trong cuộc gọi: $e');
    }

    try {
      // Bên kia đã ở trong phòng trước mình thì không có ParticipantConnected
      // nào bắn ra — phải tự kiểm một lần, nếu không màn hình đứng ở "đang
      // chờ người kia vào" dù họ đã ở đó.
      if (room.remoteParticipants.isNotEmpty) {
        _events.add(const PeerJoined());
      }
    } catch (e) {
      debugPrint('KaiCall — kiểm người trong phòng lỗi: $e');
    }
  }

  @override
  Future<void> setMicrophone(bool on) async =>
      _room?.localParticipant?.setMicrophoneEnabled(on);

  @override
  Future<void> setCamera(bool on) async =>
      _room?.localParticipant?.setCameraEnabled(on);

  @override
  Future<void> switchCamera() async {
    final lk.LocalVideoTrack? track = _room?.localParticipant?.videoTrackPublications
        .map((lk.LocalTrackPublication<lk.LocalVideoTrack> p) => p.track)
        .whereType<lk.LocalVideoTrack>()
        .firstOrNull;
    if (track == null) return;
    final lk.CameraPosition current =
        (track.currentOptions as lk.CameraCaptureOptions?)?.cameraPosition ??
            lk.CameraPosition.front;
    await track.setCameraPosition(
      current == lk.CameraPosition.front ? lk.CameraPosition.back : lk.CameraPosition.front,
    );
  }

  @override
  Future<void> leave() async {
    await _listener?.dispose();
    _listener = null;
    // disconnect() TƯỜNG MINH — để bên kia thoát treo ngay, không phải ngồi
    // đợi LiveKit tự phát hiện mất kết nối (AC-7, ARCHITECTURE.md §7d).
    await _room?.disconnect();
    await _room?.dispose();
    _room = null;
  }
}
