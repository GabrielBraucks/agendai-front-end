import 'package:agendai/presenter/receipts_presenter.dart';
import 'package:agendai/widgets/responsiveTable.dart';
import 'package:agendai/widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ReceiptsPage extends StatefulWidget {
  const ReceiptsPage({Key? key}) : super(key: key);

  @override
  _ReceiptsPageState createState() => _ReceiptsPageState();
}

class _ReceiptsPageState extends State<ReceiptsPage> {
  List<int> _selectedReceiptIndices = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final presenter = Provider.of<ReceiptsPresenter>(context, listen: false);
      if (presenter.receipts.isEmpty && !presenter.isLoading) {
        presenter.getReceipts();
      }
    });
  }
  
  String _formatDate(String dateStr) {
    try {
      final DateTime date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> tableHeaders = [
      'Cliente',
      'Serviço',
      'Data',
      'Pagamento',
      'Status',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: Row(
        children: [
          const Sidebar(selected: 'Recibos'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Recibos',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A202C))),
                  const SizedBox(height: 8),
                  const Text('Visualize todos os recibos de serviços prestados',
                      style:
                          TextStyle(fontSize: 15, color: Color(0xFF718096))),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Wrap(
                        spacing: 12.0,
                        runSpacing: 8.0,
                        children: [
                          OutlinedButton.icon(
                            icon: const Icon(Icons.filter_list, size: 18),
                            label: const Text('Filtrar'),
                            onPressed: () => ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                                    content: Text('Filtrar não implementado.'))),
                            style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF4A5568),
                                side: BorderSide(color: Colors.grey.shade300),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                textStyle: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w500),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8))),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey.shade300, width: 1)),
                      clipBehavior: Clip.antiAlias,
                      child: Consumer<ReceiptsPresenter>(
                        builder: (context, presenter, child) {
                          if (presenter.isLoading &&
                              presenter.receipts.isEmpty) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (!presenter.isLoading &&
                              presenter.receipts.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.receipt_long_outlined,
                                      size: 60, color: Colors.grey.shade400),
                                  const SizedBox(height: 16),
                                  const Text('Nenhum recibo encontrado.',
                                      style: TextStyle(
                                          fontSize: 17,
                                          color: Color(0xFF718096))),
                                ],
                              ),
                            );
                          }

                          final List<List<String>> tableData =
                              presenter.receipts.map((receipt) {
                            return [
                              receipt.nomeCliente,
                              receipt.nomeServico,
                              _formatDate(receipt.data),
                              receipt.pagamentoPrestacao,
                              receipt.statusPrestacao,
                            ];
                          }).toList();

                          return ResponsiveTable(
                            headers: tableHeaders,
                            data: tableData,
                            onSelectionChanged: (selectedIndices) {
                              setState(() {
                                _selectedReceiptIndices = selectedIndices;
                              });
                            },
                            onEdit: (rowIndex) {
                              // Implementar edição se necessário
                            },
                            onDelete: (rowIndex) {
                              // Implementar exclusão se necessário
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
