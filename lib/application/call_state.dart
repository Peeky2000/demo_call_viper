import 'package:equatable/equatable.dart';

import '../domain/call_models.dart';
import '../domain/contact.dart';

class CallUiState extends Equatable {
  const CallUiState({
    required this.self,
    this.status = CallStatus.idle,
    this.peer,
    this.invite,
    this.lobbyConnected = false,
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
  final bool lobbyConnected;
  final bool micOn;
  final bool cameraOn;
  final bool peerJoined;
  final bool peerHasVideo;
  final bool reconnecting;
  final CallEndReason? endReason;
  final bool permissionDenied;

  /// Chỉ gọi được khi phòng chờ đang thông — nút Gọi mờ đi ở trạng thái khác.
  /// Bấm vào hư không rồi ngồi đợi là đúng cái nỗi đau ở PRD.md §1.
  bool get canCall => lobbyConnected && status == CallStatus.idle;

  CallUiState copyWith({
    Contact? self,
    CallStatus? status,
    Contact? peer,
    CallInvite? invite,
    bool? lobbyConnected,
    bool? micOn,
    bool? cameraOn,
    bool? peerJoined,
    bool? peerHasVideo,
    bool? reconnecting,
    CallEndReason? endReason,
    bool? permissionDenied,
    bool clearPeer = false,
    bool clearInvite = false,
    bool clearEndReason = false,
  }) {
    return CallUiState(
      self: self ?? this.self,
      status: status ?? this.status,
      peer: clearPeer ? null : (peer ?? this.peer),
      invite: clearInvite ? null : (invite ?? this.invite),
      lobbyConnected: lobbyConnected ?? this.lobbyConnected,
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
        self, status, peer, invite, lobbyConnected, micOn, cameraOn,
        peerJoined, peerHasVideo, reconnecting, endReason, permissionDenied,
      ];
}
