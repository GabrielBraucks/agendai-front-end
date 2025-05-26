import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final String selected;

  const Sidebar({super.key, this.selected = 'Serviços'});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: const Color.fromARGB(255, 247, 247, 247),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: RichText(
              text: TextSpan(
                  text: 'CRM',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.w500),
                  children: <TextSpan>[
                    TextSpan(
                      text: ' Agendai',
                      style: TextStyle(
                          color: const Color(0xFF0F1E54),
                          fontSize: 24,
                          fontWeight: FontWeight.w800),
                    )
                  ]),
            ),
          ),
          const SizedBox(height: 30),
          _buildNavItem(
            context,
            icon: Icons.home,
            title: 'Início',
            route: '/home',
            selected: selected == 'Início',
          ),
          _buildNavItem(
            context,
            icon: Icons.design_services,
            title: 'Serviços',
            route: '/service',
            selected: selected == 'Serviços',
          ),
          _buildNavItem(
            context,
            icon: Icons.settings,
            title: 'Funcionarios',
            route: '/employees',
            selected: selected == 'Funcionarios',
          ),
          _buildNavItem(
            context,
            icon: Icons.people,
            title: 'Clientes',
            route: '/customers',
            selected: selected == 'Clientes',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    required bool selected,
  }) {
    return ListTile(
      leading: Icon(icon, color: Color.fromARGB(255, 24, 24, 24)),
      title: Text(title,
          style: const TextStyle(color: Color.fromARGB(255, 24, 24, 24))),
      selected: selected,
      selectedTileColor: Colors.white24,
      onTap: () {
        if (ModalRoute.of(context)?.settings.name != route) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
    );
  }
}
