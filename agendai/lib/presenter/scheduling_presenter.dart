import 'package:agendai/entity/scheduling.dart';
import 'package:agendai/model/agendai_api.dart';
import 'package:flutter/material.dart';

class SchedulingPresenter extends ChangeNotifier {
  final AgendaiApi api;
  bool loadingScheduling = false;
  List<Scheduling> scheduling = [];

  SchedulingPresenter({required this.api});

  Future<void> createScheduling({
    required int idService,
    required String date, // "2025-10-10"
    required String time, // "14:30:00"
    required String email,
    required String cpf,
    required String name,
    required String celPhone,
  }) async {
    loadingScheduling = true;
    notifyListeners();
    await api.registerScheduleWithNewClient(
      idService: idService,
      date: date,
      time: time,
      email: email,
      cpf: cpf,
      name: name,
      celPhone: celPhone,
    );
    loadingScheduling = false;
    notifyListeners();
  }

  Future<List<Scheduling>> getScheduling() async {
    loadingScheduling = true;
    notifyListeners();
    List<Scheduling> todos = await api.getScheduling();
    scheduling = todos;
    loadingScheduling = false;
    notifyListeners();
    return todos;
  }
}
