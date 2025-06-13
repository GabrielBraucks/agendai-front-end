import 'package:agendai/entity/receipt.dart';
import 'package:agendai/model/agendai_api.dart';
import 'package:flutter/material.dart';

class ReceiptsPresenter extends ChangeNotifier {
  final AgendaiApi api;
  bool isLoading = false;
  List<Receipt> receipts = [];

  ReceiptsPresenter({required this.api});

  Future<void> getReceipts() async {
    isLoading = true;
    notifyListeners();
    try {
      receipts = await api.getReceipts();
    } catch (e) {
      print("Error fetching receipts: $e");
      receipts = [];
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
