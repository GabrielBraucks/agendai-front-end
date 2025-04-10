import 'package:agendai/model/agendai_api.dart';
import 'package:flutter/material.dart';

class ServicePresenter extends ChangeNotifier {
  final AgendaiApi api;

  ServicePresenter({required this.api});

  bool loadingService = false;

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
}
