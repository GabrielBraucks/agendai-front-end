import 'package:agendai/entity/employee.dart';
import 'package:agendai/model/agendai_api.dart';
import 'package:flutter/material.dart';

class EmployeesPresenter extends ChangeNotifier {
  bool loadingPage = false;
  final AgendaiApi api;
  List<Employee> funcionarios = [];
  Employee? selected;

  EmployeesPresenter({required this.api});

  // Listar funcionários
  Future<List<Employee>> getEmployees() async {
    loadingPage = true;
    notifyListeners();
    List<Employee> todos = await api.getEmployees();
    funcionarios = todos;
    loadingPage = false;
    notifyListeners();
    return todos;
  }

  // Atualizar funcionário
  Future updateEmployee({
    required int id,
    required String nome,
    required String cpf,
    required String cargo,
    required String email,
    required String telefone,
    required String dataNasc,
  }) async {
    loadingPage = true;
    notifyListeners();
    await api.updateEmployee(
      id: id,
      name: nome,
      cpf: cpf,
      jobTitle: cargo,
      email: email,
      celPhone: telefone,
      birthday: dataNasc,
    );
    await getEmployees();
    loadingPage = false;
    notifyListeners();
  }

  // Deletar funcionário
  Future deleteEmployee(int id) async {
    loadingPage = true;
    notifyListeners();
    await api.deleteEmployee(id: id);
    await getEmployees();
    loadingPage = false;
    notifyListeners();
  }

  // Future<void> logout() async {
  //   await api.deleteToken();
  // }

  // Future deleteServicos(int id) async {
  //   loadingPage = true;
  //   notifyListeners();
  //   await api.deleteService(id);
  //   await getEmployees();
  // }

  // Pegar funcionário por id
  Future<Employee> idEmployee(int id) async {
    loadingPage = true;
    notifyListeners();
    Employee funcionario = await api.getIdEmployee(id);
    selected = funcionario;
    loadingPage = false;
    notifyListeners();
    return funcionario;
  }
}
