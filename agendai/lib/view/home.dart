import 'package:agendai/presenter/home_presenter.dart';
import 'package:agendai/view/dashboard.dart';
import 'package:agendai/view/employees.dart';
import 'package:agendai/view/scheduling.dart';
import 'package:agendai/view/service.dart';
import 'package:agendai/widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late AnimationController _controller;
  int selectedIndex = 0; // Começa com Serviços selecionado

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  @override
  void initState() {
    //final presenter = Provider.of<HomePresenter>(context, listen: false);
    // Future.delayed(Duration.zero).then((value) {
    //   presenter.getServicos();
    // });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _getSelectedWidget() {
    switch (selectedIndex) {
      case 0:
        return const Dashboard();
      case 1:
        return const Service();
      case 2:
        return const Employees();
      default:
        return const Scaffold(
          body: Center(
            child: Text('Página não encontrada'),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Row(
      children: [
        Consumer<HomePresenter>(
          builder: (context, presenter, child) {
            if (presenter.loadingHome) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return Expanded(
                child: Scheduling(),
              );
            }
          },
        ),
      ],
    ));
  }
}
