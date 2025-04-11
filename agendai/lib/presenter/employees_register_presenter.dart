import 'package:agendai/entity/employee.dart';
import 'package:agendai/model/agendai_api.dart';
import 'package:flutter/material.dart';

class EmployeesRegisterPresenter extends ChangeNotifier {
  bool loadingPage = false;
  final AgendaiApi api;
  List<Employee> funcionarios = [];
  Employee? selected;

  EmployeesRegisterPresenter({required this.api});

  Future<void> registerEmployee({
    required String name,
    required String cpf,
    required String jobTitle,
    required String email,
    required String celPhone,
    required String password,
    required String birthday,
  }) async {
    loadingPage = true;
    notifyListeners();
    await api.createEmployee(
      name: name,
      cpf: cpf,
      jobTitle: jobTitle,
      email: email,
      celPhone: celPhone,
      password: password,
      birthday: birthday,
    );
    loadingPage = false;
    notifyListeners();
  }
}
