// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class Loading extends StatefulWidget {
//   @override
//   _LoadingState createState() => _LoadingState();
// }

// class _LoadingState extends State<Loading> {
//   @override
//   void initState() {
//     super.initState();
//     _checkAuth();
//   }

//   Future<void> _checkAuth() async {
//     // Simulação de checagem do JWT token no SharedPreferences
//     final prefs = await SharedPreferences.getInstance();
//     final jwtToken = prefs.getString('jwtToken');

//     // Se o token existir e for válido, redireciona para a home
//     if (jwtToken != null && jwtToken.isNotEmpty) {
//       Navigator.pushReplacementNamed(context, '/home');
//     } else {
//       // Caso contrário, redireciona para a tela de login
//       Navigator.pushReplacementNamed(context, '/login');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(child: CircularProgressIndicator()),
//     );
//   }
// }

import 'package:agendai/presenter/splash_presenter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});
  @override
  SplashState createState() => SplashState();
}

class SplashState extends State<Splash> {
  @override
  void initState() {
    _checkAuth();
    super.initState();
  }

  Future<void> _checkAuth() async {
    final splashPresenter =
        Provider.of<SplashPresenter>(context, listen: false);

    if (await splashPresenter.getToken() != null) {
      print('Token presente, redireciona para a home');
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      print('Sem token, redireciona para a tela de login');
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
