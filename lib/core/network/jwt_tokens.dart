class JwtTokens {
  const JwtTokens({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;
}

class JwtTokensParser {
  static const List<String> _accessTokenKeys = <String>[
    'accessToken',
    'access_token',
  ];
  static const List<String> _refreshTokenKeys = <String>[
    'refreshToken',
    'refresh_token',
  ];
  static const List<String> _nestedPayloadKeys = <String>[
    'data',
    'result',
    'payload',
  ];

  static JwtTokens? tryParse(dynamic rawPayload) {
    final rootMap = _asStringKeyMap(rawPayload);
    if (rootMap == null) return null;

    final fromRoot = _readTokens(rootMap);
    if (fromRoot != null) return fromRoot;

    for (final key in _nestedPayloadKeys) {
      final nestedMap = _asStringKeyMap(rootMap[key]);
      if (nestedMap == null) continue;

      final fromNested = _readTokens(nestedMap);
      if (fromNested != null) return fromNested;
    }

    return null;
  }

  static JwtTokens? _readTokens(Map<String, dynamic> payload) {
    final accessToken = _readToken(payload, _accessTokenKeys);
    final refreshToken = _readToken(payload, _refreshTokenKeys);

    if (accessToken == null || refreshToken == null) {
      return null;
    }

    return JwtTokens(accessToken: accessToken, refreshToken: refreshToken);
  }

  static String? _readToken(
    Map<String, dynamic> payload,
    List<String> supportedKeys,
  ) {
    for (final key in supportedKeys) {
      final value = payload[key];
      if (value == null) continue;

      final token = value.toString().trim();
      if (token.isEmpty || token.toLowerCase() == 'null') continue;

      return token;
    }

    return null;
  }

  static Map<String, dynamic>? _asStringKeyMap(dynamic value) {
    if (value is! Map) return null;

    final normalized = <String, dynamic>{};
    value.forEach((dynamic key, dynamic val) {
      if (key == null) return;
      normalized[key.toString()] = val;
    });
    return normalized;
  }
}
