import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blueGrey,
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text('Agenda'),
            onTap: () {
              Navigator.pushNamed(context, '/scheduling');
            },
          ),
          ListTile(
            leading: const Icon(Icons.all_inbox_rounded),
            title: const Text('Serviços'),
            onTap: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.accessibility_new_rounded),
            title: const Text('Funcionários'),
            onTap: () {
              Navigator.pushNamed(context, '/employees');
            },
          ),
        ],
      ),
    );
  }
}
