import 'package:agendai/entity/scheduling.dart' as entity;
import 'package:agendai/presenter/scheduling_presenter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kalender/kalender.dart';
import 'package:provider/provider.dart';

class Scheduling extends StatefulWidget {
  const Scheduling({super.key});

  @override
  State<Scheduling> createState() => _SchedulingState();
}

class _SchedulingState extends State<Scheduling> {
  final eventsController = DefaultEventsController();
  final calendarController = CalendarController();
  final tileComponents = TileComponents(
    tileBuilder: (event, renderProperties) => Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 5,
      ),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 187, 212, 255),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 10,
        ),
        child: Text(
          "Agendamento ${event.data}",
        ),
      ),
    ),
  );

  @override
  void initState() {
    super.initState();
    // Carregar agendamentos na inicialização
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadSchedulings();
    });
  }

  /// Carrega os agendamentos da API e adiciona ao calendário
  Future<void> loadSchedulings() async {
    final presenter = Provider.of<SchedulingPresenter>(context, listen: false);
    await presenter.getScheduling();

    // Limpar eventos existentes
    eventsController.clearEvents();

    // Adicionar cada agendamento como um evento
    for (var agendamento in presenter.scheduling) {
      addSchedulingEvent(agendamento);
    }
  }

  /// Adiciona um agendamento como evento no calendário
  void addSchedulingEvent(entity.Scheduling agendamento) {
    // Converter a string de data para DateTime
    final dateParts = agendamento.data.split('-');
    final timeParts = agendamento.horario.split(':');

    final date = DateTime(
      int.parse(dateParts[0]), // ano
      int.parse(dateParts[1]), // mês
      int.parse(dateParts[2]), // dia
      int.parse(timeParts[0]), // hora
      int.parse(timeParts[1]), // minuto
    );

    // Calcular duração em horas e minutos
    Duration duration;
    if (agendamento.duracao.contains(':')) {
      final durationParts = agendamento.duracao.split(':');
      duration = Duration(
        hours: int.parse(durationParts[0]),
        minutes: int.parse(durationParts[1]),
      );
    } else {
      // Caso a duração esteja apenas em minutos
      duration = Duration(minutes: int.parse(agendamento.duracao));
    }

    eventsController.addEvent(CalendarEvent(
      dateTimeRange: DateTimeRange(
        start: date,
        end: date.add(duration),
      ),
      data: agendamento.nomeServico,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ValueListenableBuilder<DateTimeRange>(
          valueListenable: calendarController.visibleDateTimeRange,
          builder: (context, dateTimeRange, _) {
            // Formatar o mês e ano em português
            final mesAno =
                DateFormat('MMMM yyyy', 'pt_BR').format(dateTimeRange.start);
            // Converter primeira letra para maiúscula
            final mesCapitalizado =
                mesAno[0].toUpperCase() + mesAno.substring(1);
            return Text(mesCapitalizado);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_left),
            onPressed: () {
              // Navegar para o mês anterior
              calendarController.animateToPreviousPage();
              setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_right),
            onPressed: () {
              // Navegar para o próximo mês
              calendarController.animateToNextPage();
              setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Recarregar agendamentos
              loadSchedulings();
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Mostrar diálogo para selecionar a data do evento
              _showAddEventDialog();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(40),
        child:
            Consumer<SchedulingPresenter>(builder: (context, presenter, child) {
          if (presenter.loadingScheduling) {
            return const Center(child: CircularProgressIndicator());
          }
          return CalendarView(
            eventsController: eventsController,
            calendarController: calendarController,
            viewConfiguration: MonthViewConfiguration.singleMonth(),
            callbacks: CalendarCallbacks(
              onEventCreated: (event) => eventsController.addEvent(event),
            ),
            header: CalendarHeader(
              multiDayTileComponents: tileComponents,
            ),
            body: CalendarBody(
              multiDayTileComponents: tileComponents,
              monthTileComponents: tileComponents,
            ),
          );
        }),
      ),
    );
  }

  // Mostrar diálogo para adicionar evento
  void _showAddEventDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController cpfController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    int duration = 1;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.event_available,
                  color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              const Text('Novo Agendamento'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 0,
                  color: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Serviço',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 1,
                              child: Text('Corte de Cabelo'),
                            ),
                          ],
                          hint: const Text('Selecione um serviço'),
                          onChanged: (value) {},
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 0,
                  color: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 18,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Informações do Cliente',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Nome',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: phoneController,
                          decoration: InputDecoration(
                            labelText: 'Telefone',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.phone_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: cpfController,
                          decoration: InputDecoration(
                            labelText: 'CPF',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.badge_outlined),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 0,
                  color: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Data e Horário',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () async {
                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (pickedDate != null) {
                              setState(() {
                                selectedDate = pickedDate;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_month,
                                    color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat('dd/MM/yyyy').format(selectedDate),
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const Spacer(),
                                const Icon(Icons.arrow_drop_down,
                                    color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () async {
                            final TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (pickedTime != null) {
                              setState(() {
                                selectedTime = pickedTime;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time,
                                    color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                  '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const Spacer(),
                                const Icon(Icons.arrow_drop_down,
                                    color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Registrar o agendamento na API
                await context.read<SchedulingPresenter>().createScheduling(
                      idService: 1,
                      date: DateFormat('yyyy-MM-dd').format(selectedDate),
                      time:
                          "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}:00",
                      email: emailController.text,
                      cpf: cpfController.text,
                      name: nameController.text,
                      celPhone: phoneController.text,
                    );

                // Atualizar calendário
                await loadSchedulings();

                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Agendar'),
            ),
          ],
        );
      },
    );
  }
}

// Extensão para fornecer métodos auxiliares para DateTimex
// extension DateTimeExtension on DateTime {
//   DateTimeRange get yearRange {
//     final start = DateTime(year, 1, 1);
//     final end = DateTime(year + 1, 1, 1).subtract(const Duration(days: 1));
//     return DateTimeRange(start: start, end: end);
//   }
// }
