import 'package:agendai/entity/employee.dart';
import 'package:agendai/model/agendai_api.dart'; // Assuming Employee is here or re-exported
import 'package:agendai/presenter/employees_presenter.dart';
import 'package:agendai/widgets/responsiveTable.dart';
import 'package:agendai/widgets/sidebar.dart'; // Path to your ResponsiveTable
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Assuming Employee entity is defined, e.g., in 'agendai/entity/employee.dart'
// Ensure Employee class has fields like id, nome, cpf, cargo, email, telefone, dataNasc, (and potentially status)

class Employees extends StatefulWidget {
  const Employees({super.key});

  @override
  State<Employees> createState() => _EmployeesState();
}

class _EmployeesState extends State<Employees> {
  List<int> _selectedEmployeeIndices = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final presenter = Provider.of<EmployeesPresenter>(context, listen: false);
      // Fetch only if not already loading and list is empty
      if (presenter.funcionarios.isEmpty && !presenter.isLoading) {
        presenter.getEmployees();
      }
    });
  }

  // --- MODAL DIALOGS ---

  void _showAddEmployeeDialog() {
    final nameController = TextEditingController();
    final cpfController = TextEditingController();
    final cargoController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final dataNascController = TextEditingController();
    final passwordController = TextEditingController(); // Added for new employee
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final presenter = Provider.of<EmployeesPresenter>(dialogContext, listen: false);
        return AlertDialog(
          title: const Text('Adicionar Novo Funcionário'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(controller: nameController, decoration: const InputDecoration(labelText: 'Nome Completo', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Nome é obrigatório' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: cpfController, decoration: const InputDecoration(labelText: 'CPF', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'CPF é obrigatório' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: cargoController, decoration: const InputDecoration(labelText: 'Cargo', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Cargo é obrigatório' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: emailController, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()), keyboardType: TextInputType.emailAddress, validator: (v) => v!.isEmpty || !v.contains('@') ? 'Email inválido' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: phoneController, decoration: const InputDecoration(labelText: 'Telefone', border: OutlineInputBorder()), keyboardType: TextInputType.phone, validator: (v) => v!.isEmpty ? 'Telefone é obrigatório' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: dataNascController, decoration: const InputDecoration(labelText: 'Data de Nascimento (YYYY-MM-DD)', border: OutlineInputBorder()), keyboardType: TextInputType.datetime, validator: (v) => v!.isEmpty ? 'Data de nascimento é obrigatória' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: passwordController, decoration: const InputDecoration(labelText: 'Senha', border: OutlineInputBorder()), obscureText: true, validator: (v) => v!.isEmpty ? 'Senha é obrigatória' : (v.length < 6 ? 'Senha muito curta (mín. 6)' : null)),
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
                    // Assuming createEmployee exists in your presenter
                    await presenter.createEmployee(
                      name: nameController.text,
                      cpf: cpfController.text,
                      jobTitle: cargoController.text,
                      email: emailController.text,
                      celPhone: phoneController.text,
                      birthday: dataNascController.text,
                      password: passwordController.text,
                    );
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Funcionário adicionado!'), backgroundColor: Colors.green));
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

  void _showEditEmployeeDialog(Employee employeeToEdit) {
    final nameController = TextEditingController(text: employeeToEdit.nome);
    final cpfController = TextEditingController(text: employeeToEdit.cpf);
    final cargoController = TextEditingController(text: employeeToEdit.cargo);
    final emailController = TextEditingController(text: employeeToEdit.email);
    final phoneController = TextEditingController(text: employeeToEdit.telefone);
    final dataNascController = TextEditingController(text: employeeToEdit.dataNasc);
    // Password usually not edited directly this way or shown, handle as per your app's security policy
    // final passwordController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final presenter = Provider.of<EmployeesPresenter>(dialogContext, listen: false);
        return AlertDialog(
          title: Text('Editar Funcionário: ${employeeToEdit.nome}'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(controller: nameController, decoration: const InputDecoration(labelText: 'Nome Completo', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Nome é obrigatório' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: cpfController, decoration: const InputDecoration(labelText: 'CPF', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'CPF é obrigatório' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: cargoController, decoration: const InputDecoration(labelText: 'Cargo', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Cargo é obrigatório' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: emailController, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()), keyboardType: TextInputType.emailAddress, validator: (v) => v!.isEmpty || !v.contains('@') ? 'Email inválido' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: phoneController, decoration: const InputDecoration(labelText: 'Telefone', border: OutlineInputBorder()), keyboardType: TextInputType.phone, validator: (v) => v!.isEmpty ? 'Telefone é obrigatório' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: dataNascController, decoration: const InputDecoration(labelText: 'Data de Nascimento (YYYY-MM-DD)', border: OutlineInputBorder()), keyboardType: TextInputType.datetime, validator: (v) => v!.isEmpty ? 'Data de nascimento é obrigatória' : null),
                  // Add password field if updatable, typically a separate "Change Password" flow
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
                    await presenter.updateEmployee(
                      id: employeeToEdit.id,
                      name: nameController.text,
                      cpf: cpfController.text,
                      jobTitle: cargoController.text,
                      email: emailController.text,
                      celPhone: phoneController.text,
                      birthday: dataNascController.text,
                    );
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Funcionário atualizado!'), backgroundColor: Colors.green));
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
          content: Text(multiple 
            ? 'Tem certeza que deseja excluir os ${itemName} funcionário(s) selecionado(s)?' 
            : 'Tem certeza que deseja excluir o funcionário "$itemName"?'),
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

  void _deleteSelectedEmployees() {
    final presenter = Provider.of<EmployeesPresenter>(context, listen: false);
    if (_selectedEmployeeIndices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nenhum funcionário selecionado.')));
      return;
    }
    
    List<Employee> employeesToDelete = _selectedEmployeeIndices.map((index) {
      if (index < presenter.funcionarios.length) return presenter.funcionarios[index];
      return null; 
    }).whereType<Employee>().toList();

    if (employeesToDelete.isEmpty && _selectedEmployeeIndices.isNotEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao identificar funcionários.'), backgroundColor: Colors.red));
      return;
    }

    _confirmDeleteDialog(
      context,
      () async {
        int successCount = 0;
        for (var employee in employeesToDelete) {
          try {
            await presenter.deleteEmployee(id: employee.id); // Assuming deleteEmployee takes id
            successCount++;
          } catch (e) {
            print("Falha ao excluir funcionário ${employee.id}: $e");
          }
        }
        setState(() { _selectedEmployeeIndices = []; });
        
        if (successCount > 0 && successCount == employeesToDelete.length) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$successCount funcionário(s) excluído(s)!'), backgroundColor: Colors.green));
        } else if (successCount > 0) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$successCount funcionário(s) excluído(s). Alguns falharam.'), backgroundColor: Colors.orange));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Falha ao excluir funcionário(s).'), backgroundColor: Colors.red));
        }
      },
      _selectedEmployeeIndices.length.toString(),
      multiple: true
    );
  }

  // --- BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    // Define table headers for Employees
    final List<String> tableHeaders = ['Nome', 'CPF', 'Cargo', 'Email', 'Telefone'];

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC), 
      body: Row(
        children: [
          const Sidebar(selected: 'Funcionarios'), // Corrected selected item
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page Header
                  const Text('Funcionários', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A202C))),
                  const SizedBox(height: 8),
                  const Text('Tabela de todos os seus funcionários cadastrados', style: TextStyle(fontSize: 15, color: Color(0xFF718096))),
                  const SizedBox(height: 24),
                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Wrap( 
                        spacing: 12.0, runSpacing: 8.0, 
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: const Text('Excluir'),
                            onPressed: _selectedEmployeeIndices.isNotEmpty ? _deleteSelectedEmployees : null,
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
                          OutlinedButton.icon(
                            icon: const Icon(Icons.download_outlined, size: 18),
                            label: const Text('Exportar'),
                            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exportar não implementado.'))),
                             style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF4A5568), side: BorderSide(color: Colors.grey.shade300), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Adicionar Funcionário'),
                        onPressed: _showAddEmployeeDialog,
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
                      child: Consumer<EmployeesPresenter>(
                        builder: (context, presenter, child) {
                          if (presenter.isLoading && presenter.funcionarios.isEmpty) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (!presenter.isLoading && presenter.funcionarios.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.group_off_outlined, size: 60, color: Colors.grey.shade400),
                                  const SizedBox(height: 16),
                                  const Text('Nenhum funcionário encontrado.', style: TextStyle(fontSize: 17, color: Color(0xFF718096))),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(icon: const Icon(Icons.add), label: const Text('Adicionar Funcionário'), onPressed: _showAddEmployeeDialog, style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Theme.of(context).primaryColor))
                                ],
                              ),
                            );
                          }
                          
                          final List<List<String>> tableData = presenter.funcionarios.map((employee) {
                            // Assuming Employee model has a status or you derive it
                            String status = employee.id % 2 == 0 ? 'Active' : 'Inactive'; // Mock status
                            return [
                              employee.nome,
                              employee.cpf,
                              employee.cargo,
                              employee.email,
                              employee.telefone,
                            ];
                          }).toList();

                          return ResponsiveTable( 
                            headers: tableHeaders,
                            data: tableData,
                            onSelectionChanged: (selectedIndices) {
                              setState(() { _selectedEmployeeIndices = selectedIndices; });
                            },
                            onEdit: (rowIndex) { 
                              if (rowIndex < presenter.funcionarios.length) {
                                _showEditEmployeeDialog(presenter.funcionarios[rowIndex]);
                              }
                            },
                            onDelete: (rowIndex) {
                               if (rowIndex < presenter.funcionarios.length) {
                                final employee = presenter.funcionarios[rowIndex];
                                _confirmDeleteDialog(context, () async {
                                  try {
                                    await presenter.deleteEmployee(id: employee.id);
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Funcionário excluído!'), backgroundColor: Colors.green));
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Falha: ${e.toString()}'), backgroundColor: Colors.red));
                                  }
                                }, employee.nome);
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
