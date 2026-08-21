import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

import '../application/call_bloc.dart';
import '../application/call_event.dart';
import '../application/call_state.dart';
import '../config/kaicall_config.dart';
import '../domain/call_models.dart';
import '../domain/contact.dart';
import '../domain/ports.dart';
import '../infrastructure/livekit_call_session.dart';
import 'screens/config_error_screen.dart';
import 'screens/contacts_screen.dart';
import 'screens/in_call_screen.dart';
import 'screens/permission_screen.dart';
import 'screens/ringing_screen.dart';
import 'theme.dart';

class KaiCallApp extends StatelessWidget {
  const KaiCallApp({
    super.key,
    required this.config,
    required this.signaling,
    required this.session,
    required this.permissions,
  });

  final KaiCallConfig config;
  final SignalingPort signaling;
  final CallSessionPort session;
  final PermissionsPort permissions;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'KaiCall',
        debugShowCheckedModeBanner: false,
        theme: T.theme,
        home: config.isUsable
            ? BlocProvider<CallBloc>(
                create: (_) => CallBloc(
                  self: kDemoContacts.first,
                  signaling: signaling,
                  session: session,
                  permissions: permissions,
                ),
                // KHÔNG bắn SelfChosen ở đây. Tự chọn hộ = hai máy mở lên cùng
                // là một người, LiveKit đá một cái ra (dogfood 2026-08-21).
                // Người dùng phải bấm, và cái bấm đó mới nối vào phòng chờ.
                child: CallRouter(session: session, permissions: permissions),
              )
            // S0 — màn cụt, không dựng bloc: chưa có cấu hình thì không có gì
            // để kết nối, và đi tiếp chỉ để hỏng sâu hơn.
            : ConfigErrorScreen(missing: config.missing),
      );
}

/// Chọn màn theo trạng thái máy trạng thái — UI không tự quyết gì
/// (ARCHITECTURE.md §8).
class CallRouter extends StatelessWidget {
  const CallRouter({super.key, required this.session, required this.permissions});

  final CallSessionPort session;
  final PermissionsPort permissions;

  lk.Room? get _room => session is LiveKitCallSession
      ? (session as LiveKitCallSession).room
      : null;

  @override
  Widget build(BuildContext context) {
    final CallBloc bloc = context.read<CallBloc>();

    return BlocConsumer<CallBloc, CallUiState>(
      listenWhen: (CallUiState a, CallUiState b) =>
          a.endReason != b.endReason && b.endReason != null,
      listener: (BuildContext context, CallUiState state) {
        // Vì sao cuộc gọi kết thúc phải nói ra — AC-3, AC-6.
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(endReasonText(state.endReason!),
                style: const TextStyle(fontSize: T.textBase, color: T.text)),
            backgroundColor: T.surface,
          ));
      },
      builder: (BuildContext context, CallUiState state) {
        if (state.permissionDenied) {
          return PermissionScreen(
            permissions: permissions,
            onDismiss: () => bloc.add(const PermissionNoticeDismissed()),
          );
        }
        return switch (state.status) {
          CallStatus.incoming => RingingScreen.incoming(
              peer: state.peer!,
              onAccept: () => bloc.add(const CallAccepted()),
              onDecline: () => bloc.add(const CallDeclined()),
            ),
          CallStatus.outgoing => RingingScreen.outgoing(
              peer: state.peer!,
              onCancel: () => bloc.add(const CallCancelled()),
            ),
          CallStatus.connecting || CallStatus.inCall => InCallScreen(
              state: state,
              room: _room,
              onToggleMic: () => bloc.add(const MicToggled()),
              onToggleCamera: () => bloc.add(const CameraToggled()),
              onSwitchCamera: () => bloc.add(const CameraSwitched()),
              onHangUp: () => bloc.add(const HungUp()),
            ),
          CallStatus.idle || CallStatus.ended => ContactsScreen(
              state: state,
              onCall: (Contact peer) => bloc.add(CallRequested(peer)),
              onSwitchSelf: (Contact self) => bloc.add(SelfChosen(self)),
              onRetry: () => bloc.add(SelfChosen(state.self)),
            ),
        };
      },
    );
  }
}
