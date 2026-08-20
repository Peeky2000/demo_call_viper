import 'package:flutter/material.dart';

import 'config/kaicall_config.dart';
import 'infrastructure/device_permissions.dart';
import 'infrastructure/livekit_call_session.dart';
import 'infrastructure/livekit_signaling.dart';
import 'infrastructure/local_token_signer.dart';
import 'presentation/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final KaiCallConfig config = KaiCallConfig.fromEnvironment();
  // Ký token trong máy — CHỈ DEMO, chặn sau cờ (DECISIONS.md 2026-08-20).
  // Đổi sang backend chỉ cần thay dòng này bằng một TokenProvider khác.
  final LocalTokenSigner tokens = LocalTokenSigner(config);

  runApp(KaiCallApp(
    config: config,
    signaling: LiveKitSignaling(config: config, tokens: tokens),
    session: LiveKitCallSession(config: config, tokens: tokens),
    permissions: const DevicePermissions(),
  ));
}
