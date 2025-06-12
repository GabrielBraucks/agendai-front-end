import 'package:agendai/model/agendai_api.dart';
import 'package:flutter/material.dart';

class ConnectPresenter extends ChangeNotifier {
  final AgendaiApi api;
  bool _isLoading = false;

  // A map to hold the connection status of various services
  final Map<String, bool> _connectionStatus = {
    'google': false, // Initial status
  };

  ConnectPresenter({required this.api});

  // Getters to expose state to the UI
  bool get isLoading => _isLoading;
  Map<String, bool> get connectionStatus => _connectionStatus;

  /// Initiates the connection to Google by calling the API method.
  Future<void> connectToGoogle() async {
    _isLoading = true;
    notifyListeners();
    try {
      await api.launchGoogleAuth();
      // NOTE: This is an optimistic update. The app doesn't know the definite outcome of the web flow.
      // A more robust solution involves polling a status endpoint or using deep linking (custom URL schemes).
      _connectionStatus['google'] = true;
    } catch (e) {
      // Re-throw the exception to be caught by the UI
      _connectionStatus['google'] = false;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Disconnects from Google.
  Future<void> disconnectFromGoogle() async {
    _isLoading = true;
    notifyListeners();
    // In a real app, you would call an API endpoint to invalidate the token on the server.
    // For example: await api.disconnectFromGoogle();
    
    // Simulating a delay for the disconnect operation
    await Future.delayed(const Duration(milliseconds: 500));
    
    _connectionStatus['google'] = false;
    _isLoading = false;
    notifyListeners();
  }

  /// In a real application, you would fetch the initial connection status from your backend.
  /// This is a placeholder for that logic.
  Future<void> fetchConnectionStatus() async {
      _isLoading = true;
      notifyListeners();
      try {
        // Example: status = await api.getGoogleConnectionStatus();
        // For now, we just simulate a fetch.
        await Future.delayed(const Duration(seconds: 1));
        // _connectionStatus['google'] = fetchedStatus;
      } catch (e) {
        // Handle error
      } finally {
        _isLoading = false;
        notifyListeners();
      }
  }
}
