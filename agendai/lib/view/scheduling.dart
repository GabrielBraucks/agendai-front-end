import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kalender/kalender.dart';

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
        color: Colors.green,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 10,
        ),
        child: Text(
          event.data.toString(),
        ),
      ),
    ),
  );

  @override
  void initState() {
    super.initState();

    // Adicionar um evento de exemplo
    addEvents();
  }

  /// Add a [CalendarEvent] to the [EventsController].
  void addEvents() {
    final now = DateTime.now();
    addEventOnSpecificDate(
      now,
      "Evento de exemplo",
      const Duration(hours: 1),
    );
  }

  /// Add an event on a specific date and time
  void addEventOnSpecificDate(DateTime date, String title, Duration duration) {
    eventsController.addEvent(CalendarEvent(
      dateTimeRange: DateTimeRange(
          start: date,
          end: date.add(
            duration,
          )),
      data: title,
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
            icon: const Icon(Icons.add),
            onPressed: () {
              // Mostrar diálogo para selecionar a data do evento
              _showAddEventDialog();
              setState(() {});
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: CalendarView(
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
        ),
      ),
    );
  }

  // Mostrar diálogo para adicionar evento
  void _showAddEventDialog() {
    final TextEditingController titleController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    int duration = 1;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adicionar Evento'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título do evento',
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Data'),
                  subtitle: Text(
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  },
                ),
                ListTile(
                  title: const Text('Hora'),
                  subtitle: Text('${selectedTime.hour}:${selectedTime.minute}'),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (pickedTime != null) {
                      setState(() {
                        selectedTime = pickedTime;
                      });
                    }
                  },
                ),
                ListTile(
                  title: const Text('Duração (horas)'),
                  subtitle: Text('$duration'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (duration > 1) duration--;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            duration++;
                          });
                        },
                      ),
                    ],
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
            TextButton(
              onPressed: () {
                // Criar evento com a data e hora selecionadas
                final newDate = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );
                addEventOnSpecificDate(
                  newDate,
                  titleController.text.isNotEmpty
                      ? titleController.text
                      : 'Novo Evento',
                  Duration(hours: duration),
                );
                Navigator.of(context).pop();
                setState(() {});
              },
              child: const Text('Adicionar'),
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
