import 'package:agendai/widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:agendai/presenter/connect_presenter.dart';
import 'package:provider/provider.dart';

class Connect extends StatefulWidget {
  const Connect({super.key});

  @override
  State<Connect> createState() => _ConnectState();
}

class _ConnectState extends State<Connect> {
  @override
  void initState() {
    super.initState();
    // It's good practice to fetch initial status here, maybe from the presenter
    // Provider.of<ConnectPresenter>(context, listen: false).fetchConnectionStatus();
  }

  @override
  Widget build(BuildContext context) {
    // Access the presenter from the provider
    final connectPresenter = Provider.of<ConnectPresenter>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: Row(
        children: [
          const Sidebar(selected: 'Conexoes'),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Conexões',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A202C)),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Integre seus serviços favoritos para automatizar seu fluxo de trabalho.',
                      style: TextStyle(fontSize: 16, color: Color(0xFF718096)),
                    ),
                    const SizedBox(height: 32),
                    if (connectPresenter.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      _buildGoogleConnectionCard(context, connectPresenter),
                    // You can add more cards for other services here
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the UI card for the Google Calendar connection using the presenter.
  Widget _buildGoogleConnectionCard(
      BuildContext context, ConnectPresenter presenter) {
    final bool isConnected = presenter.connectionStatus['google'] ?? false;
    // Using LayoutBuilder to create a responsive card layout.
    return Card(
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Use a column layout for narrow screens
            bool useColumnLayout = constraints.maxWidth < 450;
            return Flex(
              direction: useColumnLayout ? Axis.vertical : Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: useColumnLayout
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.network(
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1024px-Google_%22G%22_logo.svg.png',
                      height: 40,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.cloud_queue_rounded,
                            size: 40, color: Colors.grey);
                      },
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Google Agenda',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D3748))),
                        const SizedBox(height: 4),
                        Text(
                          isConnected ? 'Conectado' : 'Não conectado',
                          style: TextStyle(
                            fontSize: 14,
                            color: isConnected
                                ? Colors.green.shade600
                                : Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (useColumnLayout) const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      if (isConnected) {
                        await presenter.disconnectFromGoogle();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Desconectado do Google Agenda.'),
                            backgroundColor: Colors.orange));
                      } else {
                        await presenter.connectToGoogle();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text(
                                'Conexão com Google Agenda estabelecida.'),
                            backgroundColor: Colors.green));
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              'Não foi possível iniciar a conexão: ${e.toString()}'),
                          backgroundColor: Colors.red));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isConnected ? Colors.white : const Color(0xFF4285F4),
                    foregroundColor: isConnected
                        ? const Color(0xFF4A5568)
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: isConnected
                          ? BorderSide(color: Colors.grey.shade300)
                          : BorderSide.none,
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    elevation: 0,
                    minimumSize: useColumnLayout
                        ? const Size.fromHeight(48)
                        : null, // Makes button full-width in column layout
                  ),
                  child: Text(isConnected ? 'Desconectar' : 'Conectar'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
