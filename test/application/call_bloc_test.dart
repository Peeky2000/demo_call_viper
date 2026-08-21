import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kaicall/application/call_bloc.dart';
import 'package:kaicall/application/call_event.dart';
import 'package:kaicall/application/call_state.dart';
import 'package:kaicall/domain/call_models.dart';
import 'package:kaicall/domain/contact.dart';
import 'package:kaicall/domain/ports.dart';

/// Ba fake dưới đây là lý do kiến trúc tách `domain` khỏi LiveKit: toàn bộ ca
/// biên chạy được trên máy tính, không cần thiết bị, không cần mạng. Với một
/// máy Android thật + một emulator không mic thì phần lớn AC chỉ kiểm được ở
/// đây (TECHSTACK.md §3).

class FakeSignaling implements SignalingPort {
  final StreamController<CallInvite> _invites = StreamController<CallInvite>.broadcast();
  final StreamController<CallInvite> _rejections = StreamController<CallInvite>.broadcast();
  final StreamController<CallInvite> _cancels = StreamController<CallInvite>.broadcast();
  final StreamController<LobbyStatus> _lobby = StreamController<LobbyStatus>.broadcast();

  final List<String> calls = <String>[];

  @override
  Stream<CallInvite> get invites => _invites.stream;
  @override
  Stream<CallInvite> get rejections => _rejections.stream;
  @override
  Stream<CallInvite> get cancellations => _cancels.stream;
  @override
  Stream<LobbyStatus> get lobby => _lobby.stream;

  @override
  Future<void> connect({required String selfId, required String displayName}) async {
    calls.add('connect');
    _lobby.add(const LobbyStatus.connected());
  }

  @override
  Future<void> disconnect() async => calls.add('disconnect');
  @override
  Future<void> invite(CallInvite i) async => calls.add('invite:${i.roomName}');
  @override
  Future<void> reject(CallInvite i) async => calls.add('reject:${i.fromId}');
  @override
  Future<void> cancel(CallInvite i) async => calls.add('cancel:${i.toId}');

  void kickDuplicate() =>
      _lobby.add(const LobbyStatus.disconnected(duplicateIdentity: true));

  void receiveInvite(CallInvite i) => _invites.add(i);
  void receiveRejection(CallInvite i) => _rejections.add(i);
}

class FakeSession implements CallSessionPort {
  final StreamController<CallSessionEvent> _events =
      StreamController<CallSessionEvent>.broadcast();
  final List<String> calls = <String>[];
  bool failJoin = false;

  @override
  Stream<CallSessionEvent> get events => _events.stream;

  @override
  Future<void> join({
    required String roomName,
    required String identity,
    required String displayName,
  }) async {
    calls.add('join:$roomName');
    if (failJoin) throw StateError('không vào được phòng');
  }

  @override
  Future<void> leave() async => calls.add('leave');
  @override
  Future<void> setMicrophone(bool on) async => calls.add('mic:$on');
  @override
  Future<void> setCamera(bool on) async => calls.add('cam:$on');
  @override
  Future<void> switchCamera() async => calls.add('switchCamera');

  void emit(CallSessionEvent e) => _events.add(e);
}

class FakePermissions implements PermissionsPort {
  FakePermissions({this.granted = true});
  bool granted;
  int openedSettings = 0;

  @override
  Future<bool> ensureCallPermissions() async => granted;
  @override
  Future<void> openSystemSettings() async => openedSettings++;
}

const Contact long = Contact(id: 'long', displayName: 'Long', note: 'Android');
const Contact minh = Contact(id: 'minh', displayName: 'Minh', note: 'Emulator');

