import 'package:agendai/presenter/home_presenter.dart';
import 'package:agendai/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late AnimationController _controller;

  @override
  void initState() {
    final presenter = Provider.of<HomePresenter>(context, listen: false);
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
                await context.read<HomePresenter>().logout();
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
          child: Consumer<HomePresenter>(
            builder: (context, presenter, child) {
              if (presenter.loadingHome) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Column(
                children: [
                  Row(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          'Listagem de serviços',
                          style: TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: 500,
                              child: TextField(
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Colors.white,
                                  ),
                                  hintText: 'Busque palavras-chave',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: presenter.servicos.isEmpty
                        ? Center(
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
                                  'Você não possui nenhum serviço listado',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : GridView.count(
                            crossAxisCount:
                                MediaQuery.of(context).size.width > 1000
                                    ? 7
                                    : MediaQuery.of(context).size.width > 600
                                        ? 4
                                        : 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1,
                            children: List.generate(
                              presenter.servicos.length,
                              (index) {
                                final servicos = presenter.servicos[index];
                                final id = servicos.id;
                                final nome = servicos.nome;
                                final preco = servicos.preco;
                                final categoria = servicos.categoria;
                                final duracao = servicos.duracao;

                                return Card(
                                  color: Colors.blueGrey[700],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 5,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          nome,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          categoria,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.white70,
                                          ),
                                        ),
                                        const Spacer(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'R\$ $preco',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Text(
                                                  duracao,
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline_sharp,
                                                color: Colors.white,
                                              ),
                                              tooltip: "Deletar",
                                              // onPressed: () {
                                              //   //presenter.deleteServicos(id);

                                              // },
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      backgroundColor:
                                                          Colors.white,
                                                      title: const Text(
                                                        'Confirmar exclusão',
                                                        style: TextStyle(
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                      content: Text(
                                                        'Tem certeza que deseja excluir o serviço "$nome"?',
                                                        style: TextStyle(
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          child: const Text(
                                                            'Cancelar',
                                                            style: TextStyle(
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            presenter
                                                                .deleteServicos(
                                                                    id);
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical: 5,
                                                                    horizontal:
                                                                        25),
                                                          ),
                                                          child: const Text(
                                                            'Excluir',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 15,
                                                            ),
                                                          ),
                                                        ),
                                                        // TextButton(
                                                        //   child: const Text(
                                                        //     'Excluir',
                                                        //     style: TextStyle(
                                                        //         color:
                                                        //             Colors.red),
                                                        //   ),
                                                        //   onPressed: () {
                                                        //     presenter
                                                        //         .deleteServicos(
                                                        //             id);
                                                        //     Navigator.of(
                                                        //             context)
                                                        //         .pop();
                                                        //   },
                                                        // ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
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
              final result = await Navigator.pushNamed(context, '/service');
              if (result == true) {
                context.read<HomePresenter>().getServicos();
              }
            },
            tooltip: 'Adicionar serviço',
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
