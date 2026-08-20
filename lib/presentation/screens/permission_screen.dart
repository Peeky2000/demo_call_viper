import 'package:flutter/material.dart';

import '../../domain/ports.dart';
import '../theme.dart';
import '../widgets/call_widgets.dart';

/// S5 — quyền bị từ chối. AC-5: không crash, không màn trắng, và phải có
/// đường tự sửa (nút mở Cài đặt hệ thống).
class PermissionScreen extends StatelessWidget {
  const PermissionScreen({
    super.key,
    required this.permissions,
    required this.onDismiss,
  });

  final PermissionsPort permissions;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(T.spaceLg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Avatar(initial: '!', size: 128),
                const SizedBox(height: T.spaceLg),
                const Text('Cần quyền',
                    style: TextStyle(
                        fontSize: T.textXl, color: T.text, fontWeight: FontWeight.w700)),
                const SizedBox(height: T.spaceMd),
                Container(
                  padding: const EdgeInsets.all(T.spaceMd),
                  decoration: BoxDecoration(
                    color: T.surface,
                    borderRadius: BorderRadius.circular(T.radius),
                  ),
                  child: const Text(
                    'KaiCall cần micrô để bạn nói, và camera để bên kia nhìn thấy bạn. '
                    'Bạn đã từ chối trước đó nên phải bật lại trong Cài đặt.',
                    style: TextStyle(fontSize: T.textBase, color: T.text),
                  ),
                ),
                const SizedBox(height: T.spaceLg),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: T.primary,
                    foregroundColor: T.onPrimary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: T.spaceLg, vertical: T.spaceMd),
                  ),
                  onPressed: permissions.openSystemSettings,
                  child: const Text('Mở Cài đặt', style: TextStyle(fontSize: T.textBase)),
                ),
                const SizedBox(height: T.spaceMd),
                TextButton(
                  onPressed: onDismiss,
                  child: const Text('Quay lại danh bạ',
                      style: TextStyle(fontSize: T.textSm, color: T.textMuted)),
                ),
              ],
            ),
          ),
        ),
      );
}
