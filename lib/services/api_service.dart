import 'package:http/http.dart' as http;
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ApiService {
  final http.Client _client = http.Client();

  Future<http.Response> get(String url) async {
    final response = await _client.get(Uri.parse(url));
    _handleErrors(response);
    return response;
  }

  Future<http.Response> post(String url, {Object? body}) async {
    final response = await _client.post(Uri.parse(url), body: body);
    _handleErrors(response);
    return response;
  }

  void _handleErrors(http.Response response) {
    if (response.statusCode >= 400) {
      throw Exception('API Error: ${response.statusCode}');
    }
  }
}

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
