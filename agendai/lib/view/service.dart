import 'package:agendai/entity/service.dart' as entity;
import 'package:agendai/presenter/servico_presenter.dart';
import 'package:agendai/widgets/responsiveTable.dart';
import 'package:agendai/widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Service extends StatefulWidget {
  const Service({super.key});

  @override
  State<Service> createState() => _ServiceState();
}

class _ServiceState extends State<Service> {
  List<int> _selectedServiceIndices = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final presenter = Provider.of<ServicePresenter>(context, listen: false);
      if (presenter.servicos.isEmpty && !presenter.loadingService) {
        presenter.getServicos();
      }
    });
  }

  // --- MODAL DIALOGS ---

  void _showAddServiceDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final categoryController = TextEditingController();
    final durationController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final presenter = Provider.of<ServicePresenter>(dialogContext, listen: false);
        return AlertDialog(
          title: const Text('Adicionar Novo Serviço'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(controller: nameController, decoration: const InputDecoration(labelText: 'Nome do Serviço', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Nome é obrigatório' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: priceController, decoration: const InputDecoration(labelText: 'Preço (Ex: 50.00)', border: OutlineInputBorder()), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Preço é obrigatório' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: categoryController, decoration: const InputDecoration(labelText: 'Categoria', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Categoria é obrigatória' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: durationController, decoration: const InputDecoration(labelText: 'Duração (minutos)', border: OutlineInputBorder()), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Duração é obrigatória' : null),
                ],
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.of(dialogContext).pop()),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Adicionar'),
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(dialogContext).primaryColor, foregroundColor: Colors.white),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await presenter.createServico(
                      nome: nameController.text,
                      preco: double.parse(priceController.text),
                      categoria: categoryController.text,
                      duracao: durationController.text,
                    );
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Serviço adicionado!'), backgroundColor: Colors.green));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Falha: ${e.toString()}'), backgroundColor: Colors.red));
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditServiceDialog(entity.Servico serviceToEdit) {
    final nameController = TextEditingController(text: serviceToEdit.nome);
    final priceController = TextEditingController(text: serviceToEdit.preco.toString());
    final categoryController = TextEditingController(text: serviceToEdit.categoria);
    final durationController = TextEditingController(text: serviceToEdit.duracao.toString());
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final presenter = Provider.of<ServicePresenter>(dialogContext, listen: false);
        return AlertDialog(
          title: Text('Editar Serviço: ${serviceToEdit.nome}'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(controller: nameController, decoration: const InputDecoration(labelText: 'Nome do Serviço', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Nome é obrigatório' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: priceController, decoration: const InputDecoration(labelText: 'Preço', border: OutlineInputBorder()), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Preço é obrigatório' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: categoryController, decoration: const InputDecoration(labelText: 'Categoria', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Categoria é obrigatória' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: durationController, decoration: const InputDecoration(labelText: 'Duração (minutos)', border: OutlineInputBorder()), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Duração é obrigatória' : null),
                ],
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.of(dialogContext).pop()),
            ElevatedButton.icon(
              icon: const Icon(Icons.save_alt_outlined),
              label: const Text('Salvar Alterações'),
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(dialogContext).primaryColor, foregroundColor: Colors.white),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await presenter.updateServico(
                      id: serviceToEdit.id,
                      nome: nameController.text,
                      preco: double.parse(priceController.text),
                      categoria: categoryController.text,
                      duracao: durationController.text,
                    );
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Serviço atualizado!'), backgroundColor: Colors.green));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Falha: ${e.toString()}'), backgroundColor: Colors.red));
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteDialog(BuildContext context, VoidCallback onDeleteConfirmed, String itemName, {bool multiple = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(multiple ? 'Confirmar Exclusão Múltipla' : 'Confirmar Exclusão'),
          content: Text(multiple ? 'Tem certeza que deseja excluir os $itemName serviço(s) selecionado(s)?' : 'Tem certeza que deseja excluir o serviço "$itemName"?'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.of(dialogContext).pop()),
            ElevatedButton.icon(
              icon: const Icon(Icons.delete_forever_outlined),
              label: const Text('Excluir'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onDeleteConfirmed();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteSelectedServices() {
    final presenter = Provider.of<ServicePresenter>(context, listen: false);
    if (_selectedServiceIndices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nenhum serviço selecionado.')));
      return;
    }

    List<entity.Servico> servicesToDelete = _selectedServiceIndices.map((index) {
      if (index < presenter.servicos.length) return presenter.servicos[index];
      return null;
    }).whereType<entity.Servico>().toList();

    if (servicesToDelete.isEmpty && _selectedServiceIndices.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao identificar serviços.'), backgroundColor: Colors.red));
      return;
    }

    _confirmDeleteDialog(
      context,
      () async {
        int successCount = 0;
        List<String> failedServices = [];
        for (var service in servicesToDelete) {
          try {
            await presenter.deleteServicos(service.id);
            successCount++;
          } catch (e) {
            failedServices.add(service.nome);
            print("Falha ao excluir serviço ${service.id}: $e");
          }
        }
        setState(() {
          _selectedServiceIndices = [];
        });

        if (successCount > 0) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$successCount serviço(s) excluído(s)!'), backgroundColor: Colors.green));
        }
        if (failedServices.isNotEmpty) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Falha ao excluir: ${failedServices.join(", ")}'), backgroundColor: Colors.red));
        }
       
      },
      _selectedServiceIndices.length.toString(),
      multiple: true,
    );
  }

  // --- BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    final List<String> tableHeaders = ['Nome', 'Categoria', 'Duração (min)', 'Preço (R\$)'];

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: Row(
        children: [
          const Sidebar(selected: 'Serviços'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page Header
                  const Text('Serviços', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A202C))),
                  const SizedBox(height: 8),
                  const Text('Tabela de todos os seus serviços cadastrados', style: TextStyle(fontSize: 15, color: Color(0xFF718096))),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Wrap(
                        spacing: 12.0,
                        runSpacing: 8.0,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: const Text('Excluir'),
                            onPressed: _selectedServiceIndices.isNotEmpty ? _deleteSelectedServices : null,
                            style: ButtonStyle(
                              padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                              elevation: MaterialStateProperty.all(0),
                              shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                              foregroundColor: MaterialStateProperty.resolveWith<Color?>((states) => states.contains(MaterialState.disabled) ? Colors.grey.shade500 : Colors.red.shade700),
                              backgroundColor: MaterialStateProperty.resolveWith<Color?>((states) => states.contains(MaterialState.disabled) ? Colors.grey.shade200 : Colors.red.shade100),
                              textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            ),
                          ),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.filter_list, size: 18),
                            label: const Text('Filtrar'),
                            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Filtrar não implementado.'))),
                             style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF4A5568), side: BorderSide(color: Colors.grey.shade300), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Adicionar Serviço'),
                        onPressed: _showAddServiceDialog,
                        style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Theme.of(context).primaryColor, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Table
                  Expanded(
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade300, width: 1)),
                      clipBehavior: Clip.antiAlias,
                      child: Consumer<ServicePresenter>(
                        builder: (context, presenter, child) {
                          if (presenter.loadingService && presenter.servicos.isEmpty) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (!presenter.loadingService && presenter.servicos.isEmpty) {
                             return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.design_services_outlined, size: 60, color: Colors.grey.shade400),
                                  const SizedBox(height: 16),
                                  const Text('Nenhum serviço encontrado.', style: TextStyle(fontSize: 17, color: Color(0xFF718096))),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(icon: const Icon(Icons.add), label: const Text('Adicionar Serviço'), onPressed: _showAddServiceDialog, style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Theme.of(context).primaryColor))
                                ],
                              ),
                            );
                          }

                          final List<List<String>> tableData = presenter.servicos.map((service) {
                            return [
                              service.nome,
                              service.categoria,
                              _formatTime(int.parse(service.duracao)),
                              'R\$ ${service.preco.toStringAsFixed(2)}',
                            ];
                          }).toList();

                          return ResponsiveTable(
                            headers: tableHeaders,
                            data: tableData,
                            onSelectionChanged: (selectedIndices) {
                              setState(() {
                                _selectedServiceIndices = selectedIndices;
                              });
                            },
                            onEdit: (rowIndex) {
                              if (rowIndex < presenter.servicos.length) {
                                _showEditServiceDialog(presenter.servicos[rowIndex]);
                              }
                            },
                            onDelete: (rowIndex) {
                              if (rowIndex < presenter.servicos.length) {
                                final service = presenter.servicos[rowIndex];
                                _confirmDeleteDialog(context, () async {
                                  try {
                                    await presenter.deleteServicos(service.id);
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Serviço excluído!'), backgroundColor: Colors.green));
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Falha ao excluir: ${e.toString()}'), backgroundColor: Colors.red));
                                  }
                                }, service.nome);
                              }
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

  String _formatTime(int minutosTotais) {
  final horas = minutosTotais ~/ 60;
  final minutos = minutosTotais % 60;

  String parteHoras = '';
  String parteMinutos = '';

  if (horas > 0) {
    parteHoras = '$horas ${horas == 1 ? 'hora' : 'horas'}';
  }

  if (minutos > 0) {
    parteMinutos = '$minutos ${minutos == 1 ? 'minuto' : 'minutos'}';
  }

  if (horas > 0 && minutos > 0) {
    return '$parteHoras e $parteMinutos';
  } else if (horas > 0) {
    return parteHoras;
  } else {
    return parteMinutos;
  }
}
}
