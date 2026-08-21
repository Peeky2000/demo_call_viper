import '../domain/call_models.dart';
import '../domain/contact.dart';
import '../domain/ports.dart';

sealed class CallEvent {
  const CallEvent();
}

/// Mở app / đổi danh tính → vào lại phòng chờ.
class SelfChosen extends CallEvent {
  const SelfChosen(this.self);
  final Contact self;
}

class LobbyConnectionChanged extends CallEvent {
  const LobbyConnectionChanged(this.status);
  final LobbyStatus status;
}

/// Bấm nút gọi ở danh bạ.
class CallRequested extends CallEvent {
  const CallRequested(this.peer);
  final Contact peer;
}

class InviteArrived extends CallEvent {
  const InviteArrived(this.invite);
  final CallInvite invite;
}

/// Bên kia đã bấm Nghe — đường DUY NHẤT đưa máy gọi đi ra khỏi "Đang gọi…"
/// một cách thành công. Thiếu nó thì cuộc gọi không bao giờ nối được.
class AcceptanceArrived extends CallEvent {
  const AcceptanceArrived(this.invite);
  final CallInvite invite;
}

class RejectionArrived extends CallEvent {
  const RejectionArrived(this.invite);
  final CallInvite invite;
}

class CancellationArrived extends CallEvent {
  const CancellationArrived(this.invite);
  final CallInvite invite;
}

class CallAccepted extends CallEvent {
  const CallAccepted();
}

class CallDeclined extends CallEvent {
  const CallDeclined();
}

/// Bấm Huỷ khi đang gọi đi.
class CallCancelled extends CallEvent {
  const CallCancelled();
}

class HungUp extends CallEvent {
  const HungUp();
}

class RingTimedOut extends CallEvent {
  const RingTimedOut();
}

class SessionSignal extends CallEvent {
  const SessionSignal(this.event);
  final CallSessionEvent event;
}

class MicToggled extends CallEvent {
  const MicToggled();
}

class CameraToggled extends CallEvent {
  const CameraToggled();
}

class CameraSwitched extends CallEvent {
  const CameraSwitched();
}

/// Người dùng đã xem màn giải thích quyền và quay lại danh bạ.
class PermissionNoticeDismissed extends CallEvent {
  const PermissionNoticeDismissed();
}
