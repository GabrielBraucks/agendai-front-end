import 'package:agendai/entity/customer.dart';
import 'package:agendai/model/agendai_api.dart';
import 'package:flutter/material.dart';

class CustomersPresenter extends ChangeNotifier {
  final AgendaiApi api;
  bool isLoading = false; // Changed from loadingCustomer for consistency
  List<Customer> internalCustomers = [];
  Customer? currentInternalCustomer;

  CustomersPresenter({required this.api});

  Future<void> createInternalCustomer({
    required String nome,
    required String cpf,
    required String email,
    required String telefone,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      await api.createInternalCustomer(
        nome: nome,
        cpf: cpf,
        email: email,
        telefone: telefone,
      );
      // Optionally, refresh the list of customers after creation
      await fetchInternalCustomers();
    } catch (e) {
      print("Error creating internal customer: $e");
      // Handle error appropriately in UI
      rethrow; // Or handle more gracefully
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchInternalCustomers() async {
    isLoading = true;
    notifyListeners();
    try {
      internalCustomers = await api.getInternalCustomers();
    } catch (e) {
      print("Error fetching internal customers: $e");
      internalCustomers = []; // Clear or handle error state
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> fetchOneInternalCustomer(int id) async {
    isLoading = true;
    currentInternalCustomer = null; // Clear previous one
    notifyListeners();
    try {
      currentInternalCustomer = await api.getOneInternalCustomer(id);
    } catch (e) {
      print("Error fetching one internal customer: $e");
      currentInternalCustomer = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateInternalCustomer(
    int id, {
    required String nome,
    required String cpf,
    required String email,
    required String telefone,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      await api.updateInternalCustomer(
        id,
        nome: nome,
        cpf: cpf,
        email: email,
        telefone: telefone,
      );
      // Optionally, refresh the list or the specific customer
      await fetchInternalCustomers(); // Or update the specific item in the list
      if (currentInternalCustomer?.id == id) {
          await fetchOneInternalCustomer(id); // Refresh current if it's the one being edited
      }
    } catch (e) {
      print("Error updating internal customer: $e");
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteInternalCustomer(int id) async {
    isLoading = true;
    notifyListeners();
    try {
      await api.deleteInternalCustomer(id);
      // Remove from local list or refetch
      internalCustomers.removeWhere((customer) => customer.id == id);
      if (currentInternalCustomer?.id == id) {
          currentInternalCustomer = null;
      }
    } catch (e) {
      print("Error deleting internal customer: $e");
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}