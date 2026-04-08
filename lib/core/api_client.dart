import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'storage_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiClient {
  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (auth) {
      final token = await StorageService.getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Uri _uri(String path) => Uri.parse('${ApiConstants.baseUrl}$path');

  static dynamic _handle(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return null;
      return json.decode(res.body);
    }
    String msg = 'Request failed (${res.statusCode})';
    try {
      final b = json.decode(res.body);
      msg = b['message'] ?? b['error'] ?? b['msg'] ?? msg;
    } catch (_) {}
    throw ApiException(msg, statusCode: res.statusCode);
  }

  static Future<dynamic> get(String path) async {
    final res = await http.get(_uri(path), headers: await _headers());
    return _handle(res);
  }

  static Future<dynamic> post(String path, Map<String, dynamic> body, {bool auth = true}) async {
    final res = await http.post(
      _uri(path),
      headers: await _headers(auth: auth),
      body: json.encode(body),
    );
    return _handle(res);
  }

  static Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    final res = await http.patch(
      _uri(path),
      headers: await _headers(),
      body: json.encode(body),
    );
    return _handle(res);
  }
}
