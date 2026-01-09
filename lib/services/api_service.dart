import 'package:http/http.dart' as http;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cqaag_app/services/connectivity_service.dart';

class ApiService {
  final http.Client _client = http.Client();
  final ConnectivityService _connectivityService;

  ApiService(this._connectivityService);

  Future<http.Response> get(String url) async {
    await _connectivityService.ensureConnected();
    final response = await _client.get(Uri.parse(url));
    _handleErrors(response);
    return response;
  }

  Future<http.Response> post(String url, {Object? body}) async {
    await _connectivityService.ensureConnected();
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

final apiServiceProvider = Provider<ApiService>((ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  return ApiService(connectivityService);
});
