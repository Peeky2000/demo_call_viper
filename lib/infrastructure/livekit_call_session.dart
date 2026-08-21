import 'dart:async';

import 'package:flutter/widgets.dart';
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

  /// Hàng rào thời gian cho "đối phương biến mất".
  ///
  /// Không phó mặc `ParticipantDisconnectedEvent` nữa: đo ngày 2026-08-21,
  /// giết app ở đầu B thì đầu A đứng **hơn hai phút** vẫn không hay biết, chỉ
  /// đổi sang dòng "đã tắt camera" (CHECKLIST ca 14). Cùng lúc đó, ca 13 (B
  /// mất mạng) thì A lại thoát sau ~20 giây — cùng một cảnh mất người mà hai
  /// kết cục khác hẳn, tức sự kiện của SDK không đáng tin một mình.
  ///
  /// 15 giây là con số Authority chốt: đủ chịu một nhịp mạng chập chờn mà
  /// không bắt người ta ngồi nhìn khung hình chết.
  static const Duration _peerGoneAfter = Duration(seconds: 15);
  static const Duration _probeEvery = Duration(seconds: 2);

  Timer? _probe;
  bool _peerEverSeen = false;
  bool _peerLeftSent = false;
  bool _endedSent = false;
  bool _selfDegraded = false;
  DateTime? _peerMissingSince;
  DateTime? _selfBadSince;

  void _log(String message) => debugPrint('KaiCall/lk — $message');

  @override
  Stream<CallSessionEvent> get events => _events.stream;

  /// Phòng đang gọi — UI cần nó để vẽ video. Đây là chỗ duy nhất kiểu của SDK
  /// lọt ra ngoài infrastructure, và là đánh đổi có chủ ý: bọc lại
  /// `VideoTrack` cho thuần domain thì phải bọc luôn cả renderer của SDK,
  /// tốn hơn nhiều so với thứ nó mua được.
  lk.Room? get room => _room;

  /// Chỉ bắn PeerLeft MỘT lần cho mỗi cuộc gọi. Cả sự kiện của SDK lẫn hàng
  /// rào thời gian đều dẫn về đây, mà bloc thì `leave()` rồi kết thúc — bắn
  /// lần hai chỉ tổ đá vào một cuộc gọi khác vừa bắt đầu.
  void _emitPeerLeftOnce(String why) {
    if (_peerLeftSent) return;
    _peerLeftSent = true;
    _log('đối phương rời phòng ($why)');
    _events.add(const PeerLeft());
  }

  @override
  Future<void> join({
    required String roomName,
    required String identity,
    required String displayName,
  }) async {
    await leave();

    _peerEverSeen = false;
    _peerLeftSent = false;
    _endedSent = false;
    _selfDegraded = false;
    _peerMissingSince = null;
    _selfBadSince = null;

    final lk.Room room = lk.Room();
    _room = room;
    _listener = room.createListener()
      ..on<lk.ParticipantConnectedEvent>((lk.ParticipantConnectedEvent e) {
        _log('ParticipantConnected ${e.participant.identity}');
        _peerEverSeen = true;
        _peerMissingSince = null;
        _events.add(const PeerJoined());
      })
      ..on<lk.ParticipantDisconnectedEvent>((lk.ParticipantDisconnectedEvent e) {
        _log('ParticipantDisconnected ${e.participant.identity}');
        _emitPeerLeftOnce('SDK báo');
      })
      ..on<lk.TrackSubscribedEvent>((lk.TrackSubscribedEvent e) {
        if (e.track is lk.VideoTrack) {
          // Vào phòng mà camera bên kia đang tắt sẵn thì publication đã muted
          // — đọc luôn, đừng mặc định là có hình rồi vẽ khung đen.
          _log('TrackSubscribed video, muted=${e.publication.muted}');
          _events.add(PeerVideoChanged(hasVideo: !e.publication.muted));
        }
      })
      ..on<lk.TrackUnsubscribedEvent>((lk.TrackUnsubscribedEvent e) {
        if (e.track is lk.VideoTrack) {
          _log('TrackUnsubscribed video');
          _events.add(const PeerVideoChanged(hasVideo: false));
        }
      })
      // Tắt/bật camera KHÔNG gỡ đăng ký track — nó chỉ mute. Thiếu hai tay
      // nghe này thì bên kia tắt cam là mình vẫn tưởng còn hình, và vẽ ra một
      // khung đen trơn đúng thứ DESIGN-SYSTEM.md §5 cấm (CHECKLIST ca 5).
      ..on<lk.TrackMutedEvent>((lk.TrackMutedEvent e) {
        if (e.participant is lk.RemoteParticipant &&
            e.publication.source == lk.TrackSource.camera) {
          _log('TrackMuted camera ${e.participant.identity}');
          _events.add(const PeerVideoChanged(hasVideo: false));
        }
      })
      ..on<lk.TrackUnmutedEvent>((lk.TrackUnmutedEvent e) {
        if (e.participant is lk.RemoteParticipant &&
            e.publication.source == lk.TrackSource.camera) {
          _log('TrackUnmuted camera ${e.participant.identity}');
          _events.add(const PeerVideoChanged(hasVideo: true));
        }
      })
      ..on<lk.RoomReconnectingEvent>((_) {
        _log('RoomReconnecting');
        _events.add(const Reconnecting());
      })
      ..on<lk.RoomReconnectedEvent>((_) {
        _log('RoomReconnected');
        _events.add(const Reconnected());
      })
      ..on<lk.RoomDisconnectedEvent>((lk.RoomDisconnectedEvent e) {
        _log('RoomDisconnected reason=${e.reason}');
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
        _peerEverSeen = true;
        _events.add(const PeerJoined());
      }
    } catch (e) {
      debugPrint('KaiCall — kiểm người trong phòng lỗi: $e');
    }

    _probe = Timer.periodic(_probeEvery, (_) => _probeTick());
  }

  /// Nhịp canh: một nhịp lo cho CHÍNH MÌNH, một nhịp lo cho đối phương.
  /// Chạy đều đặn thay vì ngồi đợi SDK gọi mình.
  void _probeTick() {
    final lk.Room? room = _room;
    if (room == null || _peerLeftSent || _endedSent) return;
    final DateTime now = DateTime.now();

    // ── Ở nền thì KHÔNG kết luận gì ─────────────────────────────────────
    // Android treo websocket của app chạy nền: `connectionState` tụt xuống
    // disconnected chỉ 6 giây sau khi bấm Home, trong khi media vẫn thông —
    // quay lại là thấy hình bên kia chạy bình thường (đo 2026-08-21). Đếm
    // trong lúc đó là tự giết đúng thứ AC-7 đòi giữ, và ca 15 vừa nghiệm thu
    // xong sẽ đỏ ngay. Cũng không xét đối phương: tin tức không tới được thì
    // im lặng không có nghĩa là họ đã đi.
    final AppLifecycleState? life = WidgetsBinding.instance.lifecycleState;
    if (life != null && life != AppLifecycleState.resumed) {
      _selfBadSince = null;
      _peerMissingSince = null;
      return;
    }

    // ── Chính mình ──────────────────────────────────────────────────────
    // Máy mình mất mạng thì đối phương vẫn nằm nguyên trong danh sách — không
    // có tin gì về để mà xoá — nên hàng rào canh-người-kia KHÔNG BAO GIỜ nổ.
    // Đo ngày 2026-08-21: bật chế độ máy bay giữa cuộc gọi, máy đó đứng nhìn
    // khung hình chết 45 giây, không một chữ, `RoomReconnectingEvent` cũng
    // không hề bắn (CHECKLIST ca 13). Vậy thì tự dò.
    final lk.ConnectionState conn = room.connectionState;
    if (conn != lk.ConnectionState.connected) {
      _selfBadSince ??= now;
      if (!_selfDegraded) {
        _selfDegraded = true;
        _log('kết nối của mình: ${conn.name} → báo đang kết nối lại');
        _events.add(const Reconnecting());
      }
      final Duration bad = now.difference(_selfBadSince!);
      _log('mạng của mình hỏng ${bad.inSeconds}s (${conn.name})');
      if (bad >= _peerGoneAfter) {
        _endedSent = true;
        _log('mất kết nối quá ${_peerGoneAfter.inSeconds}s → kết thúc cuộc gọi');
        _events.add(const SessionEnded(CallEndReason.connectionLost));
      }
      // Mạng mình còn hỏng thì đừng kết luận gì về người kia: không nhận được
      // tin không có nghĩa là họ đi mất.
      return;
    }
    if (_selfDegraded) {
      _selfDegraded = false;
      _selfBadSince = null;
      _log('kết nối của mình đã trở lại');
      _events.add(const Reconnected());
    }

    // ── Đối phương ──────────────────────────────────────────────────────
    final Iterable<lk.RemoteParticipant> peers = room.remoteParticipants.values;
    // "Còn đó" = có mặt trong phòng VÀ chất lượng kết nối chưa rơi xuống lost.
    // Người tắt cả mic lẫn cam vẫn là good/excellent nên không bị bắt nhầm.
    final bool present = peers
        .any((lk.RemoteParticipant p) => p.connectionQuality != lk.ConnectionQuality.lost);

    if (present) {
      _peerEverSeen = true;
      _peerMissingSince = null;
      return;
    }

    // Chưa ai từng vào thì chưa tính — lúc A vừa vào phòng chờ B bấm Nghe,
    // phòng rỗng là chuyện bình thường, đếm ở đây là tự cắt cuộc gọi của mình.
    if (!_peerEverSeen) return;

    _peerMissingSince ??= now;
    final Duration gone = now.difference(_peerMissingSince!);
    _log('không thấy đối phương ${gone.inSeconds}s '
        '(trong phòng: ${peers.length}, '
        '${peers.map((lk.RemoteParticipant p) => "${p.identity}=${p.connectionQuality.name}").join(", ")})');

    if (gone >= _peerGoneAfter) {
      _emitPeerLeftOnce('hàng rào ${_peerGoneAfter.inSeconds}s');
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
    _probe?.cancel();
    _probe = null;
    await _listener?.dispose();
    _listener = null;
    // disconnect() TƯỜNG MINH — để bên kia thoát treo ngay, không phải ngồi
    // đợi LiveKit tự phát hiện mất kết nối (AC-7, ARCHITECTURE.md §7d).
    await _room?.disconnect();
    await _room?.dispose();
    _room = null;
  }
}
