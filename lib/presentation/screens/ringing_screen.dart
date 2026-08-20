import 'package:flutter/material.dart';

import '../../domain/contact.dart';
import '../theme.dart';
import '../widgets/call_widgets.dart';

/// S2 (cuộc gọi đến) và S3 (đang gọi đi) — cùng một bố cục, khác hàng nút.
/// Gộp một widget vì hai màn chỉ khác đúng phần dưới đáy; tách ra là nhân đôi
/// chỗ phải sửa khi Authority đổi ý về hình thức.
class RingingScreen extends StatelessWidget {
  const RingingScreen({
    super.key,
    required this.peer,
    required this.caption,
    required this.actions,
  });

  /// S2 — có tên người gọi + hai nút Từ chối / Nghe.
  factory RingingScreen.incoming({
    required Contact peer,
    required VoidCallback onAccept,
    required VoidCallback onDecline,
  }) =>
      RingingScreen(
        peer: peer,
        caption: 'Cuộc gọi đến',
        actions: <Widget>[
          CircleAction(
            key: const Key('decline'),
            icon: Icons.call_end,
            label: 'Từ chối',
            background: T.danger,
            foreground: T.onPrimary,
            onTap: onDecline,
          ),
          CircleAction(
            key: const Key('accept'),
            icon: Icons.call,
            label: 'Nghe',
            background: T.primary,
            foreground: T.onPrimary,
            onTap: onAccept,
          ),
        ],
      );

  /// S3 — đang gọi đi, một nút Huỷ.
  factory RingingScreen.outgoing({
    required Contact peer,
    required VoidCallback onCancel,
  }) =>
      RingingScreen(
        peer: peer,
        caption: 'Đang gọi…',
        actions: <Widget>[
          CircleAction(
            key: const Key('cancel'),
            icon: Icons.call_end,
            label: 'Huỷ',
            background: T.danger,
            foreground: T.onPrimary,
            onTap: onCancel,
          ),
        ],
      );

  final Contact peer;
  final String caption;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(caption,
                        style: const TextStyle(fontSize: T.textSm, color: T.textMuted)),
                    const SizedBox(height: T.spaceLg),
                    Avatar(initial: peer.initial, size: 128),
                    const SizedBox(height: T.spaceLg),
                    Text(peer.displayName,
                        style: const TextStyle(
                            fontSize: T.textXl,
                            color: T.text,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(T.spaceLg),
                child: Row(
                  mainAxisAlignment: actions.length > 1
                      ? MainAxisAlignment.spaceEvenly
                      : MainAxisAlignment.center,
                  children: actions,
                ),
              ),
            ],
          ),
        ),
      );
}
