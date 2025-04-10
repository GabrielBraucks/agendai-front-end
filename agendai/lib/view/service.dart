import 'package:agendai/presenter/servico_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class Service extends StatefulWidget {
  const Service({super.key});

  @override
  State<Service> createState() => _TodoState();
}

class _TodoState extends State<Service> {
  final nameController = TextEditingController();
  final durationController = TextEditingController();
  final categoryController = TextEditingController();
  final valueController = TextEditingController();
  // String selectedColor = "#FFF2CC"; // Cor padrão pastel

  // final List<String> pastelColors = [
  //   "#FFF2CC", // Amarelo pastel
  //   "#FFD9F0", // Rosa pastel
  //   "#E8C5FF", // Roxo pastel
  //   "#CAFBFF", // Azul pastel
  //   "#E3FFE6", // Verde pastel
  // ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Novo Servico',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(30),
          child: Consumer<ServicePresenter>(
            builder: (context, presenter, child) {
              if (presenter.loadingService) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: 'Nome',
                    ),
                  ),
                  TextField(
                    controller: valueController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly, // Apenas números
                    ],
                    decoration: const InputDecoration(
                      hintText: 'Valor',
                    ),
                  ),
                  TextField(
                    controller: durationController,
                    decoration: const InputDecoration(
                      hintText: 'Duracao',
                    ),
                  ),
                  TextField(
                    controller: categoryController,
                    decoration: const InputDecoration(
                      hintText: 'Categoria',
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        tooltip: 'Remover serviço',
                        iconSize: 100,
                      ),
                      const SizedBox(width: 60),
                      IconButton(
                        icon: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 80,
                        ),
                        onPressed: () async {
                          final name = nameController.text;
                          final value = int.tryParse(valueController.text) ?? 0;
                          final duration = durationController.text;
                          final category = categoryController.text;

                          if (name.isNotEmpty &&
                              duration.isNotEmpty &&
                              category.isNotEmpty) {
                            await context
                                .read<ServicePresenter>()
                                .createService(
                                  name: name,
                                  value: value,
                                  duration: duration,
                                  category: category,
                                );

                            Navigator.pop(context, true);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Preencha todos os campos!')),
                            );
                          }
                        },
                        tooltip: 'Adicionar serviço',
                        iconSize: 100,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
