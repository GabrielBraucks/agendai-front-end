import 'package:agendai/entity/scheduling.dart';
import 'package:agendai/model/agendai_api.dart';
import 'package:flutter/material.dart';

class SchedulingPresenter extends ChangeNotifier {
  final AgendaiApi api;
  bool loadingScheduling = false;
  List<Scheduling> scheduling = [];

  SchedulingPresenter({required this.api});

  Future<void> createScheduling(
      {required int idService,
      required int idCliente,
      required int idFuncionario,
      required String date, // "2025-10-10"
      required String time // "14:30:00"
      }) async {
    loadingScheduling = true;
    notifyListeners();

    try {
      // Combina a data e a hora e converte para ISO 8601
      final isoDateTime =
          DateTime.parse('$date $time').toUtc().toIso8601String();

      await api.registerSchedule(
        idCliente: idCliente,
        idFuncionario: idFuncionario,
        idService: idService,
        date: isoDateTime.split('T')[0],
        time: isoDateTime.split('T')[1].substring(0, 8),
      );
      
      await getScheduling();
    } finally {
      loadingScheduling = false;
      notifyListeners();
    }
  }

  Future<void> deleteScheduling(int id) async {
    loadingScheduling = true;
    notifyListeners();

    try {
      final success = await api.deleteScheduling(id);
      if (success) {
        // Remove o agendamento da lista local para atualizar a UI
        scheduling.removeWhere((item) => item.id == id);
      }
    } finally {
      loadingScheduling = false;
      notifyListeners();
    }
  }

  Future<List<Scheduling>> getScheduling() async {
    loadingScheduling = true;
    notifyListeners();
    try {
      List<Scheduling> todos = await api.getScheduling();
      scheduling = todos;
      return todos;
    } finally {
      loadingScheduling = false;
      notifyListeners();
    }
  }
}
