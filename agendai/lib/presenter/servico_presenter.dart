import 'package:agendai/entity/service.dart';
import 'package:agendai/model/agendai_api.dart';
import 'package:flutter/material.dart';

class ServicePresenter extends ChangeNotifier {
  final AgendaiApi api;
  bool loadingService = false;
  List<Servico> servicos = [];

  ServicePresenter({required this.api});

  Future<void> createServico({
    required String nome,
    required double preco,
    required String duracao,
    required String categoria,
  }) async {
    loadingService = true;
    notifyListeners();
    try {
      await api.createService(
        name: nome,
        preco: preco,
        duracao: duracao,
        category: categoria,
      );
      await getServicos(); // Recarrega a lista após a criação
    } catch (e) {
      print("Erro ao criar serviço: $e");
      rethrow;
    } finally {
      loadingService = false;
      notifyListeners();
    }
  }

  Future<void> getServicos() async {
    loadingService = true;
    notifyListeners();
    try {
      servicos = await api.getServices();
    } catch (e) {
      print("Erro ao buscar serviços: $e");
      servicos = []; // Limpa a lista em caso de erro
      rethrow;
    } finally {
      loadingService = false;
      notifyListeners();
    }
  }

  Future<void> updateServico({
    required int id,
    required String nome,
    required double preco,
    required String duracao,
    required String categoria,
  }) async {
    loadingService = true;
    notifyListeners();
    try {
      await api.updateService(
        id: id,
        nome: nome,
        preco: preco,
        duracao: duracao,
        categoria: categoria,
      );
      await getServicos(); // Recarrega a lista após a atualização
    } catch (e) {
      print("Erro ao atualizar serviço: $e");
      rethrow;
    } finally {
      loadingService = false;
      notifyListeners();
    }
  }

  Future<void> deleteServicos(int id) async {
    loadingService = true;
    notifyListeners();
    try {
      await api.deleteService(id);
      // Remove o item localmente para uma UI mais responsiva
      servicos.removeWhere((servico) => servico.id == id);
    } catch (e) {
      print("Erro ao deletar serviço: $e");
      rethrow;
    } finally {
      loadingService = false;
      notifyListeners();
    }
  }
}
