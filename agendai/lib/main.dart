import 'package:agendai/model/agendai_api.dart';
import 'package:agendai/presenter/connect_presenter.dart';
import 'package:agendai/presenter/customer_presenter.dart';
import 'package:agendai/presenter/employees_presenter.dart';
import 'package:agendai/presenter/employees_register_presenter.dart';
import 'package:agendai/presenter/home_presenter.dart';
import 'package:agendai/presenter/login_presenter.dart';
import 'package:agendai/presenter/register_presenter.dart';
import 'package:agendai/presenter/scheduling_presenter.dart';
import 'package:agendai/presenter/servico_presenter.dart';
import 'package:agendai/presenter/splash_presenter.dart';
import 'package:agendai/view/connect.dart';
import 'package:agendai/view/customers.dart';
import 'package:agendai/view/dashboard.dart';
import 'package:agendai/view/employees.dart';
import 'package:agendai/view/employees_register.dart';
import 'package:agendai/view/home.dart';
import 'package:agendai/view/login.dart';
import 'package:agendai/view/register.dart';
import 'package:agendai/view/scheduling.dart';
import 'package:agendai/view/service.dart';
import 'package:agendai/view/service_register.dart';
import 'package:agendai/view/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'theme.dart';

void main() {
  initializeDateFormatting('pt_BR', null).then((_) {
    final api = AgendaiApi();
    runApp(
      MultiProvider(
        // Fornece o AgendApi para todos os presenters
        providers: [
          ChangeNotifierProvider(create: (_) => LoginPresenter(api: api)),
          ChangeNotifierProvider(create: (_) => ConnectPresenter(api: api)),
          ChangeNotifierProvider(create: (_) => HomePresenter(api: api)),
          ChangeNotifierProvider(create: (_) => SplashPresenter(api: api)),
          ChangeNotifierProvider(create: (_) => RegisterPresenter(api: api)),
          ChangeNotifierProvider(create: (_) => ServicePresenter(api: api)),
          ChangeNotifierProvider(create: (_) => EmployeesPresenter(api: api)),
          ChangeNotifierProvider(create: (_) => CustomersPresenter(api: api)),
          ChangeNotifierProvider(
              create: (_) => EmployeesRegisterPresenter(api: api)),
          ChangeNotifierProvider(create: (_) => SchedulingPresenter(api: api)),
        ],
        child: const MyApp(),
      ),
    );
  });
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
      themeMode: ThemeMode.light,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('pt', 'BR'),
      initialRoute: '/',
      routes: {
        '/': (_) => const Splash(),
        '/login': (context) => const Login(),
        '/register': (context) => const Register(),
        '/home': (context) => const Scheduling(),
        '/service': (context) => const Service(),
        '/customers': (context) => const Customers(),
        '/connections': (context) => const Connect(),
        '/dashboard': (context) => const Dashboard(),
        '/service-register': (context) => const ServiceRegister(),
        '/employees': (context) => const Employees(),
        '/employee-register': (context) => const EmployeesRegister(),
        '/scheduling': (context) => const Scheduling(),
      },
    );
  }
}
