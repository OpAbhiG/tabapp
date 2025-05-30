
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityProvider with ChangeNotifier {
  bool _isConnected = true;
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  bool get isConnected => _isConnected;

  ConnectivityProvider() {
    _initialize();
  }

  void _initialize() {
    _subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      final hasConnection = results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi);

      if (_isConnected != hasConnection) {
        _isConnected = hasConnection;
        notifyListeners();
      }
    });
  }

  void disposeStream() {
    _subscription.cancel();
  }
}



