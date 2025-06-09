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
