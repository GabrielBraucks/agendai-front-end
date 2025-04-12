import 'package:agendai/model/agendai_api.dart';
import 'package:agendai/presenter/employees_presenter.dart';
import 'package:agendai/presenter/employees_register_presenter.dart';
import 'package:agendai/presenter/home_presenter.dart';
import 'package:agendai/presenter/login_presenter.dart';
import 'package:agendai/presenter/register_presenter.dart';
import 'package:agendai/presenter/servico_presenter.dart';
import 'package:agendai/presenter/splash_presenter.dart';
import 'package:agendai/view/employees.dart';
import 'package:agendai/view/employees_register.dart';
import 'package:agendai/view/home.dart';
import 'package:agendai/view/login.dart';
import 'package:agendai/view/register.dart';
import 'package:agendai/view/scheduling.dart';
import 'package:agendai/view/service.dart';
import 'package:agendai/view/splash.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme.dart';

void main() {
  final api = AgendaiApi();
  runApp(
    MultiProvider(
      // Fornece o AgendApi para todos os presenters
      providers: [
        ChangeNotifierProvider(create: (_) => LoginPresenter(api: api)),
        ChangeNotifierProvider(create: (_) => HomePresenter(api: api)),
        ChangeNotifierProvider(create: (_) => SplashPresenter(api: api)),
        ChangeNotifierProvider(create: (_) => RegisterPresenter(api: api)),
        ChangeNotifierProvider(create: (_) => ServicePresenter(api: api)),
        ChangeNotifierProvider(create: (_) => EmployeesPresenter(api: api)),
        ChangeNotifierProvider(
            create: (_) => EmployeesRegisterPresenter(api: api)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (_) => Splash(),
        '/login': (context) => const Login(),
        '/home': (context) => const Home(),
        '/register': (context) => const Register(),
        '/service': (context) => const Service(),
        '/employees': (context) => const Employees(),
        '/employee-form': (context) => const EmployeesRegister(),
        '/scheduling': (context) => const Scheduling(),
      },
    );
  }
}
