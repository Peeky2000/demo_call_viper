import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/call_models.dart';
import '../domain/contact.dart';
import '../domain/ports.dart';
import 'call_event.dart';
import 'call_state.dart';

/// Máy trạng thái cuộc gọi — ARCHITECTURE.md §6–§7.
///
/// Đây là chỗ MỌI quyết định chuyển trạng thái xảy ra. UI chỉ bắn event và vẽ
/// theo state; infrastructure chỉ dịch sự kiện SDK. Nhờ vậy toàn bộ ca biên
/// (rớt mạng, từ chối quyền, hai bên gọi cùng lúc, đối phương thoát) test được
/// bằng `flutter test` mà không cần thiết bị — điều kiện sống còn khi chỉ có
/// một máy Android thật và một emulator không mic (TECHSTACK.md §3).
class CallBloc extends Bloc<CallEvent, CallUiState> {
  CallBloc({
    required Contact self,
    required SignalingPort signaling,
    required CallSessionPort session,
    required PermissionsPort permissions,
  })  : _signaling = signaling,
        _session = session,
        _permissions = permissions,
        super(CallUiState(self: self)) {
    on<SelfChosen>(_onSelfChosen);
    on<LobbyConnectionChanged>(_onLobbyChanged);
    on<CallRequested>(_onCallRequested);
    on<InviteArrived>(_onInviteArrived);
    on<RejectionArrived>(_onRejectionArrived);
    on<CancellationArrived>(_onCancellationArrived);
    on<CallAccepted>(_onAccepted);
    on<CallDeclined>(_onDeclined);
    on<CallCancelled>(_onCancelled);
    on<HungUp>(_onHungUp);
    on<RingTimedOut>(_onRingTimedOut);
    on<SessionSignal>(_onSessionSignal);
    on<MicToggled>(_onMicToggled);
    on<CameraToggled>(_onCameraToggled);
    on<CameraSwitched>(_onCameraSwitched);
    on<PermissionNoticeDismissed>(
      (_, Emitter<CallUiState> emit) => emit(state.copyWith(permissionDenied: false)),
    );

    _subs.addAll(<StreamSubscription<dynamic>>[
      _signaling.invites.listen((CallInvite i) => add(InviteArrived(i))),
      _signaling.rejections.listen((CallInvite i) => add(RejectionArrived(i))),
      _signaling.cancellations.listen((CallInvite i) => add(CancellationArrived(i))),
      _signaling.lobby.listen((LobbyStatus st) => add(LobbyConnectionChanged(st))),
      _session.events.listen((CallSessionEvent e) => add(SessionSignal(e))),
    ]);
  }

  final SignalingPort _signaling;
  final CallSessionPort _session;
  final PermissionsPort _permissions;
  final List<StreamSubscription<dynamic>> _subs = <StreamSubscription<dynamic>>[];
  Timer? _ringTimer;

  Contact _contactById(String id) => kDemoContacts.firstWhere(
        (Contact c) => c.id == id,
        orElse: () => Contact(id: id, displayName: id, note: ''),
      );

  Future<void> _onSelfChosen(SelfChosen e, Emitter<CallUiState> emit) async {
    emit(CallUiState(self: e.self));
    try {
      await _signaling.connect(selfId: e.self.id, displayName: e.self.displayName);
    } catch (err, stack) {
      // In ra console để đọc bằng `flutter run` / `adb logcat`, VÀ đưa lên màn
      // hình. Chỉ log thôi thì người cầm máy không thấy; chỉ hiện thôi thì mất
      // stack trace. Cần cả hai.
      debugPrint('KaiCall — vào phòng chờ thất bại: $err\n$stack');
      emit(state.copyWith(lobbyConnected: false, lobbyError: err.toString()));
    }
  }

  void _onLobbyChanged(LobbyConnectionChanged e, Emitter<CallUiState> emit) {
    emit(state.copyWith(
      lobbyConnected: e.status.connected,
      clearLobbyError: e.status.connected,
      kickedByDuplicate: e.status.duplicateIdentity,
      lobbyError: e.status.duplicateIdentity
          ? 'Máy khác vừa vào bằng danh tính "${state.self.displayName}".'
          : null,
    ));
  }

  Future<void> _onCallRequested(CallRequested e, Emitter<CallUiState> emit) async {
    if (!state.canCall) return; // chống bấm hai lần (ARCHITECTURE.md §6)

    if (!await _permissions.ensureCallPermissions()) {
      emit(state.copyWith(permissionDenied: true)); // → S5, AC-5
      return;
    }

    final CallInvite invite = CallInvite(
      fromId: state.self.id,
      toId: e.peer.id,
      roomName: roomNameFor(state.self.id, e.peer.id),
    );
    emit(state.copyWith(
      status: CallStatus.outgoing,
      peer: e.peer,
      invite: invite,
      clearEndReason: true,
    ));
    await _signaling.invite(invite);
    _startRingTimer();
  }

  Future<void> _onInviteArrived(InviteArrived e, Emitter<CallUiState> emit) async {
    if (e.invite.toId != state.self.id) return; // lời mời của người khác

    // Hai bên bấm gọi nhau CÙNG LÚC: mình đang gọi đúng người vừa mời mình →
    // coi như đã đồng ý, cả hai đi thẳng vào phòng, không ai phải bấm Nghe.
    // Tên phòng tất định nên hai bên chắc chắn gặp nhau (ARCHITECTURE.md §6).
    if (state.status == CallStatus.outgoing && state.peer?.id == e.invite.fromId) {
      _cancelRingTimer();
      await _enterCall(e.invite, _contactById(e.invite.fromId), emit);
      return;
    }
    if (state.status != CallStatus.idle) return; // đang bận thì bỏ qua

    emit(state.copyWith(
      status: CallStatus.incoming,
      peer: _contactById(e.invite.fromId),
      invite: e.invite,
      clearEndReason: true,
    ));
  }

