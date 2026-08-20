import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/call_widgets.dart';

/// S0 — màn CỤT, cố ý không có đường ra. Thiếu cấu hình thì sửa
/// `--dart-define` rồi mở lại app; cho đi tiếp vào danh bạ chỉ để hỏng sâu
/// hơn ở chỗ khó đoán hơn (PROTOTYPE.md §2).
class ConfigErrorScreen extends StatelessWidget {
  const ConfigErrorScreen({super.key, required this.missing});

  final List<String> missing;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(T.spaceLg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Center(child: Avatar(initial: '!', size: 128)),
                const SizedBox(height: T.spaceLg),
                const Text('Chưa chạy được',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: T.textXl, color: T.text, fontWeight: FontWeight.w700)),
                const SizedBox(height: T.spaceSm),
                const Text('Thiếu thông tin kết nối LiveKit',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: T.textSm, color: T.textMuted)),
                const SizedBox(height: T.spaceMd),
                Container(
                  padding: const EdgeInsets.all(T.spaceMd),
                  decoration: BoxDecoration(
                    color: T.surface,
                    border: Border.all(color: T.danger),
                    borderRadius: BorderRadius.circular(T.radius),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      for (final String name in missing)
                        Padding(
                          padding: const EdgeInsets.only(bottom: T.spaceSm),
                          child: Text(name,
                              style: const TextStyle(
                                  fontSize: T.textSm,
                                  color: T.textMuted,
                                  fontFamily: 'monospace')),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: T.spaceMd),
                const Text('Nạp các giá trị này qua --dart-define rồi mở lại app.\n'
                    'Xem: make doctor',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: T.textSm, color: T.textMuted)),
              ],
            ),
          ),
        ),
      );
}
