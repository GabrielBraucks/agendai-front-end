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
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    employerIdentificationController.dispose();
    employernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5), // A soft, neutral background
      body: Center(
        child: Consumer<RegisterPresenter>(
          builder: (context, presenter, child) {
            if (presenter.loadingRegister) {
              return const Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Container(
                    width: 1100, // Max width for the card
                    clipBehavior: Clip.antiAlias,
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
                                child: _buildRegisterForm(presenter),
                              ),
                            ],
                          );
                        } else {
                          // Mobile layout
                          return _buildRegisterForm(presenter);
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
              'Crie sua Conta',
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
              'Comece a organizar seu negócio hoje mesmo.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withOpacity(0.85),
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterForm(RegisterPresenter presenter) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Vamos Começar!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A202C),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Preencha os dados para se cadastrar.',
            style: TextStyle(fontSize: 16, color: Color(0xFF718096)),
          ),
          const SizedBox(height: 32),
          _buildTextField(
            controller: employernameController,
            label: 'Nome da Empresa',
            icon: Icons.store_mall_directory_outlined,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: employerIdentificationController,
            label: 'CNPJ',
            icon: Icons.business_center_outlined,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: emailController,
            label: 'E-mail de Contato',
            icon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _buildPasswordField(
            controller: passwordController,
            label: 'Senha',
            isObscured: _obscurePassword,
            toggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          const SizedBox(height: 16),
          _buildPasswordField(
            controller: confirmPasswordController,
            label: 'Confirmar Senha',
            isObscured: _obscureConfirmPassword,
            toggleObscure: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
          ),
          // if (presenter.errorMessage != null) ...[
          //   const SizedBox(height: 12),
          //   Text(
          //     presenter.errorMessage!,
          //     textAlign: TextAlign.center,
          //     style: TextStyle(color: Colors.red.shade700, fontSize: 14),
          //   ),
          // ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (passwordController.text == confirmPasswordController.text) {
                register(presenter);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('As senhas não coincidem!'),
                  backgroundColor: Colors.red,
                ));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              shadowColor: const Color(0xFF6366F1).withOpacity(0.4),
            ),
            child: const Text('CADASTRAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Já possui uma conta?', style: TextStyle(color: Color(0xFF718096))),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Faça login',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF718096)),
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
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isObscured,
    required VoidCallback toggleObscure,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscured,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF718096)),
        suffixIcon: IconButton(
          onPressed: toggleObscure,
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
    );
  }

  Future<void> register(RegisterPresenter presenter) async {
    final result = await presenter.register(
      employerIdentification: employerIdentificationController.text,
      employername: employernameController.text,
      email: emailController.text,
      password: passwordController.text,
    );
    if (result && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastro realizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Go back to the login screen
    }
    // Error messages are handled by the Consumer
  }
}
