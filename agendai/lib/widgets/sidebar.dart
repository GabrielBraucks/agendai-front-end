import 'package:flutter/material.dart';

class Sidebar extends StatefulWidget {
  final String selected;
  final bool initiallyCollapsed;

  const Sidebar({
    super.key,
    this.selected = 'Clientes', // Default selected item
    this.initiallyCollapsed = false,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  late bool _isCollapsed;

  @override
  void initState() {
    super.initState();
    _isCollapsed = widget.initiallyCollapsed;
  }

  void _toggleSidebar() {
    setState(() {
      _isCollapsed = !_isCollapsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define colors based on the new design
    const Color sidebarBackgroundColor = Color(0xFF0F1E54); // Dark blue
    const Color selectedItemColor = Color(0xFF2C7BE5); // Lighter blue for selected
    const Color iconAndTextColor = Colors.white;
    const Color hoverColor = Color(0xFF1A357B); // Slightly lighter blue for hover

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _isCollapsed ? 80 : 260,
      color: sidebarBackgroundColor,
      padding: EdgeInsets.symmetric(vertical: _isCollapsed ? 10 : 20),
      child: Column(
        crossAxisAlignment: _isCollapsed ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          // Header: Logo and Toggle Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: _isCollapsed ? 0 : 20.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: _isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
              children: [
                if (!_isCollapsed)
                  Row(
                    children: [
                      // Placeholder for a more elaborate logo if needed
                      Image.asset(
                        'assets/logo_leaf_white.png', // Replace with your actual asset path
                        height: 28,
                        errorBuilder: (context, error, stackTrace) => 
                          const Icon(Icons.eco, color: iconAndTextColor, size: 28), // Fallback icon
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Agendai', // Or "Cacau Sys." as in one image
                        style: TextStyle(
                          color: iconAndTextColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                IconButton(
                  icon: Icon(
                    _isCollapsed ? Icons.menu_open : Icons.menu,
                    color: iconAndTextColor,
                    size: 28,
                  ),
                  onPressed: _toggleSidebar,
                  tooltip: _isCollapsed ? 'Expandir menu' : 'Recolher menu',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Navigation Items
          Expanded(
            child: ListView(
              children: [
                _buildNavItem(
                  context,
                  icon: Icons.dashboard_outlined,
                  title: 'Dashboard',
                  route: '/dashboard', // Example route
                  selected: widget.selected == 'Dashboard',
                  isCollapsed: _isCollapsed,
                  selectedColor: selectedItemColor,
                  iconTextColor: iconAndTextColor,
                  hoverColor: hoverColor,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.home_outlined, // Changed from Icons.home
                  title: 'Início',
                  route: '/home',
                  selected: widget.selected == 'Início',
                  isCollapsed: _isCollapsed,
                  selectedColor: selectedItemColor,
                  iconTextColor: iconAndTextColor,
                  hoverColor: hoverColor,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.design_services_outlined, // Changed from Icons.design_services
                  title: 'Serviços',
                  route: '/service',
                  selected: widget.selected == 'Serviços',
                  isCollapsed: _isCollapsed,
                  selectedColor: selectedItemColor,
                  iconTextColor: iconAndTextColor,
                  hoverColor: hoverColor,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.groups_outlined, // Changed from Icons.settings (or people)
                  title: 'Funcionários',
                  route: '/employees',
                  selected: widget.selected == 'Funcionarios', // Keep key consistent if used elsewhere
                  isCollapsed: _isCollapsed,
                  selectedColor: selectedItemColor,
                  iconTextColor: iconAndTextColor,
                  hoverColor: hoverColor,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.people_outline, // Changed from Icons.people
                  title: 'Clientes',
                  route: '/customers',
                  selected: widget.selected == 'Clientes',
                  isCollapsed: _isCollapsed,
                  selectedColor: selectedItemColor,
                  iconTextColor: iconAndTextColor,
                  hoverColor: hoverColor,
                ),
                 _buildNavItem(
                  context,
                  icon: Icons.calendar_today_outlined,
                  title: 'Agendamento',
                  route: '/scheduling', // Example route
                  selected: widget.selected == 'Agendamento',
                  isCollapsed: _isCollapsed,
                  selectedColor: selectedItemColor,
                  iconTextColor: iconAndTextColor,
                  hoverColor: hoverColor,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.bar_chart_outlined,
                  title: 'Relatórios',
                  route: '/reports', // Example route
                  selected: widget.selected == 'Relatorios',
                  isCollapsed: _isCollapsed,
                  selectedColor: selectedItemColor,
                  iconTextColor: iconAndTextColor,
                  hoverColor: hoverColor,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.share_outlined,
                  title: 'Conexões',
                  route: '/connections', // Example route
                  selected: widget.selected == 'Conexoes',
                  isCollapsed: _isCollapsed,
                  selectedColor: selectedItemColor,
                  iconTextColor: iconAndTextColor,
                  hoverColor: hoverColor,
                ),
              ],
            ),
          ),

          // User Profile Section
          if (!_isCollapsed) const Divider(color: Colors.white24, height: 1),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: _isCollapsed ? 0 : 16.0, vertical: 12.0),
            child: _isCollapsed
                ? IconButton(
                    icon: const CircleAvatar(
                      // backgroundImage: AssetImage('assets/user_avatar.png'), // Replace with your asset
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person_outline, color: iconAndTextColor),
                    ),
                    onPressed: () {
                      // TODO: Implement user profile action for collapsed state
                    },
                    tooltip: 'Perfil do Usuário',
                  )
                : Row(
                    children: [
                      const CircleAvatar(
                        // backgroundImage: AssetImage('assets/user_avatar.png'), // Replace with your asset
                        backgroundColor: Colors.white24,
                        radius: 20,
                        child: Icon(Icons.person_outline, color: iconAndTextColor, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Nome do Usuário', // Replace with actual user name
                              style: TextStyle(
                                color: iconAndTextColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'username', // Replace with actual username or role
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: iconAndTextColor),
                        onPressed: () {
                          // TODO: Implement user settings menu
                        },
                        tooltip: 'Opções do Usuário',
                      ),
                    ],
                  ),
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
    required bool isCollapsed,
    required Color selectedColor,
    required Color iconTextColor,
    required Color hoverColor,
  }) {
    return Material(
      color: selected ? selectedColor : Colors.transparent,
      child: InkWell(
        onTap: () {
          if (ModalRoute.of(context)?.settings.name != route) {
            Navigator.pushReplacementNamed(context, route);
          }
        },
        hoverColor: hoverColor,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 10 : 16,
            vertical: isCollapsed ? 12 : 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: selected ? selectedColor : Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Icon(icon, color: iconTextColor, size: 24),
              if (!isCollapsed) ...[
                const SizedBox(width: 16),
                Expanded( // Added Expanded here
                  child: Text(
                    title,
                    style: TextStyle(
                      color: iconTextColor,
                      fontSize: 14.5,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis, // Prevent text overflow
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
