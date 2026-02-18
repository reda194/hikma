import 'package:connectivity_plus/connectivity_plus.dart';

/// ConnectivityService provides network status checking
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  /// Check if device is currently online
  Future<bool> get isOnline async {
    final List<ConnectivityResult> results =
        await _connectivity.checkConnectivity();

    // Consider WiFi, Ethernet, VPN, and Bluetooth as online
    // Mobile and None as offline (for desktop, mainly None matters)
    for (final result in results) {
      if (result != ConnectivityResult.none) {
        return true;
      }
    }

    return false;
  }

  /// Stream of connectivity changes
  Stream<bool> get onConnectivityChanged async* {
    await for (final List<ConnectivityResult> results
        in _connectivity.onConnectivityChanged) {
      final isOnline = results.any((r) => r != ConnectivityResult.none);
      yield isOnline;
    }
  }
}