  void _onRejectionArrived(RejectionArrived e, Emitter<CallUiState> emit) {
    if (state.status != CallStatus.outgoing) return;
    _cancelRingTimer();
    _end(emit, CallEndReason.rejected); // → AC-3
  }

  void _onCancellationArrived(CancellationArrived e, Emitter<CallUiState> emit) {
    if (state.status != CallStatus.incoming) return;
    _end(emit, CallEndReason.cancelled);
  }

  Future<void> _onAccepted(CallAccepted e, Emitter<CallUiState> emit) async {
    final CallInvite? invite = state.invite;
    final Contact? peer = state.peer;
    if (state.status != CallStatus.incoming || invite == null || peer == null) return;

    if (!await _permissions.ensureCallPermissions()) {
      emit(state.copyWith(permissionDenied: true));
      _end(emit, CallEndReason.failed);
      return;
    }
    await _enterCall(invite, peer, emit);
  }

  Future<void> _enterCall(CallInvite invite, Contact peer, Emitter<CallUiState> emit) async {
    emit(state.copyWith(
      status: CallStatus.connecting,
      peer: peer,
      invite: invite,
      micOn: true,
      cameraOn: true,
      peerJoined: false,
      peerHasVideo: false,
    ));
    try {
      await _session.join(
        roomName: invite.roomName,
        identity: state.self.id,
        displayName: state.self.displayName,
      );
      emit(state.copyWith(status: CallStatus.inCall));
    } catch (_) {
      _end(emit, CallEndReason.failed);
    }
  }

  Future<void> _onDeclined(CallDeclined e, Emitter<CallUiState> emit) async {
    final CallInvite? invite = state.invite;
    if (invite != null) await _signaling.reject(invite);
    _end(emit, CallEndReason.rejected);
  }

  Future<void> _onCancelled(CallCancelled e, Emitter<CallUiState> emit) async {
    _cancelRingTimer();
    final CallInvite? invite = state.invite;
    if (invite != null) await _signaling.cancel(invite);
    _end(emit, CallEndReason.cancelled);
  }

  Future<void> _onHungUp(HungUp e, Emitter<CallUiState> emit) async {
    await _session.leave();
    _end(emit, CallEndReason.hangUp);
  }

  void _onRingTimedOut(RingTimedOut e, Emitter<CallUiState> emit) {
    if (state.status != CallStatus.outgoing) return;
    final CallInvite? invite = state.invite;
    if (invite != null) unawaited(_signaling.cancel(invite));
    _end(emit, CallEndReason.noAnswer); // ARCHITECTURE.md §7a
  }

  Future<void> _onSessionSignal(SessionSignal e, Emitter<CallUiState> emit) async {
    switch (e.event) {
      case PeerJoined():
        emit(state.copyWith(peerJoined: true, status: CallStatus.inCall, reconnecting: false));
      case PeerLeft():
        await _session.leave();
        _end(emit, CallEndReason.peerLeft); // → AC-6
      case PeerVideoChanged(:final bool hasVideo):
        emit(state.copyWith(peerHasVideo: hasVideo));
      case Reconnecting():
        emit(state.copyWith(reconnecting: true));
      case Reconnected():
        emit(state.copyWith(reconnecting: false));
      case SessionEnded(:final CallEndReason reason):
        if (state.status == CallStatus.idle || state.status == CallStatus.ended) return;
        await _session.leave();
        _end(emit, reason);
    }
  }

  Future<void> _onMicToggled(MicToggled e, Emitter<CallUiState> emit) async {
    final bool next = !state.micOn;
    emit(state.copyWith(micOn: next)); // đổi UI NGAY, không đợi SDK — AC-4
    await _session.setMicrophone(next);
  }

  Future<void> _onCameraToggled(CameraToggled e, Emitter<CallUiState> emit) async {
    final bool next = !state.cameraOn;
    emit(state.copyWith(cameraOn: next));
    await _session.setCamera(next);
  }

  Future<void> _onCameraSwitched(CameraSwitched e, Emitter<CallUiState> emit) =>
      _session.switchCamera();

  void _startRingTimer() {
    _cancelRingTimer();
    _ringTimer = Timer(kRingTimeout, () => add(const RingTimedOut()));
  }

  void _cancelRingTimer() {
    _ringTimer?.cancel();
    _ringTimer = null;
  }

  /// Mọi nhánh kết thúc đều đi qua đây, rồi về idle — không nhánh nào được
  /// dừng ở màn không có đường ra (PROTOTYPE.md §2).
  void _end(Emitter<CallUiState> emit, CallEndReason reason) {
    _cancelRingTimer();
    emit(state.copyWith(
      status: CallStatus.ended,
      endReason: reason,
      reconnecting: false,
      peerJoined: false,
      peerHasVideo: false,
      clearInvite: true,
    ));
    emit(state.copyWith(status: CallStatus.idle, clearPeer: true));
  }

  @override
  Future<void> close() async {
    _cancelRingTimer();
    for (final StreamSubscription<dynamic> s in _subs) {
      await s.cancel();
    }
    await _session.leave();
    await _signaling.disconnect();
    return super.close();
  }
}
