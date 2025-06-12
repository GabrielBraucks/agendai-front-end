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
      backgroundColor: const Color(0xFFF0F2F5), // A soft, neutral background
      body: Center(
        child: Consumer<LoginPresenter>(
          builder: (context, presenter, child) {
            if (presenter.loadingLogin) {
              return const Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Container(
                    width: 1100, // Max width for the card
                    clipBehavior: Clip.antiAlias, // Ensures content respects the border radius
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 800) {
                          // Desktop layout
                          return Row(
                            children: [
                              _buildBrandingSide(),
                              Expanded(
                                child: _buildLoginForm(presenter),
                              ),
                            ],
                          );
                        } else {
                          // Mobile layout
                          return _buildLoginForm(presenter);
                        }
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBrandingSide() {
    return Expanded(
      child: Container(
        color: const Color(0xFF6366F1), // Primary brand color
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.event_available_rounded, color: Colors.white, size: 60),
            const SizedBox(height: 24),
            const Text(
              'Agendai',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Gerencie seus agendamentos de forma simples e eficiente.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withOpacity(0.85),
                fontFamily: 'Inter',
              ),
            ),
            // You can add an image here as well
            // Padding(
            //   padding: const EdgeInsets.only(top: 40.0),
            //   child: Image.asset('your_illustration.png'),
            // )
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm(LoginPresenter presenter) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Bem-vindo de volta!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A202C),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Faça login para continuar.',
            style: TextStyle(fontSize: 16, color: Color(0xFF718096)),
          ),
          const SizedBox(height: 40),
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: 'E-mail',
              prefixIcon: const Icon(Icons.alternate_email_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFCBD5E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
              ),
              filled: true,
              fillColor: const Color(0xFFF7FAFC),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: passwordController,
            obscureText: isObscured,
            decoration: InputDecoration(
              labelText: 'Senha',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                onPressed: () => setState(() => isObscured = !isObscured),
                icon: Icon(
                  isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: const Color(0xFF718096),
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFCBD5E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
              ),
              filled: true,
              fillColor: const Color(0xFFF7FAFC),
            ),
          ),
          if (presenter.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              presenter.errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade700, fontSize: 14),
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => login(presenter),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              shadowColor: const Color(0xFF6366F1).withOpacity(0.4),
            ),
            child: const Text('Entrar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Não tem uma conta?', style: TextStyle(color: Color(0xFF718096))),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text(
                  'Crie agora',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> login(LoginPresenter presenter) async {
    String email = emailController.text;
    String password = passwordController.text;
    final result = await presenter.login(username: email, password: password);
    if (result && mounted) {
      Navigator.pushReplacementNamed(context, '/service');
    }
    // The error message is handled by the consumer, so no need for a ScaffoldMessenger here.
  }
}
