import 'package:agendai/presenter/employees_register_presenter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmployeesRegister extends StatefulWidget {
  const EmployeesRegister({super.key});

  @override
  State<EmployeesRegister> createState() => _EmployeesRegistertate();
}

class _EmployeesRegistertate extends State<EmployeesRegister> {
  final nameController = TextEditingController();
  final cpfController = TextEditingController();
  final jobTitleController = TextEditingController();
  final emailController = TextEditingController();
  final celPhoneController = TextEditingController();
  final passwordController = TextEditingController();
  final birthdayController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Cadastro funcionário'),
      ),
      body: Consumer<EmployeesRegisterPresenter>(
        builder: (context, presenter, child) {
          if (presenter.loadingPage) {
            return const Center(child: CircularProgressIndicator());
          }

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.design_services,
                    size: 200,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 24),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
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
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: cpfController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'CPF',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: jobTitleController,
                              decoration: const InputDecoration(
                                labelText: 'Trabalho',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: emailController,
                              decoration: const InputDecoration(
                                labelText: 'E-mail',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: celPhoneController,
                              decoration: const InputDecoration(
                                labelText: 'Celular',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // TextFormField(
                            //   controller: birthdayController,
                            //   decoration: const InputDecoration(
                            //     labelText: 'Aniversário',
                            //     border: OutlineInputBorder(),
                            //   ),
                            // ),
                            TextFormField(
                              controller: birthdayController,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'Aniversário (AAAA-MM-DD)',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              onTap: () async {
                                final DateTime? pickedDate =
                                    await showDatePicker(
                                  context: context,
                                  initialDate: DateTime(2000),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                );
                                if (pickedDate != null) {
                                  final formattedDate =
                                      "${pickedDate.year.toString().padLeft(4, '0')}"
                                      "-${pickedDate.month.toString().padLeft(2, '0')}"
                                      "-${pickedDate.day.toString().padLeft(2, '0')}";
                                  birthdayController.text = formattedDate;
                                }
                              },
                            ),

                            const SizedBox(height: 16),
                            TextFormField(
                              controller: passwordController,
                              decoration: const InputDecoration(
                                labelText: 'Categoria',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.close,
                                      color: Colors.red),
                                  label: const Text(
                                    'Cancelar',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[300],
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                ),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.check),
                                  label: const Text('Salvar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.primaryColor,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () async {
                                    final name = nameController.text;
                                    final cpf = cpfController.text;
                                    final jobTitle = jobTitleController.text;
                                    final email = emailController.text;
                                    final celPhone = celPhoneController.text;
                                    final password = passwordController.text;
                                    final birthday = birthdayController.text;

                                    if (name.isNotEmpty &&
                                        cpf.isNotEmpty &&
                                        jobTitle.isNotEmpty) {
                                      await context
                                          .read<EmployeesRegisterPresenter>()
                                          .registerEmployee(
                                            name: name,
                                            cpf: cpf,
                                            jobTitle: jobTitle,
                                            email: email,
                                            celPhone: celPhone,
                                            password: password,
                                            birthday: birthday,
                                          );

                                      Navigator.pop(context, true);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
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
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
