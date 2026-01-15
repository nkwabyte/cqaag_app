import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_service.g.dart';

/// Custom exception for no internet connection
class NoInternetException implements Exception {
  final String message;

  NoInternetException([this.message = 'No internet connection']);

  @override
  String toString() => message;
}

/// Service to check and monitor internet connectivity
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  /// Stream of connectivity status changes
  Stream<List<ConnectivityResult>> get connectivityStream => _connectivity.onConnectivityChanged;

  /// Check current connectivity status
  Future<List<ConnectivityResult>> checkConnectivity() async {
    return await _connectivity.checkConnectivity();
  }

  /// Check if device is connected to any network
  Future<bool> isConnected() async {
    final connectivityResult = await checkConnectivity();
    return connectivityResult.isNotEmpty && !connectivityResult.contains(ConnectivityResult.none);
  }

  /// Check if device has actual internet access (not just network connection)
  /// This performs a real internet check by attempting to lookup a host
  Future<bool> hasInternetAccess() async {
    // First check if connected to a network
    if (!await isConnected()) {
      return false;
    }

    // Then check if we can actually reach the internet
    try {
      final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Verify internet connection and throw exception if not available
  Future<void> ensureConnected() async {
    if (!await hasInternetAccess()) {
      throw NoInternetException(
        'No internet connection. Please check your network settings.',
      );
    }
  }
}

/// Provider for ConnectivityService
@Riverpod(keepAlive: true)
ConnectivityService connectivityService(Ref ref) {
  return ConnectivityService();
}

/// Provider for connectivity status stream
@riverpod
Stream<List<ConnectivityResult>> connectivityStatus(
  Ref ref,
) {
  return ref.watch(connectivityServiceProvider).connectivityStream;
}

/// Provider to check if currently connected
@riverpod
Future<bool> isConnected(Ref ref) {
  return ref.watch(connectivityServiceProvider).isConnected();
}

/// Provider to check if has internet access
@riverpod
Future<bool> hasInternetAccess(Ref ref) {
  return ref.watch(connectivityServiceProvider).hasInternetAccess();
}
