import 'package:agendai/widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Assume que o widget Sidebar está em 'sidebar_widget.dart' ou similar
// import 'sidebar_widget.dart'; // Descomente se você tiver o Sidebar em um arquivo separado

// Placeholder Sidebar Widget (se não estiver importando de outro arquivo)


class Appointment {
  final String clientName;
  final String service;
  final DateTime time;
  final String professional;

  Appointment({
    required this.clientName,
    required this.service,
    required this.time,
    required this.professional,
  });
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // Dados de exemplo
  final int _appointmentsToday = 7;
  final double _totalRevenueToday = 350.75;
  final int _newClientsThisWeek = 3;

  final List<Appointment> _upcomingAppointments = [
    Appointment(clientName: "Ana Silva", service: "Corte de Cabelo", time: DateTime.now().add(const Duration(hours: 1)), professional: "Juliana"),
    Appointment(clientName: "Beatriz Costa", service: "Manicure e Pedicure", time: DateTime.now().add(const Duration(hours: 2, minutes: 30)), professional: "Fernanda"),
    Appointment(clientName: "Carla Dias", service: "Coloração", time: DateTime.now().add(const Duration(hours: 4)), professional: "Mariana"),
    Appointment(clientName: "Sofia Lima", service: "Escova Progressiva", time: DateTime.now().add(const Duration(days:1, hours: 10)), professional: "Juliana"),
  ];

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  Icon(icon, color: color, size: 28),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

   Widget _buildQuickActionButton(String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo.shade400,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: onPressed,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Row(
        children: [
          const Sidebar(selected: 'Dashboard'), // Barra lateral
          Expanded(
            child: Column(
              children: [
                // Barra Superior do Conteúdo Principal (semelhante à da página de agendamento)
                _buildDashboardTopBar(),
                // Conteúdo Principal do Dashboard
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Seção de Resumo
                        Row(
                          children: [
                            _buildSummaryCard("Agendamentos Hoje", _appointmentsToday.toString(), Icons.calendar_today_outlined, Colors.indigo.shade500),
                            const SizedBox(width: 16),
                            _buildSummaryCard("Receita Hoje", "R\$ ${NumberFormat.currency(locale: 'pt_BR', symbol: '').format(_totalRevenueToday)}", Icons.attach_money_outlined, Colors.green.shade500),
                            const SizedBox(width: 16),
                            _buildSummaryCard("Novos Clientes (Semana)", _newClientsThisWeek.toString(), Icons.person_add_alt_1_outlined, Colors.blue.shade500),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Seção de Ações Rápidas
                        Text(
                          "Ações Rápidas",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 12),
                        Wrap( // Usar Wrap para melhor responsividade dos botões
                          spacing: 16.0,
                          runSpacing: 12.0,
                          children: [
                             _buildQuickActionButton("Novo Agendamento", Icons.add_circle_outline, () {
                                // Lógica para novo agendamento
                             }),
                             _buildQuickActionButton("Ver Agenda Completa", Icons.event_note_outlined, () {
                                // Lógica para ver agenda
                             }),
                             _buildQuickActionButton("Registrar Venda", Icons.point_of_sale_outlined, () {
                                // Lógica para registrar venda
                             }),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Seção de Próximos Agendamentos
                        Text(
                          "Próximos Agendamentos",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 12),
                        _buildUpcomingAppointmentsList(),

                        // Poderia adicionar mais seções aqui, como gráficos, etc.
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          const Text(
            "Dashboard",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          // Ícone de Notificações (Exemplo)
          IconButton(
            icon: Badge(
              label: const Text('3'), // Número de notificações
              child: Icon(Icons.notifications_none_outlined, color: Colors.grey.shade700),
            ),
            onPressed: () {
              // Lógica para mostrar notificações
            },
          ),
          const SizedBox(width: 16),
          // Seção do perfil do utilizador (placeholder)
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.indigoAccent,
                child: Icon(Icons.person_outline, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Nome do Gerente",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Salão de Beleza XYZ",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.arrow_drop_down),
                onPressed: () {
                  // Lógica para o dropdown do perfil
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointmentsList() {
    if (_upcomingAppointments.isEmpty) {
      return const Card(
        elevation: 1,
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(child: Text("Nenhum agendamento próximo.")),
        ),
      );
    }
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        shrinkWrap: true, // Importante para ListView dentro de SingleChildScrollView
        physics: const NeverScrollableScrollPhysics(), // Desabilita rolagem própria do ListView
        itemCount: _upcomingAppointments.length > 3 ? 3 : _upcomingAppointments.length, // Mostrar no máximo 3 ou menos
        itemBuilder: (context, index) {
          final appointment = _upcomingAppointments[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.indigo.shade100,
              child: Text(
                DateFormat('HH:mm').format(appointment.time),
                style: TextStyle(fontSize: 12, color: Colors.indigo.shade700, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text("${appointment.clientName} - ${appointment.service}", style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text("Profissional: ${appointment.professional} | Dia: ${DateFormat('dd/MM').format(appointment.time)}"),
            trailing: const Icon(Icons.chevron_right_outlined, color: Colors.grey),
            onTap: () {
              // Lógica para ver detalhes do agendamento
            },
          );
        },
        separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
      ),
    );
  }
}

