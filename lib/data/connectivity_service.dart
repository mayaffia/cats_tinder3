import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionStatus => _connectionStatusController.stream;
  bool _isConnected = false;

  ConnectivityService() {
    _initConnectivity();

    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _initConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } catch (e) {
      _updateConnectionStatus(ConnectivityResult.none);
      return;
    }

    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    bool isConnected = result != ConnectivityResult.none;

    if (_isConnected != isConnected) {
      _isConnected = isConnected;
      _connectionStatusController.add(_isConnected);
    }
  }

  bool get isConnected => _isConnected;

  void setOffline() {
    if (_isConnected) {
      _isConnected = false;
      _connectionStatusController.add(false);
    }
  }

  void dispose() {
    _connectionStatusController.close();
  }
}
