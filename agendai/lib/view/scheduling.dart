import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Scheduling extends StatefulWidget {
  const Scheduling({super.key});

  @override
  State<Scheduling> createState() => _SchedulingState();
}

class _SchedulingState extends State<Scheduling> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Map<DateTime, List<String>> _events = {
    DateTime.utc(2025, 3, 31): ['teste'],
    DateTime.utc(2025, 4, 7): ['teste'],
    DateTime.utc(2025, 4, 9): ['teste'],
    DateTime.utc(2025, 4, 10): ['teste2'],
    DateTime.utc(2025, 4, 11): ['teste'],
    DateTime.utc(2025, 4, 14): ['teste2'],
    DateTime.utc(2025, 4, 18): ['teste'],
    DateTime.utc(2025, 4, 20): ['teste'],
    DateTime.utc(2025, 4, 21): ['teste'],
    DateTime.utc(2025, 4, 22): ['teste'],
    DateTime.utc(2025, 4, 30): ['teste'],
    DateTime.utc(2025, 5, 1): ['teste'],
  };

  List<String> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendamentos'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              double cellWidth =
                  (constraints.maxWidth - 12) / 7; // 7 dias da semana
              const double desiredRowHeight =
                  60.0; // Defina a altura desejada para cada linha

              return TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                eventLoader: _getEventsForDay,

                // Calendar Style
                calendarStyle: CalendarStyle(
                  markerMargin: const EdgeInsets.symmetric(horizontal: 1.0),
                  isTodayHighlighted: true,
                  selectedDecoration: const BoxDecoration(
                    color: Colors.deepPurple,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: const BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  weekendTextStyle: const TextStyle(color: Colors.grey),
                  defaultTextStyle: const TextStyle(color: Colors.white),
                  outsideTextStyle: const TextStyle(color: Colors.grey),
                  cellMargin: const EdgeInsets.symmetric(horizontal: 6.0),
                  cellPadding: EdgeInsets.zero,
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
                  leftChevronIcon:
                      Icon(Icons.chevron_left, color: Colors.white),
                  rightChevronIcon:
                      Icon(Icons.chevron_right, color: Colors.white),
                ),

                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    return SizedBox(
                      height: desiredRowHeight,
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                  markerBuilder: (context, date, events) {
                    if (events.isEmpty)
                      return const SizedBox(height: desiredRowHeight);
                    return SizedBox(
                      height: desiredRowHeight,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: events.map((e) {
                            final String event = e.toString();
                            return Container(
                              margin: const EdgeInsets.only(top: 2),
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: event.contains("teste2")
                                    ? const Color.fromARGB(153, 255, 174, 242)
                                    : event.contains("teste") ||
                                            event.contains("teste")
                                        ? Colors.lightBlue
                                        : Colors.green,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                event,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
