import 'package:agendai/entity/customer.dart';
import 'package:agendai/model/agendai_api.dart'; // Assuming Customer is here or re-exported
import 'package:agendai/presenter/customer_presenter.dart';
import 'package:agendai/widgets/responsiveTable.dart';
import 'package:agendai/widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Assuming Customer entity is defined in customer.dart and imported by agendai_api.dart or directly
// If not, ensure you have: import 'package:agendai/entity/customer.dart';

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
      // Check if customers are already loaded to avoid redundant calls if screen is revisited
      if (presenter.internalCustomers.isEmpty) {
        presenter.fetchInternalCustomers();
      }
    });
  }

  void _showAddCustomerDialog() {
    final nameController = TextEditingController();
    final cpfController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    // It's good practice to get the presenter instance inside the builder or method
    // if context might change, but for a dialog triggered from the current screen, this is okay.
    // However, to be safer with async gaps, it's better to pass it or get it fresh.
    // final presenter = Provider.of<CustomersPresenter>(context, listen: false); // Already have it

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) { // Use dialogContext for clarity
        // Get presenter here to ensure it's from the correct context if dialog rebuilds
        final presenter = Provider.of<CustomersPresenter>(dialogContext, listen: false);
        return AlertDialog(
          title: const Text('Adicionar Novo Cliente'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nome')),
                TextField(controller: cpfController, decoration: const InputDecoration(labelText: 'CPF')),
                TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
                TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Telefone')),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Adicionar'),
              onPressed: () async { // Make async for API call
                if (nameController.text.isNotEmpty &&
                    cpfController.text.isNotEmpty &&
                    emailController.text.isNotEmpty &&
                    phoneController.text.isNotEmpty) {
                  try {
                    await presenter.createInternalCustomer(
                      nome: nameController.text,
                      cpf: cpfController.text,
                      email: emailController.text,
                      telefone: phoneController.text,
                    );
                    Navigator.of(dialogContext).pop();
                    // Optionally, show a success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cliente adicionado com sucesso!'), backgroundColor: Colors.green,)
                    );
                  } catch (e) {
                     ScaffoldMessenger.of(dialogContext).showSnackBar( // Use dialogContext for SnackBar if dialog is still visible
                      SnackBar(content: Text('Falha ao adicionar cliente: $e'), backgroundColor: Colors.red,)
                    );
                  }
                } else {
                   ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Por favor, preencha todos os campos.'), backgroundColor: Colors.orange,)
                  );
                }
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum cliente selecionado para excluir.'))
      );
      return;
    }
    
    // Get actual customer IDs to delete.
    // It's crucial that _selectedCustomerIndices correspond to the current order in presenter.internalCustomers
    List<Customer> customersToDelete = _selectedCustomerIndices.map((index) {
      // Add bounds check for safety, though ideally the indices should always be valid
      if (index < presenter.internalCustomers.length) {
        return presenter.internalCustomers[index];
      }
      return null; // Should not happen in a well-synced UI
    }).whereType<Customer>().toList(); // Filter out any nulls if error occurred

    if (customersToDelete.isEmpty && _selectedCustomerIndices.isNotEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao identificar clientes para exclusão.'), backgroundColor: Colors.red)
      );
      return;
    }


    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir ${_selectedCustomerIndices.length} cliente(s) selecionado(s)?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
                bool allSucceeded = true;
                for (var customer in customersToDelete) {
                  try {
                    await presenter.deleteInternalCustomer(customer.id); 
                  } catch (e) {
                    allSucceeded = false;
                    print("Failed to delete customer ${customer.id}: $e");
                    // Optionally show error for specific customer
                  }
                }
                // Clear selection regardless of individual failures, presenter will update list
                setState(() {
                  _selectedCustomerIndices = []; 
                });
                Navigator.of(dialogContext).pop();
                if (allSucceeded) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cliente(s) excluído(s) com sucesso!'), backgroundColor: Colors.green,)
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Alguns clientes não puderam ser excluídos.'), backgroundColor: Colors.orange,)
                  );
                }
            }, 
            child: const Text('Excluir')
          ),
        ],
      )
    );
  }


  @override
  Widget build(BuildContext context) {
    final List<String> tableHeaders = ['Nome', 'CPF', 'Email', 'Telefone', 'Status'];

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC), 
      body: Row(
        children: [
          const Sidebar(selected: 'Clientes'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0), // Adjust bottom padding if FAB overlaps
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Clientes',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A202C)),
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
                      Wrap( // Use Wrap for better responsiveness of action buttons
                        spacing: 12.0, // Horizontal space between buttons
                        runSpacing: 8.0, // Vertical space if they wrap
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: const Text('Excluir'),
                            onPressed: _selectedCustomerIndices.isNotEmpty ? _deleteSelectedCustomers : null,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: _selectedCustomerIndices.isNotEmpty ? Colors.red.shade700 : Colors.grey, 
                              backgroundColor: _selectedCustomerIndices.isNotEmpty ? Colors.red.shade100 : Colors.grey.shade300,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.filter_list, size: 18),
                            label: const Text('Filtrar'),
                            onPressed: () {
                               ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Funcionalidade "Filtrar" não implementada.'))
                              );
                            },
                             style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF4A5568),
                              side: BorderSide(color: Colors.grey.shade300),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.download_outlined, size: 18),
                            label: const Text('Exportar'),
                            onPressed: () {
                               ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Funcionalidade "Exportar" não implementada.'))
                              );
                            },
                             style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF4A5568),
                              side: BorderSide(color: Colors.grey.shade300),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                          elevation: 0, 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                          if (presenter.isLoading && presenter.internalCustomers.isEmpty) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (!presenter.isLoading && presenter.internalCustomers.isEmpty) {
                            return const Center(
                              child: Text(
                                'Nenhum cliente encontrado.',
                                style: TextStyle(fontSize: 16, color: Color(0xFF718096)),
                              ),
                            );
                          }
                          
                          final List<List<String>> tableData =
                              presenter.internalCustomers.map((customer) {
                            // Assuming your Customer model has a 'status' field or you derive it.
                            // For now, using a mock status based on ID. Replace with actual data.
                            String status = customer.id % 3 == 0 ? 'Active' : (customer.id % 3 == 1 ? 'Inactive' : 'Pending'); 
                            return [
                              customer.nome,
                              customer.cpf,
                              customer.email,
                              customer.telefone,
                              status, // Actual status data
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
                              if (rowIndex < presenter.internalCustomers.length) {
                                final customer = presenter.internalCustomers[rowIndex];
                                // TODO: Implement actual edit dialog/screen
                                print('Edit customer: ${customer.nome}');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Editar ${customer.nome} (não implementado).'))
                                );
                              }
                            },
                            onDelete: (rowIndex) {
                               if (rowIndex < presenter.internalCustomers.length) {
                                final customer = presenter.internalCustomers[rowIndex];
                                showDialog(
                                  context: context,
                                  builder: (BuildContext dialogContext) => AlertDialog(
                                    title: const Text('Confirmar Exclusão'),
                                    content: Text('Tem certeza que deseja excluir ${customer.nome}?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancelar')),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                        onPressed: () async {
                                          try {
                                            await presenter.deleteInternalCustomer(customer.id);
                                            Navigator.of(dialogContext).pop();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Cliente excluído com sucesso!'), backgroundColor: Colors.green,)
                                            );
                                          } catch (e) {
                                            Navigator.of(dialogContext).pop();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Falha ao excluir cliente: $e'), backgroundColor: Colors.red,)
                                            );
                                          }
                                        }, 
                                        child: const Text('Excluir')
                                      ),
                                    ],
                                  )
                                );
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
