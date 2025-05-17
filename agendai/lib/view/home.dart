import 'package:agendai/presenter/home_presenter.dart';
import 'package:agendai/view/employees.dart';
import 'package:agendai/view/scheduling.dart';
import 'package:agendai/view/service.dart';
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
        return const Scheduling();
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.person, size: 40),
          tooltip: "Menu",
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: const Row(
          children: [
            Text(
              "AgendAi",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedIndex = 0;
                  });
                },
                child: Text(
                  'Agendamentos',
                  style: TextStyle(
                    fontSize: 16,
                    color: selectedIndex == 0 ? Colors.purple : Colors.black,
                    fontWeight: selectedIndex == 0
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedIndex = 1;
                  });
                },
                child: Text(
                  'Serviços',
                  style: TextStyle(
                    fontSize: 16,
                    color: selectedIndex == 1 ? Colors.purple : Colors.black,
                    fontWeight: selectedIndex == 1
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedIndex = 2;
                  });
                },
                child: Text(
                  'Funcionários',
                  style: TextStyle(
                    fontSize: 16,
                    color: selectedIndex == 2 ? Colors.purple : Colors.black,
                    fontWeight: selectedIndex == 2
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(
              right: 20,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.logout,
                size: 40,
              ),
              tooltip: "Logout",
              onPressed: () async {
                await context.read<HomePresenter>().logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
            ),
          ),
        ],
        shadowColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 100,
      ),
      body: Consumer<HomePresenter>(
        builder: (context, presenter, child) {
          if (presenter.loadingHome) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return _getSelectedWidget();
          }
        },
      ),
    );
  }
}
