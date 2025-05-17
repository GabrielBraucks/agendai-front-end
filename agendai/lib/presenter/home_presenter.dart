import 'package:agendai/model/agendai_api.dart';
import 'package:flutter/material.dart';

class HomePresenter extends ChangeNotifier {
  bool loadingHome = false;
  // String? name;
  // String? email;
  // String? cnpj;
  final AgendaiApi api;

  HomePresenter({required this.api});

  Future<void> logout() async {
    await api.deleteToken();
  }
}
