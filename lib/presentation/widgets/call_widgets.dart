import 'package:flutter/material.dart';

import '../theme.dart';

/// Avatar tròn chữ cái đầu. Dùng ở danh bạ (52px) và các màn gọi (128px).
class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.initial, this.size = 52});

  final String initial;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(color: T.border, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Text(
          initial,
          style: TextStyle(
            fontSize: size > 80 ? T.textXl : T.textBase,
            color: T.text,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}

/// C1 — nút tròn hành động. `label` luôn có: icon không kèm chữ là thứ
/// DESIGN-SYSTEM.md §1 ghi rõ "cố tình tránh".
class CircleAction extends StatelessWidget {
  const CircleAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.background = T.surface,
    this.foreground = T.text,
    this.size = 68,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color background;
  final Color foreground;
  final double size;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Semantics(
          button: true,
          label: label,
          child: Material(
            color: enabled ? background : T.surface,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: SizedBox(
                width: size,
                height: size,
                child: Icon(icon,
                    color: enabled ? foreground : T.textMuted, size: size * 0.4),
              ),
            ),
          ),
        ),
        const SizedBox(height: T.spaceSm),
        Text(label, style: const TextStyle(fontSize: T.textSm, color: T.textMuted)),
      ],
    );
  }
}

/// C6 — banner trạng thái kết nối.
class StatusBanner extends StatelessWidget {
  const StatusBanner({super.key, required this.text, this.bad = false});

  final String text;
  final bool bad;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(T.spaceLg, 0, T.spaceLg, T.spaceSm),
        padding: const EdgeInsets.symmetric(horizontal: T.spaceMd, vertical: T.spaceSm),
        decoration: BoxDecoration(
          color: T.surface,
          borderRadius: BorderRadius.circular(T.radius),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: T.textSm, color: bad ? T.danger : T.textMuted),
        ),
      );
}
