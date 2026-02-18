import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// ConnectivityService provides network status checking
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  /// Check if device is currently online
  Future<bool> get isOnline async {
    final results = await _connectivity.checkConnectivity();

    // Handle both single result and list result based on version
    final List<ConnectivityResult> resultList = results is List
        ? results as List<ConnectivityResult>
        : [results as ConnectivityResult];

    // Consider WiFi, Ethernet, VPN, and Bluetooth as online
    // Mobile and None as offline (for desktop, mainly None matters)
    for (final result in resultList) {
      if (result != ConnectivityResult.none) {
        return true;
      }
    }

    return false;
  }

  /// Stream of connectivity changes
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((results) {
      final List<ConnectivityResult> resultList = results is List
          ? results as List<ConnectivityResult>
          : [results as ConnectivityResult];

      return resultList.any((r) => r != ConnectivityResult.none);
    });
  }
}
