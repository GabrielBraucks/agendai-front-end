import 'package:agendai/presenter/servico_presenter.dart';
import 'package:agendai/view/service_register.dart';
import 'package:agendai/widgets/testTable.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Service extends StatefulWidget {
  const Service({super.key});

  @override
  State<Service> createState() => _ServiceState();
}

class _ServiceState extends State<Service> {
  late AnimationController _controller;
  List<int> _selectedServiceIndices = [];

  @override
  void initState() {
    final presenter = Provider.of<ServicePresenter>(context, listen: false);
    Future.delayed(Duration.zero).then((value) {
      presenter.getServicos();
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
    final List<String> tableHeaders = [
      'Serviço',
      'Preço',
      'Duração',
      'Categoria',
    ];
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            // padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Consumer<ServicePresenter>(
              builder: (context, presenter, child) {
                if (presenter.loadingService) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return Scaffold(
                  body: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Serviços',
                                  style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A202C))),
                              const SizedBox(height: 8),
                              const Text(
                                  'Tabela de todos os seus serviços cadastrados',
                                  style: TextStyle(
                                      fontSize: 15, color: Color(0xFF718096))),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Wrap(
                                    spacing: 12.0,
                                    runSpacing: 8.0,
                                    children: [
                                      ElevatedButton.icon(
                                        icon: Icon(Icons.delete_outline,
                                            size: 18),
                                        label: Text('Excluir'),
                                        onPressed: () {
                                          // List<int> selectedIndices = [];
                                          // for (int i = 0;
                                          //     i < presenter.servicos.length;
                                          //     i++) {
                                          //   if (selectedIndices.contains(i)) {
                                          //     selectedIndices.remove(i);
                                          //   } else {
                                          //     showDialog(
                                          //         context: context,
                                          //         builder:
                                          //             (BuildContext context) {
                                          //           return AlertDialog(
                                          //             title: const Text(
                                          //               'Confirmar exclusão',
                                          //             ),
                                          //             content: Text(
                                          //               'Tem certeza que deseja excluir o serviço "${presenter.servicos[i].nome}"?',
                                          //             ),
                                          //             actions: <Widget>[
                                          //               TextButton(
                                          //                 child: const Text(
                                          //                   'Cancelar',
                                          //                   style: TextStyle(
                                          //                     color: Colors.red,
                                          //                   ),
                                          //                 ),
                                          //                 onPressed: () {
                                          //                   Navigator.of(
                                          //                           context)
                                          //                       .pop();
                                          //                 },
                                          //               ),
                                          //               ElevatedButton(
                                          //                 onPressed: () {
                                          //                   presenter
                                          //                       .deleteServicos(
                                          //                           presenter
                                          //                               .servicos[
                                          //                                   i]
                                          //                               .id);
                                          //                   ScaffoldMessenger
                                          //                           .of(context)
                                          //                       .showSnackBar(
                                          //                           const SnackBar(
                                          //                               content:
                                          //                                   Text('Serviço excluído com sucesso')));
                                          //                   Navigator.of(
                                          //                           context)
                                          //                       .pop();
                                          //                 },
                                          //                 child: const Text(
                                          //                     'Excluir'),
                                          //               ),
                                          //             ],
                                          //           );
                                          //         });
                                          //   }
                                          // }
                                        },
                                        // onPressed: _selectedEmployeeIndices.isNotEmpty
                                        //     ? _deleteSelectedEmployees
                                        //     : null,
                                        style: ButtonStyle(
                                          padding: WidgetStateProperty.all(
                                              EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 12)),
                                          elevation: WidgetStateProperty.all(0),
                                          shape: WidgetStateProperty.all(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8))),
                                          foregroundColor: WidgetStateProperty
                                              .resolveWith<Color?>((states) =>
                                                  states.contains(
                                                          WidgetState.disabled)
                                                      ? Colors.grey.shade500
                                                      : Colors.red.shade700),
                                          backgroundColor: WidgetStateProperty
                                              .resolveWith<Color?>((states) =>
                                                  states.contains(
                                                          WidgetState.disabled)
                                                      ? Colors.grey.shade200
                                                      : Colors.red.shade100),
                                          textStyle: WidgetStateProperty.all(
                                              TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500)),
                                        ),
                                      ),
                                      OutlinedButton.icon(
                                        icon: Icon(Icons.filter_list, size: 18),
                                        label: Text('Filtrar'),
                                        onPressed: () => ScaffoldMessenger.of(
                                                context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Filtrar não implementado.'))),
                                        style: OutlinedButton.styleFrom(
                                            foregroundColor: Color(0xFF4A5568),
                                            side: BorderSide(
                                                color: Colors.grey.shade300),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 12),
                                            textStyle: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8))),
                                      ),
                                      OutlinedButton.icon(
                                        icon: Icon(Icons.download_outlined,
                                            size: 18),
                                        label: Text('Exportar'),
                                        onPressed: () => ScaffoldMessenger.of(
                                                context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Exportar não implementado.'))),
                                        style: OutlinedButton.styleFrom(
                                            foregroundColor: Color(0xFF4A5568),
                                            side: BorderSide(
                                                color: Colors.grey.shade300),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 12),
                                            textStyle: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8))),
                                      ),
                                    ],
                                  ),
                                  ElevatedButton.icon(
                                    icon: const Icon(
                                      Icons.add,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    label: const Text('Adicionar Serviço'),
                                    onPressed: () async {
                                      await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            content: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxHeight:
                                                    MediaQuery.of(context)
                                                            .size
                                                            .height *
                                                        0.8,
                                                maxWidth: 500,
                                              ),
                                              child:
                                                  const SingleChildScrollView(
                                                child: ServiceRegister(),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                      // final result = await Navigator.pushNamed(context, '/service');
                                      // if (result == true) {
                                      context
                                          .read<ServicePresenter>()
                                          .getServicos();
                                      //}
                                    },
                                    //onPressed: _showAddEmployeeDialog,
                                    style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 12),
                                        textStyle: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8))),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Expanded(
                                child: Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(
                                          color: Colors.grey.shade300,
                                          width: 1)),
                                  clipBehavior: Clip.antiAlias,
                                  child: Consumer<ServicePresenter>(
                                    builder: (context, presenter, child) {
                                      if (presenter.loadingService &&
                                          presenter.servicos.isEmpty) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      }
                                      if (!presenter.loadingService &&
                                          presenter.servicos.isEmpty) {
                                        return Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.group_off_outlined,
                                                  size: 60,
                                                  color: Colors.grey.shade400),
                                              const SizedBox(height: 16),
                                              const Text(
                                                  'Nenhum serviço encontrado.',
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      color:
                                                          Color(0xFF718096))),
                                              const SizedBox(height: 8),
                                              ElevatedButton.icon(
                                                  icon: const Icon(Icons.add),
                                                  label: const Text(
                                                      'Adicionar Serviço'),
                                                  onPressed: () async {
                                                    await showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          content:
                                                              ConstrainedBox(
                                                            constraints:
                                                                BoxConstraints(
                                                              maxHeight: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.8,
                                                              maxWidth: 500,
                                                            ),
                                                            child:
                                                                const SingleChildScrollView(
                                                              child:
                                                                  ServiceRegister(),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                    // final result = await Navigator.pushNamed(context, '/service');
                                                    // if (result == true) {
                                                    context
                                                        .read<
                                                            ServicePresenter>()
                                                        .getServicos();
                                                    //}
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          foregroundColor:
                                                              Colors.white,
                                                          backgroundColor: Theme
                                                                  .of(context)
                                                              .primaryColor))
                                            ],
                                          ),
                                        );
                                      }

                                      List<Map<String, dynamic>> tabelaData =
                                          presenter.servicos
                                              .map((item) => item.toMap())
                                              .toList();

                                      // final camposParaRemover = [
                                      //   'id',
                                      //   'categoria'
                                      // ];

                                      // // Remover atributos específicos de cada item no dataMap
                                      // for (var item in tabelaData) {
                                      //   for (var campo in camposParaRemover) {
                                      //     item.remove(campo);
                                      //   }
                                      // }

                                      return TestTable(
                                        dataMap: tabelaData,
                                        onSelectionChanged: (selectedIndices) {
                                          setState(() {
                                            _selectedServiceIndices =
                                                selectedIndices;
                                          });
                                        },
                                        onEdit: (rowIndex) {
                                          // if (rowIndex <
                                          //     presenter.funcionarios.length) {
                                          //   _showEditEmployeeDialog(presenter
                                          //       .funcionarios[rowIndex]);
                                          // }
                                        },
                                        onDelete: (rowIndex) {
                                          final service = presenter.servicos
                                              .where((service) =>
                                                  service.id == rowIndex)
                                              .first;

                                          _confirmDeleteDialog(
                                            context,
                                            () async {
                                              try {
                                                await presenter
                                                    .deleteServicos(service.id);
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(const SnackBar(
                                                        content: Text(
                                                            'Serviço excluído!'),
                                                        backgroundColor:
                                                            Colors.green));
                                              } catch (e) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                        content: Text(
                                                            'Falha: ${e.toString()}'),
                                                        backgroundColor:
                                                            Colors.red));
                                              }
                                            },
                                            service.nome,
                                          );
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
              },
            ),
          )
        ],
      ),
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
              ? 'Tem certeza que deseja excluir os $itemName serviço(s) selecionado(s)?'
              : 'Tem certeza que deseja excluir o serviço "$itemName"?'),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: <Widget>[
            TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.of(dialogContext).pop()),
            ElevatedButton.icon(
              icon: const Icon(Icons.delete_forever_outlined),
              label: const Text('Excluir'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white),
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
}
