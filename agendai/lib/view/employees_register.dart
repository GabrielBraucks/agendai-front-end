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

    return Consumer<EmployeesRegisterPresenter>(
      builder: (context, presenter, child) {
        if (presenter.loadingPage) {
          return const Center(child: CircularProgressIndicator());
        }

        return Center(
          child: SingleChildScrollView(
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
                          Icons.person,
                          size: 100,
                        ),
                        const Text(
                          'Preencha as informações do funcionário',
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
                          controller: cpfController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'CPF',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: jobTitleController,
                          decoration: const InputDecoration(
                            labelText: 'Trabalho',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: 'E-mail',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: celPhoneController,
                          decoration: const InputDecoration(
                            labelText: 'Celular',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: birthdayController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Aniversário (AAAA-MM-DD)',
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          onTap: () async {
                            final DateTime? pickedDate = await showDatePicker(
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
                            TextButton.icon(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              label: const Text(
                                'Cancelar',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.check),
                              label: const Text('Salvar'),
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
