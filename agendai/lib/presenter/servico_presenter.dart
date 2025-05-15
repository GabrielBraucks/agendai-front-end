import 'package:agendai/entity/service.dart';
import 'package:agendai/model/agendai_api.dart';
import 'package:flutter/material.dart';

class ServicePresenter extends ChangeNotifier {
  final AgendaiApi api;
  bool loadingService = false;
  List<Servico> servicos = [];

  ServicePresenter({required this.api});

  Future<void> createService({
    required String name,
    required int value,
    required String duration,
    required String category,
  }) async {
    loadingService = true;
    notifyListeners();
    await api.createService(
      name: name,
      value: value,
      duration: duration,
      category: category,
    );
    loadingService = false;
    notifyListeners();
  }

  Future<List<Servico>> getServicos() async {
    loadingService = true;
    notifyListeners();
    List<Servico> todos = await api.getServices();
    servicos = todos;
    loadingService = false;
    notifyListeners();
    return todos;
  }

  Future deleteServicos(int id) async {
    loadingService = true;
    notifyListeners();
    await api.deleteService(id);
    await getServicos();
  }
}
