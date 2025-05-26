import 'package:agendai/entity/employee.dart';
import 'package:agendai/model/agendai_api.dart';
import 'package:flutter/material.dart';

class EmployeesPresenter extends ChangeNotifier {
  bool isLoading = false; // Renamed from loadingPage for consistency
  final AgendaiApi api;
  List<Employee> funcionarios = [];
  Employee? selectedEmployee; // Renamed from selected for clarity

  EmployeesPresenter({required this.api});

  Future<void> createEmployee({
    required String name,
    required String cpf,
    required String jobTitle,
    required String email,
    required String celPhone,
    required String password,
    required String birthday,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      await api.createEmployee(
        name: name,
        cpf: cpf,
        jobTitle: jobTitle,
        email: email,
        celPhone: celPhone,
        password: password,
        birthday: birthday,
      );
      // Refresh the list of employees after creation
      await getEmployees();
    } catch (e) {
      print("Error creating employee: $e");
      // Rethrow to allow UI to handle specific error messages if needed
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Listar funcionários
  Future<void> getEmployees() async {
    isLoading = true;
    notifyListeners();
    try {
      List<Employee> todos = await api.getEmployees();
      funcionarios = todos;
    } catch (e) {
      print("Error fetching employees: $e");
      funcionarios = []; // Clear list on error or handle appropriately
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Atualizar funcionário
  Future<void> updateEmployee({
    required int id,
    required String name, // Changed from nome
    required String cpf,
    required String jobTitle, // Changed from cargo
    required String email,
    required String celPhone, // Changed from telefone
    required String birthday, // Changed from dataNasc
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      await api.updateEmployee(
        id: id,
        name: name,
        cpf: cpf,
        jobTitle: jobTitle,
        email: email,
        celPhone: celPhone,
        birthday: birthday,
      );
      // Refresh the list and potentially the selected employee details
      await getEmployees();
      if (selectedEmployee?.id == id) {
        // If the updated employee was the selected one, refresh its details
        // This might require fetching it individually if getEmployees doesn't return full details
        // or if you want to ensure the 'selectedEmployee' instance is updated.
        // For simplicity, we assume getEmployees() is sufficient or handle selection update in UI.
        // Alternatively: await getEmployeeById(id);
      }
    } catch (e) {
      print("Error updating employee: $e");
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Deletar funcionário
  Future<void> deleteEmployee({required int id}) async { // Added named parameter for clarity
    isLoading = true;
    notifyListeners();
    try {
      await api.deleteEmployee(id: id); // Assuming api.deleteEmployee expects a named 'id'
      // Remove from local list or refetch
      funcionarios.removeWhere((employee) => employee.id == id);
      if (selectedEmployee?.id == id) {
        selectedEmployee = null;
      }
      // Or simply call: await getEmployees(); if a full refresh is preferred
    } catch (e) {
      print("Error deleting employee: $e");
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Pegar funcionário por id e definir como selecionado
  Future<void> getEmployeeById(int id) async { // Renamed from idEmployee for clarity
    isLoading = true;
    selectedEmployee = null; // Clear previous
    notifyListeners();
    try {
      Employee funcionario = await api.getIdEmployee(id); // Assuming this method exists
      selectedEmployee = funcionario;
    } catch (e) {
      print("Error fetching employee by ID: $e");
      selectedEmployee = null;
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Clear selected employee
  void clearSelectedEmployee() {
    selectedEmployee = null;
    notifyListeners();
  }

  // Logout (if needed, ensure AgendaiApi has deleteToken)
  // Future<void> logout() async {
  //   isLoading = true;
  //   notifyListeners();
  //   try {
  //     await api.deleteToken(); // Make sure this method exists in AgendaiApi
  //     funcionarios = [];
  //     selectedEmployee = null;
  //   } catch (e) {
  //     print("Error during logout: $e");
  //   } finally {
  //     isLoading = false;
  //     notifyListeners();
  //   }
  // }
}
