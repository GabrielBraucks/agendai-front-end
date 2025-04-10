import 'package:agendai/entity/employee.dart';
import 'package:agendai/model/agendai_api.dart';
import 'package:flutter/material.dart';

class EmployeesPresenter extends ChangeNotifier {
  bool loadingHome = false;
  final AgendaiApi api;
  List<Employee> funcionarios = [];
  Employee? selected;

  EmployeesPresenter({required this.api});
  Future<List<Employee>> getEmployees() async {
    loadingHome = true;
    notifyListeners();
    List<Employee> todos = await api.getEmployees();
    funcionarios = todos;
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
    await getEmployees();
  }

  Future<Employee> idEmployee(int id) async {
    loadingHome = true;
    notifyListeners();
    Employee funcionario = await api.getIdEmployee(id);
    selected = funcionario;
    loadingHome = false;
    notifyListeners();
    return funcionario;
  }
}
