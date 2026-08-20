import 'package:flutter_test/flutter_test.dart';
import 'package:kaicall/domain/call_models.dart';

void main() {
  group('roomNameFor — tên phòng tất định', () {
    test('hai bên tính ra CÙNG một tên dù gọi theo chiều nào', () {
      // Đây là thứ giữ cho hai máy gặp nhau mà không cần ai cấp tên phòng.
      // Hỏng chỗ này thì A vào kaicall-a-b, B vào kaicall-b-a, và hai người
      // ngồi nhìn nhau mãi không thấy — im lặng, không lỗi nào bật lên.
      expect(roomNameFor('long', 'minh'), roomNameFor('minh', 'long'));
    });

    test('sắp xếp id nên tên phòng đoán trước được', () {
      expect(roomNameFor('minh', 'long'), 'kaicall-long-minh');
    });

    test('cặp khác nhau ra phòng khác nhau', () {
      expect(roomNameFor('a', 'b'), isNot(roomNameFor('a', 'c')));
    });
  });
}
