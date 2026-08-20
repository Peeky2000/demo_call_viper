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

  test('TTL đúng 2 giờ — mốc đã chốt ở challenge pha V', () async {
    final String jwt = await LocalTokenSigner(_config(), now: () => fixed)
        .tokenFor(roomName: 'r', identity: 'i', displayName: 'I');
    final Map<String, dynamic> p = _payload(jwt);
    expect((p['exp'] as int) - (p['nbf'] as int), 2 * 60 * 60);
  });
}
