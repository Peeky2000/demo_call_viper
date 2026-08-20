import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

import '../../application/call_state.dart';
import '../theme.dart';
import '../widgets/call_widgets.dart';

/// S4 — trong cuộc gọi. Màn quan trọng nhất: video tràn vùng, ô "Bạn" nhỏ góc
/// phải, banner trạng thái ở đỉnh, bốn nút điều khiển dưới đáy.
class InCallScreen extends StatelessWidget {
  const InCallScreen({
    super.key,
    required this.state,
    required this.room,
    required this.onToggleMic,
    required this.onToggleCamera,
    required this.onSwitchCamera,
    required this.onHangUp,
  });

  final CallUiState state;
  final lk.Room? room;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleCamera;
  final VoidCallback onSwitchCamera;
  final VoidCallback onHangUp;

  lk.VideoTrack? get _remoteVideo => room?.remoteParticipants.values
      .expand((lk.RemoteParticipant p) => p.videoTrackPublications)
      .map((lk.RemoteTrackPublication<lk.RemoteVideoTrack> p) => p.track)
      .whereType<lk.VideoTrack>()
      .firstOrNull;

  lk.VideoTrack? get _localVideo => room?.localParticipant?.videoTrackPublications
      .map((lk.LocalTrackPublication<lk.LocalVideoTrack> p) => p.track)
      .whereType<lk.VideoTrack>()
      .firstOrNull;

  String get _banner {
    if (state.reconnecting) return 'Đang kết nối lại…';
    if (!state.peerJoined) return 'Đang chờ ${state.peer?.displayName ?? ''} vào…';
    return state.peer?.displayName ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final lk.VideoTrack? remote = _remoteVideo;
    final lk.VideoTrack? local = _localVideo;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const SizedBox(height: T.spaceSm),
            StatusBanner(text: _banner, bad: state.reconnecting),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: T.spaceMd),
                decoration: BoxDecoration(
                  color: T.surface,
                  borderRadius: BorderRadius.circular(T.radius),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: <Widget>[
                    // Chưa có hình bên kia → avatar + tên, KHÔNG để khung đen
                    // trơn (DESIGN-SYSTEM.md §5, khuôn "rỗng").
                    Positioned.fill(
                      child: remote != null
                          ? lk.VideoTrackRenderer(remote)
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Avatar(initial: state.peer?.initial ?? '?', size: 128),
                                const SizedBox(height: T.spaceMd),
                                Text(
                                  state.peerJoined
                                      ? '${state.peer?.displayName} đã tắt camera'
                                      : 'đang chờ hình…',
                                  style: const TextStyle(
                                      fontSize: T.textSm, color: T.textMuted),
                                ),
                              ],
                            ),
                    ),
                    Positioned(
                      top: T.spaceMd,
                      right: T.spaceMd,
                      child: Container(
                        width: 92,
                        height: 124,
                        decoration: BoxDecoration(
                          color: T.bg,
                          border: Border.all(color: T.border),
                          borderRadius: BorderRadius.circular(T.radius),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: (local != null && state.cameraOn)
                            ? lk.VideoTrackRenderer(local)
                            : const Center(
                                child: Text('Bạn',
                                    style: TextStyle(
                                        fontSize: T.textSm, color: T.textMuted)),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(T.spaceLg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  CircleAction(
                    key: const Key('mic'),
                    icon: state.micOn ? Icons.mic : Icons.mic_off,
                    label: state.micOn ? 'Tắt mic' : 'Bật mic',
                    size: 46,
                    background: state.micOn ? T.surface : T.text,
                    foreground: state.micOn ? T.text : T.bg,
                    onTap: onToggleMic,
                  ),
                  CircleAction(
                    key: const Key('camera'),
                    icon: state.cameraOn ? Icons.videocam : Icons.videocam_off,
                    label: state.cameraOn ? 'Tắt cam' : 'Bật cam',
                    size: 46,
                    background: state.cameraOn ? T.surface : T.text,
                    foreground: state.cameraOn ? T.text : T.bg,
                    onTap: onToggleCamera,
                  ),
                  CircleAction(
                    key: const Key('switch-camera'),
                    icon: Icons.cameraswitch,
                    label: 'Đổi cam',
                    size: 46,
                    onTap: onSwitchCamera,
                  ),
                  CircleAction(
                    key: const Key('hangup'),
                    icon: Icons.call_end,
                    label: 'Cúp máy',
                    size: 46,
                    background: T.danger,
                    foreground: T.onPrimary,
                    onTap: onHangUp,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