void main() {
  late FakeSignaling signaling;
  late FakeSession session;
  late FakePermissions permissions;
  late CallBloc bloc;

  setUp(() {
    signaling = FakeSignaling();
    session = FakeSession();
    permissions = FakePermissions();
    bloc = CallBloc(
      self: long,
      signaling: signaling,
      session: session,
      permissions: permissions,
    );
  });

  tearDown(() => bloc.close());

  /// Đẩy bloc vào trạng thái "phòng chờ đã thông" — điều kiện để gọi được.
  Future<void> lobbyUp() async {
    bloc.add(const LobbyConnectionChanged(LobbyStatus.connected()));
    await bloc.stream.firstWhere((CallUiState s) => s.lobbyConnected);
  }

  CallInvite inviteFromMinh() => const CallInvite(
        fromId: 'minh',
        toId: 'long',
        roomName: 'kaicall-long-minh',
      );

  test('dogfood 2026-08-21 · bị đá vì trùng danh tính → nói RÕ, và không mời thử lại', () async {
    // Hai emulator cùng chọn "Long": LiveKit đá máy vào trước ra. Bản đầu chỉ
    // hiện "chưa vào được máy chủ" trống trơn, và nút Thử lại làm hai máy đá
    // nhau vô hạn. Giờ state phải mang cờ để UI hướng người dùng đi đổi vai.
    await lobbyUp();
    signaling.kickDuplicate();
    await bloc.stream.firstWhere((CallUiState s) => !s.lobbyConnected);
    expect(bloc.state.kickedByDuplicate, isTrue);
    expect(bloc.state.lobbyError, contains('Long'));
    expect(bloc.state.canCall, isFalse);
  });

  test('AC-1 · bấm gọi khi phòng chờ CHƯA thông thì không làm gì', () async {
    bloc.add(const CallRequested(minh));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.status, CallStatus.idle);
    expect(signaling.calls, isNot(contains('invite:kaicall-long-minh')));
  });

  test('AC-5 · từ chối quyền → sang màn giải thích, KHÔNG gọi', () async {
    await lobbyUp();
    permissions.granted = false;
    bloc.add(const CallRequested(minh));
    await bloc.stream.firstWhere((CallUiState s) => s.permissionDenied);
    expect(bloc.state.status, CallStatus.idle);
    expect(signaling.calls.where((String c) => c.startsWith('invite')), isEmpty);
  });

  test('AC-1 · bấm gọi → outgoing và gửi lời mời đúng phòng tất định', () async {
    await lobbyUp();
    bloc.add(const CallRequested(minh));
    await bloc.stream.firstWhere((CallUiState s) => s.status == CallStatus.outgoing);
    expect(bloc.state.peer, minh);
    expect(signaling.calls, contains('invite:kaicall-long-minh'));
  });

  test('AC-1 · nhận lời mời → màn cuộc gọi đến, kèm tên người gọi', () async {
    signaling.receiveInvite(inviteFromMinh());
    await bloc.stream.firstWhere((CallUiState s) => s.status == CallStatus.incoming);
    expect(bloc.state.peer?.displayName, 'Minh');
  });

  test('lời mời gửi cho NGƯỜI KHÁC thì bỏ qua', () async {
    signaling.receiveInvite(
      const CallInvite(fromId: 'minh', toId: 'ai-do-khac', roomName: 'r'),
    );
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.status, CallStatus.idle);
  });

  test('AC-2 · bấm Nghe → vào phòng đúng tên', () async {
    signaling.receiveInvite(inviteFromMinh());
    await bloc.stream.firstWhere((CallUiState s) => s.status == CallStatus.incoming);
    bloc.add(const CallAccepted());
    await bloc.stream.firstWhere((CallUiState s) => s.status == CallStatus.inCall);
    expect(session.calls, contains('join:kaicall-long-minh'));
  });

  test('AC-3 · bấm Từ chối → báo cho bên kia rồi về danh bạ, không treo', () async {
    signaling.receiveInvite(inviteFromMinh());
    await bloc.stream.firstWhere((CallUiState s) => s.status == CallStatus.incoming);
    bloc.add(const CallDeclined());
    await bloc.stream.firstWhere((CallUiState s) => s.status == CallStatus.idle);
    expect(signaling.calls, contains('reject:minh'));
    expect(bloc.state.endReason, CallEndReason.rejected);
  });

  test('AC-3 · bên kia từ chối → mình thấy "bị từ chối" và về danh bạ', () async {
    await lobbyUp();
    bloc.add(const CallRequested(minh));
    await bloc.stream.firstWhere((CallUiState s) => s.status == CallStatus.outgoing);
    signaling.receiveRejection(inviteFromMinh());
    await bloc.stream.firstWhere((CallUiState s) => s.status == CallStatus.idle);
    expect(bloc.state.endReason, CallEndReason.rejected);
  });

  test('ARCHITECTURE §7a · hết 30 giây không ai nghe → "Không trả lời", không quay mãi', () async {
    // Kiểm nhánh xử lý; bộ đếm 30 giây thật do Timer bắn ra cùng event này.
    await lobbyUp();
    bloc.add(const CallRequested(minh));
    await bloc.stream.firstWhere((CallUiState s) => s.status == CallStatus.outgoing);
    bloc.add(const RingTimedOut());
    await bloc.stream.firstWhere((CallUiState s) => s.status == CallStatus.idle);
    expect(bloc.state.endReason, CallEndReason.noAnswer);
    expect(signaling.calls, contains('cancel:minh'));
  });

  test('ARCHITECTURE §6 · hai bên bấm gọi CÙNG LÚC → vào thẳng phòng, không ai phải bấm Nghe', () async {
    await lobbyUp();
    bloc.add(const CallRequested(minh));
    await bloc.stream.firstWhere((CallUiState s) => s.status == CallStatus.outgoing);
    // Đúng lúc đó lời mời của Minh tới nơi.
    signaling.receiveInvite(inviteFromMinh());
    await bloc.stream.firstWhere((CallUiState s) => s.status == CallStatus.inCall);
    expect(session.calls, contains('join:kaicall-long-minh'));
  });

  test('AC-6 · bên kia thoát → rời phòng và về danh bạ với lý do rõ ràng', () async {
    signaling.receiveInvite(inviteFromMinh());
    await bloc.stream.firstWhere((CallUiState s) => s.status == CallStatus.incoming);
    bloc.add(const CallAccepted());
    await bloc.stream.firstWhere((CallUiState s) => s.status == CallStatus.inCall);

    session.emit(const PeerLeft());
    await bloc.stream.firstWhere((CallUiState s) => s.status == CallStatus.idle);
    expect(bloc.state.endReason, CallEndReason.peerLeft);
    expect(session.calls, contains('leave'));
  });

  test('AC-6 · mất kết nối → hiện đang kết nối lại, rồi hết thì thôi', () async {
    signaling.receiveInvite(inviteFromMinh());
    await bloc.stream.firstWhere((CallUiState s) => s.status == CallStatus.incoming);
    bloc.add(const CallAccepted());
    await bloc.stream.firstWhere((CallUiState s) => s.status == CallStatus.inCall);

    session.emit(const Reconnecting());
    await bloc.stream.firstWhere((CallUiState s) => s.reconnecting);
    session.emit(const Reconnected());
    await bloc.stream.firstWhere((CallUiState s) => !s.reconnecting);
  });

  test('AC-4 · bấm tắt mic đổi giao diện NGAY, không đợi SDK', () async {
    bloc.add(const MicToggled());
    await bloc.stream.firstWhere((CallUiState s) => !s.micOn);
    expect(session.calls, contains('mic:false'));
  });

  test('AC-4 · tắt rồi bật lại camera', () async {
    bloc.add(const CameraToggled());
    await bloc.stream.firstWhere((CallUiState s) => !s.cameraOn);
    bloc.add(const CameraToggled());
    await bloc.stream.firstWhere((CallUiState s) => s.cameraOn);
    expect(session.calls, containsAllInOrder(<String>['cam:false', 'cam:true']));
  });

  test('không vào được phòng → về danh bạ với lý do, không đứng ở màn trắng', () async {
    session.failJoin = true;
    signaling.receiveInvite(inviteFromMinh());
    await bloc.stream.firstWhere((CallUiState s) => s.status == CallStatus.incoming);
    bloc.add(const CallAccepted());
    await bloc.stream.firstWhere((CallUiState s) => s.status == CallStatus.idle);
    expect(bloc.state.endReason, CallEndReason.failed);
  });
}
