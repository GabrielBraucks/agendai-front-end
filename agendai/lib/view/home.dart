import 'package:agendai/presenter/home_presenter.dart';
import 'package:agendai/view/customers.dart';
import 'package:agendai/view/employees.dart';
import 'package:agendai/view/scheduling.dart';
import 'package:agendai/view/service.dart';
import 'package:agendai/widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  final String initialPage;

  const Home({
    super.key,
    this.initialPage = 'Início',
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String currentPage = 'Início';

  @override
  void initState() {
    super.initState();
    currentPage = widget.initialPage;
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _getSelectedWidget() {
    switch (currentPage) {
      case 'Dashboard':
        return const Center(child: Text('Dashboard em desenvolvimento'));
      case 'Início':
        return const Scheduling();
      case 'Serviços':
        return const Service();
      case 'Funcionários':
        return const Employees();
      case 'Clientes':
        return const Customers();
      case 'Agendamento':
        return const Scheduling();
      case 'Relatórios':
        return const Center(child: Text('Relatórios em desenvolvimento'));
      case 'Conexões':
        return const Center(child: Text('Conexões em desenvolvimento'));
      default:
        return const Scaffold(
          body: Center(
            child: Text('Página não encontrada'),
          ),
        );
    }
  }

  void _handleNavigation(String page) {
    setState(() {
      currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Row(
      children: [
        SidebarWithNavigation(
          selected: currentPage,
          onNavigate: _handleNavigation,
        ),
        Expanded(
          child: Consumer<HomePresenter>(
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
        ),
      ],
    ));
  }
}

// Extension of Sidebar that includes navigation callback
class SidebarWithNavigation extends StatelessWidget {
  final String selected;
  final Function(String) onNavigate;
  final bool initiallyCollapsed;

  const SidebarWithNavigation({
    super.key,
    required this.selected,
    required this.onNavigate,
    this.initiallyCollapsed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Sidebar(
      selected: selected,
      initiallyCollapsed: initiallyCollapsed,
      onNavigate: (page) {
        // Intercept navigation and pass to parent
        onNavigate(page);
      },
    );
  }
}
