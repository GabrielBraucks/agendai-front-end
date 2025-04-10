import 'package:agendai/model/agendai_api.dart';
import 'package:flutter/material.dart';

class LoginPresenter extends ChangeNotifier {
  bool loadingLogin = false;
  String? errorMessage;
  final AgendaiApi api;

  LoginPresenter({required this.api});

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    loadingLogin = true;
    errorMessage = null;
    notifyListeners();
    final result = await api.login(
      identifier: username,
      password: password,
    );
    loadingLogin = false;
    notifyListeners();
    if (result.isEmpty) {
      errorMessage = 'E-mail ou senha inválidos';
      notifyListeners();
      return false;
    }
    final token = result[0];
    final id = result[1];
    updateTokenAndId(token, id);
    notifyListeners();
    return true;
  }

  void updateTokenAndId(String? newToken, int? id) {
    api.saveTokenAndId(newToken!, id!);
  }
}
