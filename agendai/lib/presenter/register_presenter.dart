import 'package:agendai/model/agendai_api.dart';
import 'package:flutter/material.dart';

class RegisterPresenter extends ChangeNotifier {
  bool loadingRegister = false;
  final AgendaiApi api;

  RegisterPresenter({required this.api});

  Future<bool> register({
    required String employerIdentification,
    required String employername,
    required String email,
    required String password,
  }) async {
    loadingRegister = true;
    notifyListeners();
    bool teste = await api.register(
      employerIdentification: employerIdentification,
      employername: employername,
      email: email,
      password: password,
    );
    loadingRegister = false;
    notifyListeners();
    if (teste == true) {
      return true;
    } else {
      return false;
    }
  }
}
