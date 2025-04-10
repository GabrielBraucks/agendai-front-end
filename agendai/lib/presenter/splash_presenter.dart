import 'package:agendai/model/agendai_api.dart';
import 'package:flutter/material.dart';

class SplashPresenter extends ChangeNotifier {
  bool loadingLogin = false;
  String? jwtToken;
  final AgendaiApi api;

  SplashPresenter({required this.api});

  Future<bool> checkAuth() async {
    loadingLogin = true;
    notifyListeners();
    String? teste = await api.getToken();
    loadingLogin = false;
    notifyListeners();
    if (teste != null) {
      jwtToken = teste;
      return true;
    } else {
      return false;
    }
  }

  //recuperar token do dispositivo
  Future<String?> getToken() async {
    return await api.getToken();
  }
}
