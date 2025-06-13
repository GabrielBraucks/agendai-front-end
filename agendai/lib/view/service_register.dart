import 'package:agendai/presenter/servico_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ServiceRegister extends StatefulWidget {
  const ServiceRegister({super.key});

  @override
  State<ServiceRegister> createState() => _ServiceRegisterState();
}

class _ServiceRegisterState extends State<ServiceRegister> {
  final nameController = TextEditingController();
  final durationController = TextEditingController();
  final categoryController = TextEditingController();
  final valueController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<ServicePresenter>(
      builder: (context, presenter, child) {
        if (presenter.loadingService) {
          return const Center(child: CircularProgressIndicator());
        }

        return Center(
          child: SingleChildScrollView(
            //padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.design_services,
                          size: 200,
                        ),
                        const Text(
                          'Preencha as informações do serviço',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nome',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: valueController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}')),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Valor (em R\$)',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: durationController,
                          decoration: const InputDecoration(
                            labelText: 'Duração',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: categoryController,
                          decoration: const InputDecoration(
                            labelText: 'Categoria',
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.check),
                              label: const Text('Salvar'),
                              // style: ElevatedButton.styleFrom(
                              //   backgroundColor: theme.primaryColor,
                              //   padding: const EdgeInsets.symmetric(
                              //       horizontal: 20, vertical: 12),
                              //   shape: RoundedRectangleBorder(
                              //     borderRadius: BorderRadius.circular(12),
                              //   ),
                              // ),
                              onPressed: () async {
                                final name = nameController.text;
                                final value = double.tryParse(valueController
                                        .text
                                        .replaceAll(',', '.')) ??
                                    0.0;
                                final duration = durationController.text;
                                final category = categoryController.text;

                                if (name.isNotEmpty &&
                                    duration.isNotEmpty &&
                                    category.isNotEmpty) {
                                  await context
                                      .read<ServicePresenter>()
                                      .createServico(
                                        nome: name,
                                        preco: value,
                                        duracao: duration,
                                        categoria: category,
                                      );

                                  Navigator.pop(context, true);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Preencha todos os campos!'),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
