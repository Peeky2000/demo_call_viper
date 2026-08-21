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
    required this.onRetry,
  });

  final CallUiState state;
  final void Function(Contact peer) onCall;
  final void Function(Contact self) onSwitchSelf;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final List<Contact> others =
        kDemoContacts.where((Contact c) => c.id != state.self.id).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Tiêu đề
            const Padding(
              padding: EdgeInsets.fromLTRB(T.spaceLg, T.spaceMd, T.spaceLg, T.spaceMd),
              child: Text('KaiCall',
                  style: TextStyle(
                      fontSize: T.textXl, color: T.text, fontWeight: FontWeight.w700)),
            ),

            // Chọn danh tính. Không có đăng nhập (PRD.md §7) nên đây là cách
            // DUY NHẤT nói cho app biết máy này là ai. Hai máy phải chọn hai
            // vai khác nhau — cùng vai thì LiveKit đá một máy ra vì trùng
            // identity (ARCHITECTURE.md §7c). Vì vậy nó đứng trên cùng và có
            // nhãn nói rõ việc phải làm, không phải một link chữ nhỏ.
            Container(
              margin: const EdgeInsets.symmetric(horizontal: T.spaceLg),
              padding: const EdgeInsets.all(T.spaceMd),
              decoration: BoxDecoration(
                color: T.surface,
                borderRadius: BorderRadius.circular(T.radius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Máy này là ai?',
                      style: TextStyle(fontSize: T.textSm, color: T.textMuted)),
                  const SizedBox(height: T.spaceSm),
                  Row(
                    children: <Widget>[
                      for (final Contact c in kDemoContacts)
                        Padding(
                          padding: const EdgeInsets.only(right: T.spaceSm),
                          child: _IdentityChip(
                            key: Key('be-${c.id}'),
                            contact: c,
                            selected: c.id == state.self.id,
                            onTap: () => onSwitchSelf(c),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: T.spaceMd),
            if (state.lobbyConnected)
              const StatusBanner(text: 'Đã kết nối')
            else
              Container(
                margin: const EdgeInsets.symmetric(horizontal: T.spaceLg),
                padding: const EdgeInsets.all(T.spaceMd),
                decoration: BoxDecoration(
                  color: T.surface,
                  border: Border.all(color: T.danger),
                  borderRadius: BorderRadius.circular(T.radius),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                        state.kickedByDuplicate
                            ? 'Máy khác đang dùng danh tính "${state.self.displayName}"'
                            : 'Chưa vào được máy chủ — chưa gọi được',
                        style: const TextStyle(fontSize: T.textBase, color: T.danger)),
                    if (state.lobbyError != null) ...<Widget>[
                      const SizedBox(height: T.spaceSm),
                      // Lý do thô của SDK. Xấu, nhưng đây là màn của người thử
                      // kỹ thuật (PERSONAS.md) — giấu lý do đi thì họ phải đoán,
                      // và đoán là thứ tốn thời gian nhất khi đang gấp.
                      Text(state.lobbyError!,
                          style: const TextStyle(
                              fontSize: T.textSm, color: T.textMuted)),
                    ],
                    const SizedBox(height: T.spaceSm),
                    // Bị đá vì trùng danh tính thì KHÔNG mời "Thử lại": bấm vào
                    // là vào lại rồi đá ngược máy kia ra, hai máy đá nhau vô
                    // hạn. Việc đúng là đổi vai ở thẻ trên.
                    if (state.kickedByDuplicate)
                      const Text(
                        'Chọn người khác ở thẻ "Máy này là ai?" phía trên — '
                        'hai máy không dùng chung một người được.',
                        style: TextStyle(fontSize: T.textSm, color: T.text),
                      )
                    else
                      TextButton(
                        key: const Key('retry-lobby'),
                        onPressed: onRetry,
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: const Text('Thử lại',
                            style: TextStyle(fontSize: T.textBase, color: T.primary)),
                      ),
                  ],
                ),
              ),
            const Padding(
              padding: EdgeInsets.fromLTRB(T.spaceLg, T.spaceSm, T.spaceLg, T.spaceSm),
              child: Text('GỌI CHO',
                  style: TextStyle(
                      fontSize: T.textSm, color: T.textMuted, letterSpacing: 1.2)),
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
            // Danh bạ chỉ có 1 dòng (2 người, mình là một) nên phần dưới trống
            // trơn. Chỗ trống đó phải nói được việc tiếp theo, không để đen.
            Padding(
              padding: const EdgeInsets.all(T.spaceLg),
              child: Column(
                children: <Widget>[
                  const Icon(Icons.phonelink_ring, color: T.border, size: 40),
                  const SizedBox(height: T.spaceMd),
                  Text(
                    'Mở KaiCall ở máy thứ hai, chọn '
                    '"${others.isEmpty ? '' : others.first.displayName}" ở đó, '
                    'rồi bấm nút gọi ở đây.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: T.textSm, color: T.textMuted),
                  ),
                  const SizedBox(height: T.spaceSm),
                  const Text(
                    'Hai máy phải chọn hai người khác nhau.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: T.textSm, color: T.textMuted),
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

/// Chip chọn danh tính. Cái đang chọn tô nền chính để nhìn một cái là biết
/// máy này đang đóng vai ai — đây là thứ hay bấm nhầm nhất khi thử hai máy.
class _IdentityChip extends StatelessWidget {
  const _IdentityChip({
    super.key,
    required this.contact,
    required this.selected,
    required this.onTap,
  });

  final Contact contact;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: selected ? T.primary : T.bg,
        borderRadius: BorderRadius.circular(T.radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(T.radius),
          onTap: selected ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: T.spaceMd, vertical: T.spaceSm),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (selected) ...<Widget>[
                  const Icon(Icons.check, size: 18, color: T.onPrimary),
                  const SizedBox(width: T.spaceSm / 2),
                ],
                Text(
                  contact.displayName,
                  style: TextStyle(
                    fontSize: T.textBase,
                    color: selected ? T.onPrimary : T.text,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
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
