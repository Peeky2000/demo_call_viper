import 'package:equatable/equatable.dart';

import '../domain/call_models.dart';
import '../domain/contact.dart';

class CallUiState extends Equatable {
  const CallUiState({
    required this.self,
    this.status = CallStatus.idle,
    this.peer,
    this.invite,
    this.identityChosen = false,
    this.lobbyConnected = false,
    this.lobbyError,
    this.kickedByDuplicate = false,
    this.micOn = true,
    this.cameraOn = true,
    this.peerJoined = false,
    this.peerHasVideo = false,
    this.reconnecting = false,
    this.endReason,
    this.permissionDenied = false,
  });

  final Contact self;
  final CallStatus status;
  final Contact? peer;
  final CallInvite? invite;
  /// Người dùng đã BẤM chọn máy này là ai chưa. Mặc định false: app KHÔNG tự
  /// chọn hộ. Trước bản vá 2026-08-21 nó tự chọn người đầu danh bạ rồi vào
  /// phòng chờ ngay — nên hai máy mở lên là cùng vai, LiveKit đá một cái ra,
  /// tái lập 100%. Dogfood bắt được.
  final bool identityChosen;

  final bool lobbyConnected;

  /// Vì sao không vào được phòng chờ. Hiện thẳng lên banner — người thử phải
  /// đọc được lý do, không phải đoán.
  final String? lobbyError;

  /// Bị đá khỏi phòng chờ vì máy khác dùng đúng danh tính này. Cách xử khác
  /// hẳn lỗi mạng: phải ĐỔI VAI, bấm "Thử lại" chỉ đá ngược máy kia ra và hai
  /// máy đá nhau vô hạn.
  final bool kickedByDuplicate;
  final bool micOn;
  final bool cameraOn;
  final bool peerJoined;
  final bool peerHasVideo;
  final bool reconnecting;
  final CallEndReason? endReason;
  final bool permissionDenied;

  /// Chỉ gọi được khi phòng chờ đang thông — nút Gọi mờ đi ở trạng thái khác.
  /// Bấm vào hư không rồi ngồi đợi là đúng cái nỗi đau ở PRD.md §1.
  bool get canCall => identityChosen && lobbyConnected && status == CallStatus.idle;

  CallUiState copyWith({
    Contact? self,
    CallStatus? status,
    Contact? peer,
    CallInvite? invite,
    bool? identityChosen,
    bool? lobbyConnected,
    String? lobbyError,
    bool? kickedByDuplicate,
    bool? micOn,
    bool? cameraOn,
    bool? peerJoined,
    bool? peerHasVideo,
    bool? reconnecting,
    CallEndReason? endReason,
    bool? permissionDenied,
    bool clearPeer = false,
    bool clearLobbyError = false,
    bool clearInvite = false,
    bool clearEndReason = false,
  }) {
    return CallUiState(
      self: self ?? this.self,
      status: status ?? this.status,
      peer: clearPeer ? null : (peer ?? this.peer),
      invite: clearInvite ? null : (invite ?? this.invite),
      identityChosen: identityChosen ?? this.identityChosen,
      lobbyConnected: lobbyConnected ?? this.lobbyConnected,
      lobbyError: clearLobbyError ? null : (lobbyError ?? this.lobbyError),
      kickedByDuplicate: kickedByDuplicate ?? this.kickedByDuplicate,
      micOn: micOn ?? this.micOn,
      cameraOn: cameraOn ?? this.cameraOn,
      peerJoined: peerJoined ?? this.peerJoined,
      peerHasVideo: peerHasVideo ?? this.peerHasVideo,
      reconnecting: reconnecting ?? this.reconnecting,
      endReason: clearEndReason ? null : (endReason ?? this.endReason),
      permissionDenied: permissionDenied ?? this.permissionDenied,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        self, status, peer, invite, identityChosen, lobbyConnected, lobbyError,
        kickedByDuplicate,
        micOn, cameraOn,
        peerJoined, peerHasVideo, reconnecting, endReason, permissionDenied,
      ];
}
