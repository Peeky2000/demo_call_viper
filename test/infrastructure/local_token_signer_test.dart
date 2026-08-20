import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kaicall/config/kaicall_config.dart';
import 'package:kaicall/infrastructure/local_token_signer.dart';

KaiCallConfig _config({bool allow = true}) => KaiCallConfig(
      serverUrl: 'wss://example.livekit.cloud',
      apiKey: 'APIkey123',
      apiSecret: 'secret-value-for-test',
      allowInsecureLocalToken: allow,
    );

Map<String, dynamic> _payload(String jwt) {
  final String seg = jwt.split('.')[1];
  return json.decode(utf8.decode(base64Url.decode(base64Url.normalize(seg))))
      as Map<String, dynamic>;
}

void main() {
  final DateTime fixed = DateTime.utc(2026, 8, 20, 10);

  test('cờ chặn tắt thì TỪ CHỐI ký — secret không được rời máy dev', () async {
    final LocalTokenSigner signer = LocalTokenSigner(_config(allow: false));
    expect(
      () => signer.tokenFor(roomName: 'r', identity: 'i', displayName: 'I'),
      throwsA(isA<StateError>()),
    );
  });

  test('JWT có 3 phần và KHÔNG có padding "=" — JWT không nhận padding', () async {
    final String jwt = await LocalTokenSigner(_config(), now: () => fixed)
        .tokenFor(roomName: 'kaicall-long-minh', identity: 'long', displayName: 'Long');
    expect(jwt.split('.'), hasLength(3));
    expect(jwt.contains('='), isFalse);
  });

  test('claim video đúng thứ LiveKit cần để vào phòng và gửi data', () async {
    final String jwt = await LocalTokenSigner(_config(), now: () => fixed)
        .tokenFor(roomName: 'kaicall-long-minh', identity: 'long', displayName: 'Long');
    final Map<String, dynamic> p = _payload(jwt);
    expect(p['iss'], 'APIkey123');
    expect(p['sub'], 'long'); // identity = Contact.id, để LiveKit đá bản cũ
    final Map<String, dynamic> video = p['video'] as Map<String, dynamic>;
    expect(video['room'], 'kaicall-long-minh');
    expect(video['roomJoin'], isTrue);
    expect(video['canPublishData'], isTrue); // thiếu cái này thì phòng chờ câm
  });

  test('TTL đúng 2 giờ tính từ BÂY GIỜ — mốc đã chốt ở challenge pha V', () async {
    final String jwt = await LocalTokenSigner(_config(), now: () => fixed)
        .tokenFor(roomName: 'r', identity: 'i', displayName: 'I');
    final Map<String, dynamic> p = _payload(jwt);
    final int now = fixed.millisecondsSinceEpoch ~/ 1000;
    // Đo từ `now`, KHÔNG đo `exp - nbf`: nbf đã lùi lại nên hiệu hai số đó là
    // 2 giờ + dung sai, không phải TTL.
    expect((p['exp'] as int) - now, 2 * 60 * 60);
  });

  test('nbf lùi 60 giây — đồng hồ máy nhanh hơn server thì token vẫn dùng được', () async {
    // Không có dung sai này thì lệch đồng hồ vài giây là LiveKit từ chối token,
    // mà thông báo trả về không hề nhắc tới đồng hồ — cực khó lần.
    final String jwt = await LocalTokenSigner(_config(), now: () => fixed)
        .tokenFor(roomName: 'r', identity: 'i', displayName: 'I');
    final int now = fixed.millisecondsSinceEpoch ~/ 1000;
    expect(now - (_payload(jwt)['nbf'] as int), 60);
  });
}
