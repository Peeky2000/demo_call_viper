/// Cấu hình nạp qua `--dart-define` — TECHSTACK.md §6.
///
/// Không có giá trị mặc định nào cho key/secret: thiếu thì app phải hiện màn
/// chặn S0, không được đoán. API secret KHÔNG bao giờ vào bản release
/// (DECISIONS.md 2026-08-20).
class KaiCallConfig {
  const KaiCallConfig({
    required this.serverUrl,
    required this.apiKey,
    required this.apiSecret,
    required this.allowInsecureLocalToken,
  });

  factory KaiCallConfig.fromEnvironment() => const KaiCallConfig(
        serverUrl: String.fromEnvironment('KAICALL_LIVEKIT_URL'),
        apiKey: String.fromEnvironment('KAICALL_LIVEKIT_API_KEY'),
        apiSecret: String.fromEnvironment('KAICALL_LIVEKIT_API_SECRET'),
        allowInsecureLocalToken:
            bool.fromEnvironment('KAICALL_ALLOW_INSECURE_LOCAL_TOKEN'),
      );

  final String serverUrl;
  final String apiKey;
  final String apiSecret;
  final bool allowInsecureLocalToken;

  /// Tên biến còn thiếu — S0 in đúng danh sách này ra cho người dùng.
  List<String> get missing => <String>[
        if (serverUrl.trim().isEmpty) 'KAICALL_LIVEKIT_URL',
        if (apiKey.trim().isEmpty) 'KAICALL_LIVEKIT_API_KEY',
        if (apiSecret.trim().isEmpty) 'KAICALL_LIVEKIT_API_SECRET',
        if (!allowInsecureLocalToken) 'KAICALL_ALLOW_INSECURE_LOCAL_TOKEN',
      ];

  bool get isUsable => missing.isEmpty;
}
