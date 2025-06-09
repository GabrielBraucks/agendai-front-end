import 'package:agendai/presenter/login_presenter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isObscured = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;
          return Consumer<LoginPresenter>(
            builder: (context, presenter, child) {
              if (presenter.loadingLogin) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              //Tela de login
              return Center(
                child: Container(
                  width: width < 600 ? width * 0.9 : 1000,
                  padding: const EdgeInsets.all(50),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 12,
                        offset: Offset(0, 8),
                      )
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.event,
                            size: 35,
                          ),
                          SizedBox(height: 15),
                          Text(
                            'Bem-vindo ao Agendai',
                            style: TextStyle(
                              fontSize: 30,
                            ),
                          ),
                          Text(
                            'Que bom que está aqui 😊',
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 50),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 400),
                                child: TextField(
                                  controller: emailController,
                                  decoration: const InputDecoration(
                                    labelText: 'E-mail',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 400),
                                child: TextField(
                                  obscureText: isObscured,
                                  controller: passwordController,
                                  decoration: InputDecoration(
                                    labelText: "Senha",
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          isObscured = !isObscured;
                                        });
                                      },
                                      icon: Icon(isObscured
                                          ? Icons.visibility
                                          : Icons.visibility_off),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (presenter.errorMessage != null) ...[
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    presenter.errorMessage!,
                                    textAlign: TextAlign.start,
                                    style:
                                        TextStyle(color: Colors.red.shade800),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/register');
                                  },
                                  child: const Text('Criar conta'),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    login(presenter);
                                  },
                                  child: const Text('Entrar'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> login(LoginPresenter presenter) async {
    String email = emailController.text;
    String password = passwordController.text;
    final result = await presenter.login(username: email, password: password);
    if (result) {
      Navigator.pushNamed(context, '/home');
    }
  }
}
