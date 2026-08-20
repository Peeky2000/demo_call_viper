import 'call_models.dart';

/// Ranh giới quan trọng nhất của dự án (ARCHITECTURE.md §8): domain và
/// application KHÔNG biết LiveKit tồn tại. Chúng chỉ thấy bốn interface dưới.
/// Đổi SDK, hay thay ký-token-trong-app bằng gọi backend, chỉ đụng
/// lib/infrastructure/ — đó là điều kiện để phần call bóc ra dùng lại được.

/// Cấp token vào một phòng. Bản demo ký ngay trong máy; bản thật gọi backend.
abstract interface class TokenProvider {
  Future<String> tokenFor({required String roomName, required String identity, required String displayName});
}

/// Kênh báo cuộc gọi — phòng chờ. Không phải media.
abstract interface class SignalingPort {
  Future<void> connect({required String selfId, required String displayName});
  Future<void> disconnect();
  Future<void> invite(CallInvite invite);
  Future<void> reject(CallInvite invite);
  Future<void> cancel(CallInvite invite);

  Stream<CallInvite> get invites;
  Stream<CallInvite> get rejections;
  Stream<CallInvite> get cancellations;
  Stream<bool> get connected;
}

/// Phiên gọi thật — tiếng + hình.
abstract interface class CallSessionPort {
  Future<void> join({required String roomName, required String identity, required String displayName});
  Future<void> leave();
  Future<void> setMicrophone(bool on);
  Future<void> setCamera(bool on);
  Future<void> switchCamera();

  Stream<CallSessionEvent> get events;
}

/// Sự kiện từ phiên gọi, đã dịch khỏi kiểu của SDK.
sealed class CallSessionEvent {
  const CallSessionEvent();
}

class PeerJoined extends CallSessionEvent {
  const PeerJoined();
}

class PeerLeft extends CallSessionEvent {
  const PeerLeft();
}

class PeerVideoChanged extends CallSessionEvent {
  const PeerVideoChanged({required this.hasVideo});
  final bool hasVideo;
}

class Reconnecting extends CallSessionEvent {
  const Reconnecting();
}

class Reconnected extends CallSessionEvent {
  const Reconnected();
}

class SessionEnded extends CallSessionEvent {
  const SessionEnded(this.reason);
  final CallEndReason reason;
}

/// Quyền mic + camera.
abstract interface class PermissionsPort {
  /// true = đủ quyền để gọi.
  Future<bool> ensureCallPermissions();

  /// Bị từ chối vĩnh viễn → phải tự mở Cài đặt hệ thống (AC-5).
  Future<void> openSystemSettings();
}
