import 'package:flutter/material.dart';

import '../../application/call_state.dart';
import '../../domain/call_models.dart';
import '../../domain/contact.dart';
import '../theme.dart';
import '../widgets/call_widgets.dart';

/// S1 — danh bạ. Màn đầu tiên mở app: nhìn là biết app gọi điện, bấm một
/// người là gọi (PROTOTYPE.md §1).
class ContactsScreen extends StatelessWidget {
  const ContactsScreen({
    super.key,
    required this.state,
    required this.onCall,
    required this.onSwitchSelf,
  });

  final CallUiState state;
  final void Function(Contact peer) onCall;
  final void Function(Contact self) onSwitchSelf;

  @override
  Widget build(BuildContext context) {
    final List<Contact> others =
        kDemoContacts.where((Contact c) => c.id != state.self.id).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(T.spaceLg, T.spaceMd, T.spaceLg, T.spaceSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('KaiCall',
                      style: TextStyle(
                          fontSize: T.textXl, color: T.text, fontWeight: FontWeight.w700)),
                  const SizedBox(height: T.spaceSm / 2),
                  Row(
                    children: <Widget>[
                      Text('Bạn đang là ${state.self.displayName}',
                          style: const TextStyle(fontSize: T.textSm, color: T.textMuted)),
                      const SizedBox(width: T.spaceSm),
                      // Đổi danh tính: để một máy đóng vai nào cũng được khi
                      // thử với emulator (PRD.md §7 đăng nhập = không có).
                      for (final Contact c in kDemoContacts)
                        if (c.id != state.self.id)
                          TextButton(
                            onPressed: () => onSwitchSelf(c),
                            child: Text('đổi sang ${c.displayName}',
                                style: const TextStyle(
                                    fontSize: T.textSm, color: T.primary)),
                          ),
                    ],
                  ),
                ],
              ),
            ),
            StatusBanner(
              text: state.lobbyConnected
                  ? 'Đã kết nối'
                  : 'Chưa kết nối được máy chủ — chưa gọi được',
              bad: !state.lobbyConnected,
            ),
            Expanded(
              child: ListView.separated(
                itemCount: others.length,
                separatorBuilder: (BuildContext _, int _) => const Divider(height: 1, color: T.surface),
                itemBuilder: (BuildContext context, int i) {
                  final Contact c = others[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: T.spaceLg, vertical: T.spaceMd),
                    child: Row(
                      children: <Widget>[
                        Avatar(initial: c.initial),
                        const SizedBox(width: T.spaceMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(c.displayName,
                                  style: const TextStyle(
                                      fontSize: T.textBase,
                                      color: T.text,
                                      fontWeight: FontWeight.w600)),
                              Text(c.note,
                                  style: const TextStyle(
                                      fontSize: T.textSm, color: T.textMuted)),
                            ],
                          ),
                        ),
                        CircleAction(
                          key: Key('call-${c.id}'),
                          icon: Icons.call,
                          label: 'Gọi',
                          size: 46,
                          background: T.primary,
                          foreground: T.onPrimary,
                          // Nút mờ khi phòng chờ chưa thông — bấm vào hư không
                          // rồi ngồi đợi chính là nỗi đau ở PRD.md §1.
                          onTap: state.canCall ? () => onCall(c) : null,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Câu hiện lên khi một cuộc gọi vừa kết thúc. Mọi nhánh kết thúc đều về đây,
/// kể cả nhánh lỗi — không nhánh nào được dừng ở màn không có đường ra.
String endReasonText(CallEndReason reason) => switch (reason) {
      CallEndReason.hangUp => 'Cuộc gọi đã kết thúc',
      CallEndReason.rejected => 'Bị từ chối',
      CallEndReason.cancelled => 'Đã huỷ cuộc gọi',
      CallEndReason.noAnswer => 'Không trả lời',
      CallEndReason.peerLeft => 'Người kia đã rời cuộc gọi',
      CallEndReason.connectionLost => 'Mất kết nối',
      CallEndReason.failed => 'Không vào được cuộc gọi',
    };
