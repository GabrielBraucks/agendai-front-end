import 'package:agendai/entity/customer.dart';
import 'package:agendai/presenter/customer_presenter.dart';
import 'package:agendai/widgets/responsiveTable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Customers extends StatefulWidget {
  const Customers({super.key});

  @override
  State<Customers> createState() => _CustomersState();
}

class _CustomersState extends State<Customers> {
  List<int> _selectedCustomerIndices = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final presenter = Provider.of<CustomersPresenter>(context, listen: false);
      if (presenter.internalCustomers.isEmpty && !presenter.isLoading) {
        presenter.fetchInternalCustomers();
      }
    });
  }

  void _showAddCustomerDialog() {
    final nameController = TextEditingController();
    final cpfController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext dialogContext) {
        final presenter =
            Provider.of<CustomersPresenter>(dialogContext, listen: false);
        return AlertDialog(
          title: const Text('Adicionar Novo Cliente'),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                        labelText: 'Nome', border: OutlineInputBorder()),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Nome é obrigatório'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: cpfController,
                    decoration: const InputDecoration(
                        labelText: 'CPF', border: OutlineInputBorder()),
                    validator: (value) => value == null || value.isEmpty
                        ? 'CPF é obrigatório'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                          labelText: 'Email', border: OutlineInputBorder()),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Email é obrigatório';
                        if (!value.contains('@')) return 'Email inválido';
                        return null;
                      }),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                        labelText: 'Telefone', border: OutlineInputBorder()),
                    keyboardType: TextInputType.phone,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Telefone é obrigatório'
                        : null,
                  ),
                ],
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Adicionar'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(dialogContext).primaryColor,
                  foregroundColor: Colors.white),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await presenter.createInternalCustomer(
                      nome: nameController.text,
                      cpf: cpfController.text,
                      email: emailController.text,
                      telefone: phoneController.text,
                    );
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Cliente adicionado com sucesso!'),
                        backgroundColor: Colors.green));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text('Falha ao adicionar cliente: ${e.toString()}'),
                        backgroundColor: Colors.red));
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditCustomerDialog(Customer customerToEdit, int originalIndex) {
    final nameController = TextEditingController(text: customerToEdit.nome);
    final cpfController = TextEditingController(text: customerToEdit.cpf);
    final emailController = TextEditingController(text: customerToEdit.email);
    final phoneController =
        TextEditingController(text: customerToEdit.telefone);
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final presenter =
            Provider.of<CustomersPresenter>(dialogContext, listen: false);
        return AlertDialog(
          title: Text('Editar Cliente: ${customerToEdit.nome}'),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                        labelText: 'Nome', border: OutlineInputBorder()),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Nome é obrigatório'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: cpfController,
                    decoration: const InputDecoration(
                        labelText: 'CPF', border: OutlineInputBorder()),
                    validator: (value) => value == null || value.isEmpty
                        ? 'CPF é obrigatório'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                          labelText: 'Email', border: OutlineInputBorder()),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Email é obrigatório';
                        if (!value.contains('@')) return 'Email inválido';
                        return null;
                      }),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                        labelText: 'Telefone', border: OutlineInputBorder()),
                    keyboardType: TextInputType.phone,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Telefone é obrigatório'
                        : null,
                  ),
                ],
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.save_alt_outlined),
              label: const Text('Salvar Alterações'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(dialogContext).primaryColor,
                  foregroundColor: Colors.white),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    // Use the updateInternalCustomer method from the presenter
                    await presenter.updateInternalCustomer(
                      customerToEdit.id, // Pass the customer's ID
                      nome: nameController.text,
                      cpf: cpfController.text,
                      email: emailController.text,
                      telefone: phoneController.text,
                    );
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Cliente atualizado com sucesso!'),
                        backgroundColor: Colors.green));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text('Falha ao atualizar cliente: ${e.toString()}'),
                        backgroundColor: Colors.red));
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteDialog(
      BuildContext context, VoidCallback onDeleteConfirmed, String itemName,
      {bool multiple = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
              multiple ? 'Confirmar Exclusão Múltipla' : 'Confirmar Exclusão'),
          content: Text(multiple
              ? 'Tem certeza que deseja excluir os $itemName cliente(s) selecionado(s)?'
              : 'Tem certeza que deseja excluir o cliente "$itemName"?'),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.delete_forever_outlined),
              label: const Text('Excluir'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog first
                onDeleteConfirmed(); // Then execute delete
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteSelectedCustomers() {
    final presenter = Provider.of<CustomersPresenter>(context, listen: false);
    if (_selectedCustomerIndices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Nenhum cliente selecionado para excluir.')));
      return;
    }

    List<Customer> customersToDelete = _selectedCustomerIndices
        .map((index) {
          if (index < presenter.internalCustomers.length) {
            return presenter.internalCustomers[index];
          }
          return null;
        })
        .whereType<Customer>()
        .toList();

    if (customersToDelete.isEmpty && _selectedCustomerIndices.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Erro ao identificar clientes para exclusão.'),
          backgroundColor: Colors.red));
      return;
    }

    _confirmDeleteDialog(context, () async {
      bool allSucceeded = true;
      int successCount = 0;
      for (var customer in customersToDelete) {
        try {
          await presenter.deleteInternalCustomer(customer.id);
          successCount++;
        } catch (e) {
          allSucceeded = false;
          print("Failed to delete customer ${customer.id}: $e");
        }
      }
      setState(() {
        _selectedCustomerIndices = [];
      }); // Clear selection

      if (successCount > 0 && allSucceeded) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('$successCount cliente(s) excluído(s) com sucesso!'),
            backgroundColor: Colors.green));
      } else if (successCount > 0 && !allSucceeded) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('$successCount cliente(s) excluído(s). Alguns falharam.'),
            backgroundColor: Colors.orange));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Falha ao excluir cliente(s) selecionado(s).'),
            backgroundColor: Colors.red));
      }
    }, _selectedCustomerIndices.length.toString(), multiple: true);
  }

  @override
  Widget build(BuildContext context) {
    final List<String> tableHeaders = [
      'Nome',
      'CPF',
      'Email',
      'Telefone',
      'Status'
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Clientes',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A202C)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tabela de todos os seus clientes cadastrados da sua empresa',
                    style: TextStyle(fontSize: 15, color: Color(0xFF718096)),
                  ),
                  const SizedBox(height: 24),
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
                            onPressed: _selectedCustomerIndices.isNotEmpty
                                ? _deleteSelectedCustomers
                                : null,
                            style: ButtonStyle(
                              padding: WidgetStateProperty.all(
                                  const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12)),
                              elevation: WidgetStateProperty.all(0),
                              shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8))),
                              foregroundColor:
                                  WidgetStateProperty.resolveWith<Color?>(
                                (Set<WidgetState> states) {
                                  if (states.contains(WidgetState.disabled)) {
                                    return Colors.grey
                                        .shade500; // Cor do texto quando desabilitado
                                  }
                                  return Colors.red
                                      .shade700; // Cor do texto quando habilitado
                                },
                              ),
                              backgroundColor:
                                  WidgetStateProperty.resolveWith<Color?>(
                                (Set<WidgetState> states) {
                                  if (states.contains(WidgetState.disabled)) {
                                    return Colors.grey
                                        .shade200; // Cor de fundo quando desabilitado
                                  }
                                  return Colors.red
                                      .shade100; // Cor de fundo quando habilitado
                                },
                              ),
                              textStyle: WidgetStateProperty.all(
                                  const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.filter_list, size: 18),
                            label: const Text('Filtrar'),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Funcionalidade "Filtrar" não implementada.')));
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF4A5568),
                              side: BorderSide(color: Colors.grey.shade300),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              textStyle: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w500),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.download_outlined, size: 18),
                            label: const Text('Exportar'),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Funcionalidade "Exportar" não implementada.')));
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF4A5568),
                              side: BorderSide(color: Colors.grey.shade300),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              textStyle: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w500),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Adicionar Cliente'),
                        onPressed: _showAddCustomerDialog,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          textStyle: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Consumer<CustomersPresenter>(
                        builder: (context, presenter, child) {
                          if (presenter.isLoading &&
                              presenter.internalCustomers.isEmpty) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (!presenter.isLoading &&
                              presenter.internalCustomers.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.people_outline,
                                      size: 60, color: Colors.grey.shade400),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Nenhum cliente encontrado.',
                                    style: TextStyle(
                                        fontSize: 17, color: Color(0xFF718096)),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.add),
                                    label: const Text(
                                        'Adicionar Primeiro Cliente'),
                                    onPressed: _showAddCustomerDialog,
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                    ),
                                  )
                                ],
                              ),
                            );
                          }

                          final List<List<String>> tableData =
                              presenter.internalCustomers.map((customer) {
                            String status = customer.id % 3 == 0
                                ? 'Active'
                                : (customer.id % 3 == 1
                                    ? 'Inactive'
                                    : 'Pending');
                            return [
                              customer.nome,
                              customer.cpf,
                              customer.email,
                              customer.telefone,
                              'Active',
                            ];
                          }).toList();

                          return ResponsiveTable(
                            headers: tableHeaders,
                            data: tableData,
                            onSelectionChanged: (selectedIndices) {
                              setState(() {
                                _selectedCustomerIndices = selectedIndices;
                              });
                            },
                            onEdit: (rowIndex) {
                              if (rowIndex <
                                  presenter.internalCustomers.length) {
                                final customer =
                                    presenter.internalCustomers[rowIndex];
                                _showEditCustomerDialog(customer, rowIndex);
                              }
                            },
                            onDelete: (rowIndex) {
                              if (rowIndex <
                                  presenter.internalCustomers.length) {
                                final customer =
                                    presenter.internalCustomers[rowIndex];
                                _confirmDeleteDialog(context, () async {
                                  try {
                                    await presenter
                                        .deleteInternalCustomer(customer.id);
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content:
                                          Text('Cliente excluído com sucesso!'),
                                      backgroundColor: Colors.green,
                                    ));
                                  } catch (e) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(
                                          'Falha ao excluir cliente: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                    ));
                                  }
                                }, customer.nome);
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
}
