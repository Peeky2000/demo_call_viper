import 'package:equatable/equatable.dart';

/// Một người trong danh bạ. Đúng 2 bản ghi, hằng số trong source —
/// PRD.md §7 "Dữ liệu mẫu", ARCHITECTURE.md §6.
class Contact extends Equatable {
  const Contact({required this.id, required this.displayName, required this.note});

  final String id;
  final String displayName;

  /// Dòng phụ dưới tên — ở demo này ghi thiết bị, để người thử biết
  /// bấm cái nào là gọi sang máy nào.
  final String note;

  String get initial => displayName.characters;

  @override
  List<Object?> get props => <Object?>[id, displayName, note];
}

extension on String {
  String get characters => isEmpty ? '?' : substring(0, 1).toUpperCase();
}

/// Danh bạ cố định. `id` là khoá dựng tên phòng nên KHÔNG được đổi tuỳ tiện:
/// hai máy phải tính ra cùng một tên phòng (ARCHITECTURE.md §6).
const List<Contact> kDemoContacts = <Contact>[
  Contact(id: 'long', displayName: 'Long', note: 'Máy Android'),
  Contact(id: 'minh', displayName: 'Minh', note: 'Emulator'),
];
