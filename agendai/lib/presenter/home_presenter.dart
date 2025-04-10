import 'package:agendai/entity/service.dart';
import 'package:agendai/model/agendai_api.dart';
import 'package:flutter/material.dart';

class HomePresenter extends ChangeNotifier {
  bool loadingHome = false;
  final AgendaiApi api;
  List<Servico> servicos = [];

  HomePresenter({required this.api});
  Future<List<Servico>> getServicos() async {
    loadingHome = true;
    notifyListeners();
    List<Servico> todos = await api.getServices();
    servicos = todos;
    loadingHome = false;
    notifyListeners();
    return todos;
  }

  Future<void> logout() async {
    await api.deleteToken();
  }

  Future deleteServicos(int id) async {
    loadingHome = true;
    notifyListeners();
    await api.deleteService(id);
    await getServicos();
  }
}
