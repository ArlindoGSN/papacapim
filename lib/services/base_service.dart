class BaseService {
  static const String baseUrl = 'https://api.papacapim.just.pro.br';
  static String? _sessionToken;

  static void setSessionToken(String? token) {
    _sessionToken = token;
  }

  static Map<String, String> get headers {
    final headers = {'Content-Type': 'application/json'};
    if (_sessionToken != null) {
      headers['x-session-token'] = _sessionToken!;
    }
    return headers;
  }
}