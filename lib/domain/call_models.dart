import 'package:equatable/equatable.dart';

/// Máy trạng thái cuộc gọi — ARCHITECTURE.md §6.
/// Đóng: không có chuyển trạng thái nào ngoài bảng ở §7.
enum CallStatus { idle, outgoing, incoming, connecting, inCall, ended }

/// Vì sao cuộc gọi kết thúc — quyết định câu chữ hiện lên màn hình.
enum CallEndReason {
  hangUp,        // mình hoặc bên kia bấm cúp
  rejected,      // bên kia bấm Từ chối          → AC-3
  cancelled,     // mình bấm Huỷ khi đang gọi
  noAnswer,      // quá 30 giây không ai nghe    → ARCHITECTURE §7a
  peerLeft,      // bên kia thoát / rớt mạng     → AC-6
  connectionLost,// mình mất kết nối quá lâu     → AC-6
  failed,        // không vào được phòng
}

/// Lời mời gọi, gửi qua data channel của phòng chờ.
class CallInvite extends Equatable {
  const CallInvite({required this.fromId, required this.toId, required this.roomName});

  final String fromId;
  final String toId;
  final String roomName;

  @override
  List<Object?> get props => <Object?>[fromId, toId, roomName];
}

/// Tên phòng **tất định**: hai máy tự tính ra cùng một tên, không cần ai cấp.
///
/// Sắp xếp id trước khi ghép — nếu không thì A gọi B ra `kaicall-a-b` còn
/// B gọi A ra `kaicall-b-a`, hai người vào hai phòng khác nhau và ngồi nhìn
/// nhau mãi không thấy. Đây cũng là thứ làm ca "hai bên bấm gọi cùng lúc"
/// tự đúng (ARCHITECTURE.md §6).
String roomNameFor(String idA, String idB) {
  final List<String> ids = <String>[idA, idB]..sort();
  return 'kaicall-${ids[0]}-${ids[1]}';
}

/// Phòng chờ dùng chung — chỗ hai máy ngồi sẵn để nghe lời mời.
const String kLobbyRoom = 'kaicall-lobby';

/// Quá ngưỡng này mà bên kia chưa nghe → CallEndReason.noAnswer.
/// Không có timeout thì màn "Đang gọi…" quay vô hạn (ARCHITECTURE.md §7a).
const Duration kRingTimeout = Duration(seconds: 30);

/// Mất kết nối quá ngưỡng này thì kết thúc thay vì treo (AC-6).
const Duration kReconnectGiveUp = Duration(seconds: 20);
