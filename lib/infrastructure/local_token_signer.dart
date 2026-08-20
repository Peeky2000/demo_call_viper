import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../config/kaicall_config.dart';
import '../domain/ports.dart';

/// Ký access token của LiveKit NGAY TRONG APP bằng API secret.
///
/// CHỈ DÙNG CHO DEMO. Bản release không bao giờ được mang secret theo —
/// ai giải nén APK ra là lấy được, và ký được token vào mọi phòng.
/// Vì vậy có cờ chặn `KAICALL_ALLOW_INSECURE_LOCAL_TOKEN`: không bật thì
/// lớp này từ chối ký (DECISIONS.md 2026-08-20).
///
/// Đường nâng cấp đã tính sẵn: thay lớp này bằng bản gọi backend, phần còn
/// lại của app không đổi một dòng — đó là lý do có interface `TokenProvider`.
class LocalTokenSigner implements TokenProvider {
  LocalTokenSigner(this.config, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final KaiCallConfig config;
  final DateTime Function() _now;

  /// TTL 2 giờ — challenge pha V mục b. `livekit_client` không tự gia hạn
  /// token, nên cuộc gọi dài hơn 2 giờ sẽ rớt. Demo không có ca đó; ghi ra
  /// để sau này ai thấy rớt ở phút 121 thì biết ngay vì sao.
  static const Duration tokenTtl = Duration(hours: 2);

  /// Dung sai lệch đồng hồ giữa máy và server LiveKit.
  static const Duration clockSkewLeeway = Duration(seconds: 60);

  @override
  Future<String> tokenFor({
    required String roomName,
    required String identity,
    required String displayName,
  }) async {
    if (!config.allowInsecureLocalToken) {
      throw StateError(
        'Ký token trong máy đang bị chặn. Bật KAICALL_ALLOW_INSECURE_LOCAL_TOKEN '
        'để chạy demo — tuyệt đối không bật ở bản phát hành.',
      );
    }
    if (config.apiKey.trim().isEmpty || config.apiSecret.trim().isEmpty) {
      throw StateError('Thiếu KAICALL_LIVEKIT_API_KEY hoặc KAICALL_LIVEKIT_API_SECRET.');
    }

    final DateTime now = _now();
    // Lùi nbf 60 giây. Đồng hồ máy nhanh hơn server LiveKit dù chỉ vài giây là
    // token thành "chưa có hiệu lực" và bị từ chối — mà thông báo trả về không
    // nói gì về đồng hồ, nên đây là kiểu lỗi cực khó lần nếu không phòng trước.
    final int nbf = now.subtract(clockSkewLeeway).millisecondsSinceEpoch ~/ 1000;
    final int exp = now.add(tokenTtl).millisecondsSinceEpoch ~/ 1000;

    final String header = _segment(<String, dynamic>{'alg': 'HS256', 'typ': 'JWT'});
    final String payload = _segment(<String, dynamic>{
      'iss': config.apiKey.trim(),
      'sub': identity,
      'name': displayName,
      'nbf': nbf,
      'exp': exp,
      'video': <String, dynamic>{
        'room': roomName,
        'roomJoin': true,
        'canPublish': true,
        'canSubscribe': true,
        'canPublishData': true,
      },
    });

    final String signingInput = '$header.$payload';
    final Digest signature = Hmac(sha256, utf8.encode(config.apiSecret.trim()))
        .convert(utf8.encode(signingInput));

    return '$signingInput.${_base64Url(signature.bytes)}';
  }

  static String _segment(Map<String, dynamic> claims) =>
      _base64Url(utf8.encode(json.encode(claims)));

  /// base64url KHÔNG có dấu `=` — JWT không chấp nhận padding.
  static String _base64Url(List<int> bytes) =>
      base64Url.encode(bytes).replaceAll('=', '');
}
