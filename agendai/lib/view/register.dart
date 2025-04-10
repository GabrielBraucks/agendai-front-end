import 'package:agendai/presenter/register_presenter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final employerIdentificationController = TextEditingController();
  final employernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Consumer<RegisterPresenter>(
        builder: (context, presenter, child) {
          return LayoutBuilder(builder: (context, constraints) {
            double width = constraints.maxWidth;
            return Center(
              child: Container(
                width: width < 600 ? width * 0.9 : 450,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_balance_rounded,
                      size: 35,
                      color: Color(0xFF620096),
                    ),
                    const Text(
                      'Vamos começar!',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 30,
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: employerIdentificationController,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      decoration: const InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(
                              0xFF620096,
                            ),
                            width: 2.0,
                          ),
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Color(0xFF620096),
                        ),
                        border: OutlineInputBorder(),
                        labelText: 'CNPJ',
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: employernameController,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      decoration: const InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(
                              0xFF620096,
                            ),
                            width: 2.0,
                          ),
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Color(0xFF620096),
                        ),
                        border: OutlineInputBorder(),
                        labelText: 'Nome da empresa',
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: emailController,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      decoration: const InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(
                              0xFF620096,
                            ),
                            width: 2.0,
                          ),
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Color(0xFF620096),
                        ),
                        border: OutlineInputBorder(),
                        labelText: 'Email para contato',
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: passwordController,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      decoration: const InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(
                              0xFF620096,
                            ),
                            width: 2.0,
                          ),
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Color(0xFF620096),
                        ),
                        border: OutlineInputBorder(),
                        labelText: 'Senha',
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: confirmPasswordController,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      decoration: const InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(
                              0xFF620096,
                            ),
                            width: 2.0,
                          ),
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Color(0xFF620096),
                        ),
                        border: OutlineInputBorder(),
                        labelText: 'Confirmar senha',
                      ),
                    ),
                    const SizedBox(height: 40),
                    Align(
                      alignment: Alignment.topRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF620096), // cor do botão
                          foregroundColor: Colors.white, // cor do texto/ícone
                        ),
                        onPressed: () {
                          if (passwordController.text ==
                              confirmPasswordController.text) {
                            register(presenter);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Senhas não coincidem!')),
                            );
                          }
                        },
                        child: const Text('Cadastrar'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Future<void> register(RegisterPresenter presenter) async {
    String employerIdentification = employerIdentificationController.text;
    String employername = employernameController.text;
    String email = emailController.text;
    String password = passwordController.text;
    final result = await presenter.register(
      employerIdentification: employerIdentification,
      employername: employername,
      email: email,
      password: password,
    );
    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastro bem-sucedido!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastro inválido!')),
      );
    }
  }
}
