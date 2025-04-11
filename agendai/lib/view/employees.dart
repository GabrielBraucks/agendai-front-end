import 'package:agendai/presenter/employees_presenter.dart';
import 'package:agendai/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Employees extends StatefulWidget {
  const Employees({super.key});

  @override
  State<Employees> createState() => _EmployeesState();
}

class _EmployeesState extends State<Employees> {
  late AnimationController _controller;

  @override
  void initState() {
    final presenter = Provider.of<EmployeesPresenter>(context, listen: false);
    Future.delayed(Duration.zero).then((value) {
      presenter.getEmployees();
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.only(left: 20),
            child: IconButton(
              icon: const Icon(
                Icons.list,
                size: 40,
              ),
              tooltip: "Menu",
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 20,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.logout,
                size: 40,
              ),
              tooltip: "Logout",
              onPressed: () async {
                await context.read<EmployeesPresenter>().logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
            ),
          ),
        ],
        shadowColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 100,
      ),
      drawer: AppDrawer(),
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Consumer<EmployeesPresenter>(
            builder: (context, presenter, child) {
              if (presenter.loadingPage) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (presenter.funcionarios.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.search,
                        size: 50,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Você não possui nenhum funcionário listado',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }
              final selected = presenter.selected;

              return Row(
                children: [
                  // Lado Direito
                  Expanded(
                      flex: 1,
                      child: selected == null
                          ? const Center(
                              child: Text(
                                'Selecione um funcionário',
                                style: TextStyle(color: Colors.white70),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                color: Colors.blueGrey[800],
                                elevation: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(30.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Center(
                                        child: Icon(
                                          Icons.account_circle_rounded,
                                          size: 300,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      // Informações do funcionário
                                      _infoItem('Nome', selected.nome),
                                      _infoItem('CPF', selected.cpf),
                                      _infoItem('Email', selected.email),
                                      _infoItem('Telefone', selected.telefone),
                                      _infoItem(
                                          'Nascimento', selected.dataNasc),
                                      _infoItem('Cargo', selected.cargo),
                                      _infoItem('Empresa', selected.empresa),
                                    ],
                                  ),
                                ),
                              ),
                            )),

                  VerticalDivider(width: 1),
                  //Lado esquerdo: Lista de funcionários
                  Expanded(
                    flex: 2,
                    child: ListView.builder(
                      itemCount: presenter.funcionarios.length,
                      itemBuilder: (context, index) {
                        final funcionario = presenter.funcionarios[index];

                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.deepPurple,
                            ),
                            title: Text(funcionario.nome),
                            subtitle: Text(funcionario.cargo),
                            selected: selected?.id == funcionario.id,
                            onTap: () {
                              presenter.idEmployee(funcionario.id);
                            },
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.blue,
                              ),
                              tooltip: 'Editar funcionário',
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => _buildEditDialog(
                                      context, presenter, funcionario),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 100,
          vertical: 50,
        ),
        child: SizedBox(
          width: 70,
          height: 70,
          child: FloatingActionButton(
            backgroundColor: Color(0xFF620096),
            onPressed: () async {
              final result =
                  await Navigator.pushNamed(context, '/employee-form');
              if (result == true) {
                context.read<EmployeesPresenter>().getEmployees();
              }
            },
            tooltip: 'Adicionar funcionário',
            child: const Icon(
              Icons.add,
              size: 40,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildEditDialog(
    BuildContext context, EmployeesPresenter presenter, var funcionario) {
  final nameController = TextEditingController(text: funcionario.nome);
  final cpfController = TextEditingController(text: funcionario.cpf);
  final cargoController = TextEditingController(text: funcionario.cargo);
  final emailController = TextEditingController(text: funcionario.email);
  final telefoneController = TextEditingController(text: funcionario.telefone);
  final dataNascController = TextEditingController(text: funcionario.dataNasc);

  return AlertDialog(
    title: const Text('Editar Funcionário'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Nome'),
          ),
          TextField(
            controller: cpfController,
            decoration: const InputDecoration(labelText: 'CPF'),
          ),
          TextField(
            controller: cargoController,
            decoration: const InputDecoration(labelText: 'Cargo'),
          ),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: telefoneController,
            decoration: const InputDecoration(labelText: 'Telefone'),
          ),
          TextField(
            controller: dataNascController,
            decoration: const InputDecoration(labelText: 'Nascimento'),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      ElevatedButton(
        onPressed: () async {
          // Aqui você chama sua lógica de atualização
          await presenter.updateEmployee(
            id: funcionario.id,
            nome: nameController.text,
            cpf: cpfController.text,
            cargo: cargoController.text,
            email: emailController.text,
            telefone: telefoneController.text,
            dataNasc: dataNascController.text,
          );
          await presenter.getEmployees(); // Atualiza a lista
          Navigator.pop(context); // Fecha o diálogo
        },
        child: const Text('Salvar'),
      ),
    ],
  );
}

/// Helper para estilizar as informações
Widget _infoItem(String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title: ',
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}
