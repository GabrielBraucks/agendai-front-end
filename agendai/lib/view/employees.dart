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
              if (presenter.loadingHome) {
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
                  // Lado direito: Detalhes do funcionário
                  Expanded(
                      flex: 1,
                      child: //Text("testeee"),
                          selected == null
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
                                          // Ícone centralizado no topo
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
                                          _infoItem(
                                              'Telefone', selected.telefone),
                                          _infoItem(
                                              'Nascimento', selected.dataNasc),
                                          _infoItem('Cargo', selected.cargo),
                                          _infoItem(
                                              'Empresa', selected.empresa),
                                        ],
                                      ),
                                    ),
                                  ),
                                )

                      // Padding(
                      //     padding: const EdgeInsets.all(20.0),
                      //     child: Card(
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(15),
                      //       ),
                      //       color: Colors.blueGrey[800],
                      //       elevation: 5,
                      //       child: Padding(
                      //         padding: const EdgeInsets.all(20.0),
                      //         child: Column(
                      //           crossAxisAlignment:
                      //               CrossAxisAlignment.start,
                      //           children: [
                      //             ListTile(
                      //               leading: Icon(Icons.person,
                      //                   color: Colors.white),
                      //               title: Text(
                      //                 selected.nome,
                      //                 style: TextStyle(
                      //                     fontSize: 24,
                      //                     fontWeight: FontWeight.bold,
                      //                     color: Colors.white),
                      //               ),
                      //             ),
                      //             Divider(color: Colors.white24),
                      //             ListTile(
                      //               leading: Icon(Icons.badge,
                      //                   color: Colors.white70),
                      //               title: Text('CPF',
                      //                   style: TextStyle(
                      //                       color: Colors.white70)),
                      //               subtitle: Text(selected.cpf,
                      //                   style: TextStyle(
                      //                       color: Colors.white)),
                      //             ),
                      //             ListTile(
                      //               leading: Icon(Icons.email,
                      //                   color: Colors.white70),
                      //               title: Text('Email',
                      //                   style: TextStyle(
                      //                       color: Colors.white70)),
                      //               subtitle: Text(selected.email,
                      //                   style: TextStyle(
                      //                       color: Colors.white)),
                      //             ),
                      //             ListTile(
                      //               leading: Icon(Icons.phone,
                      //                   color: Colors.white70),
                      //               title: Text('Telefone',
                      //                   style: TextStyle(
                      //                       color: Colors.white70)),
                      //               subtitle: Text(selected.telefone,
                      //                   style: TextStyle(
                      //                       color: Colors.white)),
                      //             ),
                      //             ListTile(
                      //               leading: Icon(Icons.cake,
                      //                   color: Colors.white70),
                      //               title: Text('Nascimento',
                      //                   style: TextStyle(
                      //                       color: Colors.white70)),
                      //               subtitle: Text(selected.dataNasc,
                      //                   style: TextStyle(
                      //                       color: Colors.white)),
                      //             ),
                      //             ListTile(
                      //               leading: Icon(Icons.work,
                      //                   color: Colors.white70),
                      //               title: Text('Cargo',
                      //                   style: TextStyle(
                      //                       color: Colors.white70)),
                      //               subtitle: Text(selected.cargo,
                      //                   style: TextStyle(
                      //                       color: Colors.white)),
                      //             ),
                      //             ListTile(
                      //               leading: Icon(Icons.apartment,
                      //                   color: Colors.white70),
                      //               title: Text('Empresa',
                      //                   style: TextStyle(
                      //                       color: Colors.white70)),
                      //               subtitle: Text(selected.empresa,
                      //                   style: TextStyle(
                      //                       color: Colors.white)),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ),
                      //   )

                      // : Padding(
                      //     padding: const EdgeInsets.all(20.0),
                      //     child: Column(
                      //       crossAxisAlignment: CrossAxisAlignment.start,
                      //       children: [
                      //         Text('Nome: ${selected.nome}',
                      //             style: TextStyle(
                      //                 fontSize: 24, color: Colors.white)),
                      //         SizedBox(height: 10),
                      //         Text('CPF: ${selected.cpf}',
                      //             style:
                      //                 TextStyle(color: Colors.white70)),
                      //         Text('Email: ${selected.email}',
                      //             style:
                      //                 TextStyle(color: Colors.white70)),
                      //         Text('Telefone: ${selected.telefone}',
                      //             style:
                      //                 TextStyle(color: Colors.white70)),
                      //         Text(
                      //             'Data de Nascimento: ${selected.dataNasc}',
                      //             style:
                      //                 TextStyle(color: Colors.white70)),
                      //         Text('Cargo: ${selected.cargo}',
                      //             style:
                      //                 TextStyle(color: Colors.white70)),
                      //         Text('Empresa: ${selected.empresa}',
                      //             style:
                      //                 TextStyle(color: Colors.white70)),
                      //       ],
                      //     ),
                      //   ),
                      ),

                  VerticalDivider(width: 1),
                  //Lado esquerdo: Lista de funcionários
                  Expanded(
                    flex: 2,
                    child: ListView.builder(
                      itemCount: presenter.funcionarios.length,
                      itemBuilder: (context, index) {
                        final funcionario = presenter.funcionarios[index];
                        return Card(
                          child: ListTile(
                            title: Text(funcionario.nome),
                            subtitle: Text(funcionario.cargo),
                            selected: selected?.id == funcionario.id,
                            onTap: () {
                              presenter.idEmployee(funcionario.id);
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  // VerticalDivider(width: 1),
                ],
              );
            },
          ),
        ),
      ),

      // Center(
      //   child: Container(
      //     padding: const EdgeInsets.symmetric(horizontal: 30),
      //     child: Consumer<EmployeesPresenter>(
      //       builder: (context, presenter, child) {
      //         if (presenter.loadingHome) {
      //           return const Center(
      //             child: CircularProgressIndicator(),
      //           );
      //         }
      //         return Column(
      //           children: [
      //             Row(
      //               children: [
      //                 Align(
      //                   alignment: Alignment.centerLeft,
      //                   child: const Text(
      //                     'Funcionários',
      //                     style: TextStyle(
      //                       fontSize: 40,
      //                       color: Colors.white,
      //                     ),
      //                   ),
      //                 ),
      //                 const Spacer(),
      //                 Padding(
      //                   padding: const EdgeInsets.only(bottom: 10),
      //                   child: Row(
      //                     mainAxisAlignment: MainAxisAlignment.end,
      //                     children: [
      //                       SizedBox(
      //                         width: 500,
      //                         child: TextField(
      //                           decoration: const InputDecoration(
      //                             prefixIcon: Icon(
      //                               Icons.search,
      //                               color: Colors.white,
      //                             ),
      //                             hintText: 'Busque palavras-chave',
      //                             border: OutlineInputBorder(),
      //                           ),
      //                         ),
      //                       ),
      //                     ],
      //                   ),
      //                 ),
      //               ],
      //             ),
      //             SizedBox(
      //               height: 20,
      //             ),
      //             Expanded(
      //               child: presenter.funcionarios.isEmpty
      //                   ? Center(
      //                       child: Column(
      //                         mainAxisAlignment: MainAxisAlignment.center,
      //                         crossAxisAlignment: CrossAxisAlignment.center,
      //                         children: const [
      //                           Icon(
      //                             Icons.search,
      //                             size: 50,
      //                             color: Colors.grey,
      //                           ),
      //                           SizedBox(height: 15),
      //                           Text(
      //                             'Você não possui nenhum funcionário listado',
      //                             style: TextStyle(
      //                               fontSize: 15,
      //                               color: Colors.grey,
      //                             ),
      //                           ),
      //                         ],
      //                       ),
      //                     )
      //                   : GridView.count(
      //                       crossAxisCount:
      //                           MediaQuery.of(context).size.width > 1000
      //                               ? 7
      //                               : MediaQuery.of(context).size.width > 600
      //                                   ? 4
      //                                   : 2,
      //                       crossAxisSpacing: 10,
      //                       mainAxisSpacing: 10,
      //                       childAspectRatio: 1, // quadrado
      //                       children: List.generate(
      //                         presenter.funcionarios.length,
      //                         (index) {
      //                           final servicos = presenter.funcionarios[index];
      //                           final id = servicos.id;
      //                           final nome = servicos.nome;
      //                           final preco = servicos.cpf;
      //                           final categoria = servicos.cargo;
      //                           final duracao = servicos.email;

      //                           return Card(
      //                             color: Colors.blueGrey[700],
      //                             shape: RoundedRectangleBorder(
      //                               borderRadius: BorderRadius.circular(15),
      //                             ),
      //                             elevation: 5,
      //                             child: Padding(
      //                               padding: const EdgeInsets.all(12.0),
      //                               child: Column(
      //                                 crossAxisAlignment:
      //                                     CrossAxisAlignment.start,
      //                                 children: [
      //                                   Text(
      //                                     nome,
      //                                     style: const TextStyle(
      //                                       fontSize: 16,
      //                                       fontWeight: FontWeight.bold,
      //                                       color: Colors.white,
      //                                     ),
      //                                   ),
      //                                   const SizedBox(height: 5),
      //                                   Text(
      //                                     categoria,
      //                                     style: const TextStyle(
      //                                       fontSize: 14,
      //                                       color: Colors.white70,
      //                                     ),
      //                                   ),
      //                                   const Spacer(),
      //                                   Row(
      //                                     mainAxisAlignment:
      //                                         MainAxisAlignment.spaceBetween,
      //                                     children: [
      //                                       Column(
      //                                         crossAxisAlignment:
      //                                             CrossAxisAlignment.start,
      //                                         children: [
      //                                           Text(
      //                                             'R\$ $preco',
      //                                             style: const TextStyle(
      //                                               color: Colors.white,
      //                                             ),
      //                                           ),
      //                                           Text(
      //                                             duracao,
      //                                             style: const TextStyle(
      //                                               color: Colors.white70,
      //                                             ),
      //                                           ),
      //                                         ],
      //                                       ),
      //                                       IconButton(
      //                                         icon: const Icon(
      //                                           Icons.delete_outline_sharp,
      //                                           color: Colors.white,
      //                                         ),
      //                                         tooltip: "Deletar",
      //                                         // onPressed: () {
      //                                         //   //presenter.deleteServicos(id);

      //                                         // },
      //                                         onPressed: () {
      //                                           showDialog(
      //                                             context: context,
      //                                             builder:
      //                                                 (BuildContext context) {
      //                                               return AlertDialog(
      //                                                 backgroundColor:
      //                                                     Colors.white,
      //                                                 title: const Text(
      //                                                   'Confirmar exclusão',
      //                                                   style: TextStyle(
      //                                                     color: Colors.black87,
      //                                                   ),
      //                                                 ),
      //                                                 content: Text(
      //                                                   'Tem certeza que deseja excluir o "$nome"?',
      //                                                   style: TextStyle(
      //                                                     color: Colors.black87,
      //                                                   ),
      //                                                 ),
      //                                                 actions: <Widget>[
      //                                                   TextButton(
      //                                                     child: const Text(
      //                                                       'Cancelar',
      //                                                       style: TextStyle(
      //                                                         color: Colors.red,
      //                                                       ),
      //                                                     ),
      //                                                     onPressed: () {
      //                                                       Navigator.of(
      //                                                               context)
      //                                                           .pop();
      //                                                     },
      //                                                   ),
      //                                                   ElevatedButton(
      //                                                     onPressed: () {
      //                                                       presenter
      //                                                           .deleteServicos(
      //                                                               id);
      //                                                       Navigator.of(
      //                                                               context)
      //                                                           .pop();
      //                                                     },
      //                                                     style: ElevatedButton
      //                                                         .styleFrom(
      //                                                       padding:
      //                                                           const EdgeInsets
      //                                                               .symmetric(
      //                                                               vertical: 5,
      //                                                               horizontal:
      //                                                                   25),
      //                                                     ),
      //                                                     child: const Text(
      //                                                       'Excluir',
      //                                                       style: TextStyle(
      //                                                         color:
      //                                                             Colors.white,
      //                                                         fontSize: 15,
      //                                                       ),
      //                                                     ),
      //                                                   ),
      //                                                   // TextButton(
      //                                                   //   child: const Text(
      //                                                   //     'Excluir',
      //                                                   //     style: TextStyle(
      //                                                   //         color:
      //                                                   //             Colors.red),
      //                                                   //   ),
      //                                                   //   onPressed: () {
      //                                                   //     presenter
      //                                                   //         .deleteServicos(
      //                                                   //             id);
      //                                                   //     Navigator.of(
      //                                                   //             context)
      //                                                   //         .pop();
      //                                                   //   },
      //                                                   // ),
      //                                                 ],
      //                                               );
      //                                             },
      //                                           );
      //                                         },
      //                                       ),
      //                                     ],
      //                                   )
      //                                 ],
      //                               ),
      //                             ),
      //                           );
      //                         },
      //                       ),
      //                     ),
      //             ),
      //           ],
      //         );
      //       },
      //     ),
      //   ),
      // ),
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
