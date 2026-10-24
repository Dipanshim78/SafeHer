import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'platform_host.dart';

class ApiService {
  static const _configuredServerHost = String.fromEnvironment('API_BASE_URL');

  static String get serverHost {
    final host = _configuredServerHost.isEmpty
        ? getServerHost()
        : _configuredServerHost;
    if (host.contains('your-api-host')) {
      throw StateError(
        'Replace the API_BASE_URL example with your deployed backend URL, '
        'or omit it to use the local backend.',
      );
    }
    return host.endsWith('/') ? host.substring(0, host.length - 1) : host;
  }

  static const String _tokenKey = 'auth_token';
  static const String _lastLoginEmailKey = 'last_login_email';

  static Map<String, String> get _jsonHeaders => {
    'Content-Type': 'application/json',
  };

  static Uri _url(String path) => Uri.parse('$serverHost$path');

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<String?> getLastLoginEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastLoginEmailKey);
  }

  static Future<void> setLastLoginEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastLoginEmailKey, email.trim());
  }

  static Future<void> clearLastLoginEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastLoginEmailKey);
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token is missing. Please login again.');
    }
    return {..._jsonHeaders, 'Authorization': 'Bearer $token'};
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    final response = await http.post(
      _url('/api/auth/register'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
      }),
    );
    return _parseResponse(response);
  }

  static Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      _url('/api/auth/login'),
      headers: _jsonHeaders,
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = _parseResponse(response);
    if (data.containsKey('token')) {
      final token = data['token'] as String;
      await setToken(token);
      await setLastLoginEmail(email);
      return token;
    }

    throw Exception('Login failed: no token returned');
  }

  static Future<Map<String, dynamic>> sendAlert({
    double? latitude,
    double? longitude,
  }) async {
    print("SEND ALERT FUNCTION STARTED");
    if ((latitude == null) != (longitude == null)) {
      throw ArgumentError('Latitude and longitude must be provided together.');
    }

    final body = <String, double>{};
    if (latitude != null && longitude != null) {
      body['latitude'] = latitude;
      body['longitude'] = longitude;
    }
print("SENDING SOS REQUEST TO BACKEND");
    final response = await http.post(
      _url('/api/alerts/send'),
      headers: await _authHeaders(),
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 10));
    return _parseResponse(response);
  }

  // static Future<Map<String, dynamic>> addContact({
  //   required String name,
  //   required String phone,
  // }) async {
  //   final response = await http.post(
  //     _url('/api/contacts/add'),
  //     headers: await _authHeaders(),
  //     body: jsonEncode({'name': name, 'phone': phone}),
  //   );
  //   return _parseResponse(response);
  // }
  static Future<Map<String, dynamic>> addContact({
  required String name,
  required String phone,
  required String email,
}) async {
  final response = await http.post(
    _url('/api/contacts/add'),
    headers: await _authHeaders(),
    body: jsonEncode({
      'name': name,
      'phone': phone,
      'email': email,
    }),
  );

  return _parseResponse(response);
}
static Future<Map<String, dynamic>> updateContact({
  required String id,
  required String name,
  required String phone,
  required String email,
}) async {
  final response = await http.put(
    _url('/api/contacts/$id'),
    headers: await _authHeaders(),
    body: jsonEncode({
      'name': name,
      'phone': phone,
      'email': email,
    }),
  );

  return _parseResponse(response);
}
static Future<Map<String, dynamic>> deleteContact({
  required String id,
}) async {
  final response = await http.delete(
    _url('/api/contacts/$id'),
    headers: await _authHeaders(),
  );

  return _parseResponse(response);
}
  static Future<Map<String, dynamic>> askAssistant({
    required String message,
    List<Map<String, String>> history = const [],
    double? latitude,
    double? longitude,
  }) async {
    final response = await http.post(
      _url('/api/chatbot/ask'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'message': message,
        'history': history,
        if (latitude != null && longitude != null) ...{
          'latitude': latitude,
          'longitude': longitude,
        },
      }),
    );
    return _parseResponse(response);
  }

  static Future<List<dynamic>> searchMapPlaces({required String query}) async {
    final uri = _url('/api/map/search').replace(
      queryParameters: {'q': query},
    );
    final response = await http.get(uri, headers: _jsonHeaders);
    return _parseListResponse(response);
  }

  static Future<Map<String, dynamic>> getWalkingRoute({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) async {
    final response = await http.post(
      _url('/api/map/route'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'start': [startLongitude, startLatitude],
        'end': [endLongitude, endLatitude],
      }),
    );
    return _parseResponse(response);
  }

  static Future<List<dynamic>> getNearbyEmergencyServices({
    required double latitude,
    required double longitude,
  }) async {
    final uri = _url('/api/map/nearby').replace(
      queryParameters: {
        'lat': latitude.toString(),
        'lon': longitude.toString(),
      },
    );
    final response = await http.get(uri, headers: _jsonHeaders);
    return _parseListResponse(response);
  }

  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    final response = await http.post(
      _url('/api/auth/forgot-password'),
      headers: _jsonHeaders,
      body: jsonEncode({'email': email}),
    );
    return _parseResponse(response);
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final response = await http.post(
      _url('/api/auth/reset-password'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      }),
    );
    return _parseResponse(response);
  }

  static Future<List<dynamic>> getContacts() async {
    final response = await http.get(
      _url('/api/contacts/'),
      headers: await _authHeaders(),
    );
    return _parseListResponse(response);
  }

  static Future<Map<String, dynamic>> getUser() async {
    final response = await http.get(
      _url('/api/auth/me'),
      headers: await _authHeaders(),
    );
    return _parseResponse(response);
  }
  static Future<Map<String, dynamic>> updateProfile({
  String? name,
  String? email,
  String? secretWord,
  String? homeAddress,
}) async {
  final response = await http.put(
    _url('/api/auth/profile'),
    headers: await _authHeaders(),
    body: jsonEncode({
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (secretWord != null) 'secretWord': secretWord,
      if (homeAddress != null) 'homeAddress': homeAddress,
    }),
  );

  return _parseResponse(response);
}
  static Future<void> logout() async {
    await clearToken();
  }

  static Map<String, dynamic> _parseResponse(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body is Map<String, dynamic> ? body : {'data': body};
    }
    final message = body is Map && body['msg'] != null
        ? body['msg']
        : response.reasonPhrase ?? 'Unknown error';
    throw Exception('API Error: $message');
  }

  static List<dynamic> _parseListResponse(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body is List ? body : [body];
    }
    final message = body is Map && body['msg'] != null
        ? body['msg']
        : response.reasonPhrase ?? 'Unknown error';
    throw Exception('API Error: $message');
  }
}
