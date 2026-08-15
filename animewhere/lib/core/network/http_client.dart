import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'network_error.dart';

class AppHttpClient {
  AppHttpClient({
    http.Client? inner,
    this.timeout = const Duration(seconds: 10),
  }) : _inner = inner ?? http.Client();

  static const Map<String, String> _jsonHeaders = {
    'Accept': 'application/json',
  };

  final http.Client _inner;
  final Duration timeout;

  Future<String> getJson(
    Uri uri, {
    Map<String, String> headers = const {},
  }) async {
    final mergedHeaders = {..._jsonHeaders, ...headers};
    final response = await _guard(
      () => _inner.get(uri, headers: mergedHeaders).timeout(timeout),
    );
    return response.body;
  }

  Future<String> postJson(Uri uri, {required Object body}) async {
    final response = await _guard(
      () => _inner
          .post(
            uri,
            headers: {..._jsonHeaders, 'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(timeout),
    );
    return response.body;
  }

  Future<http.Response> _guard(Future<http.Response> Function() request) async {
    final http.Response response;
    try {
      response = await request();
    } on TimeoutException {
      throw const NetworkError('Request timed out');
    } on http.ClientException catch (error) {
      throw NetworkError(error.message);
    }

    if (response.statusCode == 429) {
      throw const RateLimitError();
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpError(statusCode: response.statusCode);
    }
    return response;
  }
}
