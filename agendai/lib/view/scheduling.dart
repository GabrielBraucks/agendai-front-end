import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Scheduling extends StatefulWidget {
  const Scheduling({super.key});

  @override
  State<Scheduling> createState() => _SchedulingState();
}

class _SchedulingState extends State<Scheduling> {
  DateTime _selectedDate = DateTime.now();
  String _viewMode = 'Mensal'; // 'Mensal' ou 'Semanal'
  final Map<DateTime, List<String>> _notes = {
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day): [
      'Reunião com a equipe às 14:00',
      'Lembrar de enviar relatório',
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildViewSelector(),
          _buildDateSelector(),
          Expanded(
            child: _viewMode == 'Mensal'
                ? _buildMonthlyView()
                : _buildWeeklyView(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNoteDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildViewSelector() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ChoiceChip(
            label: const Text('Mensal'),
            selected: _viewMode == 'Mensal',
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _viewMode = 'Mensal';
                });
              }
            },
          ),
          const SizedBox(width: 16),
          ChoiceChip(
            label: const Text('Semanal'),
            selected: _viewMode == 'Semanal',
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _viewMode = 'Semanal';
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2024),
                lastDate: DateTime(2025),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: Theme.of(context).colorScheme.primary,
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: Colors.black,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null && picked != _selectedDate) {
                setState(() {
                  _selectedDate = picked;
                });
              }
            },
            icon: const Icon(Icons.calendar_today),
            label: Text(
              _viewMode == 'Mensal'
                  ? DateFormat('MMMM yyyy').format(_selectedDate)
                  : 'Semana de ${DateFormat('dd/MM').format(_getWeekStart())}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    if (_viewMode == 'Mensal') {
                      _selectedDate = DateTime(
                        _selectedDate.year,
                        _selectedDate.month - 1,
                        1,
                      );
                    } else {
                      _selectedDate =
                          _selectedDate.subtract(const Duration(days: 7));
                    }
                  });
                },
                icon: const Icon(Icons.chevron_left),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    if (_viewMode == 'Mensal') {
                      _selectedDate = DateTime(
                        _selectedDate.year,
                        _selectedDate.month + 1,
                        1,
                      );
                    } else {
                      _selectedDate =
                          _selectedDate.add(const Duration(days: 7));
                    }
                  });
                },
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }

  DateTime _getWeekStart() {
    return _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
  }

  Widget _buildMonthlyView() {
    final firstDayOfMonth =
        DateTime(_selectedDate.year, _selectedDate.month, 1);
    final lastDayOfMonth =
        DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    return Column(
      children: [
        _buildWeekdayHeader(),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(4),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.2,
            ),
            itemCount: 42,
            itemBuilder: (context, index) {
              final adjustedIndex = index - (firstWeekday - 1);
              if (adjustedIndex < 0 || adjustedIndex >= daysInMonth) {
                return const SizedBox();
              }

              final day = DateTime(
                _selectedDate.year,
                _selectedDate.month,
                adjustedIndex + 1,
              );
              final dayNotes =
                  _notes[DateTime(day.year, day.month, day.day)] ?? [];
              final isToday = isSameDay(day, DateTime.now());
              final isSelected = isSameDay(day, _selectedDate);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = day;
                  });
                },
                child: Card(
                  elevation: isSelected ? 4 : 1,
                  color: isToday
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : null,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedDate = day;
                      });
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Theme.of(context)
                                    .dividerColor
                                    .withOpacity(0.1),
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${adjustedIndex + 1}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isToday || isSelected
                                      ? FontWeight.bold
                                      : null,
                                  color: isToday
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                ),
                              ),
                              if (isSelected)
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline,
                                      size: 14),
                                  onPressed: () => _showAddNoteDialog(day),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: dayNotes.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Sem notas',
                                        style: TextStyle(
                                          fontSize: 8,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.color,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                            Icons.add_circle_outline,
                                            size: 14),
                                        onPressed: () =>
                                            _showAddNoteDialog(day),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(1),
                                  itemCount: dayNotes.length,
                                  itemBuilder: (context, index) {
                                    return Card(
                                      elevation: 0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.05),
                                      child: ListTile(
                                        dense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 2,
                                          vertical: 0,
                                        ),
                                        title: Text(
                                          dayNotes[index],
                                          style: const TextStyle(fontSize: 8),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.delete_outline,
                                              size: 10),
                                          onPressed: () {
                                            setState(() {
                                              dayNotes.removeAt(index);
                                              if (dayNotes.isEmpty) {
                                                _notes.remove(DateTime(
                                                  day.year,
                                                  day.month,
                                                  day.day,
                                                ));
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyView() {
    final weekStart = _getWeekStart();
    final weekDays =
        List.generate(7, (index) => weekStart.add(Duration(days: index)));

    return Column(
      children: [
        _buildWeekdayHeader(),
        Expanded(
          child: Row(
            children: weekDays.map((day) {
              final dayNotes =
                  _notes[DateTime(day.year, day.month, day.day)] ?? [];
              final isToday = isSameDay(day, DateTime.now());
              final isSelected = isSameDay(day, _selectedDate);

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = day;
                    });
                  },
                  child: Card(
                    margin: const EdgeInsets.all(4),
                    elevation: isSelected ? 4 : 1,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isToday
                                ? Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.1)
                                : null,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                fontWeight: isToday || isSelected
                                    ? FontWeight.bold
                                    : null,
                                color: isToday
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(4),
                            itemCount: dayNotes.length,
                            itemBuilder: (context, index) {
                              return Card(
                                elevation: 0,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.05),
                                child: ListTile(
                                  dense: true,
                                  title: Text(
                                    dayNotes[index],
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        size: 16),
                                    onPressed: () {
                                      setState(() {
                                        dayNotes.removeAt(index);
                                        if (dayNotes.isEmpty) {
                                          _notes.remove(DateTime(
                                            day.year,
                                            day.month,
                                            day.day,
                                          ));
                                        }
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader() {
    final weekdays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        children: weekdays.map((day) {
          return Expanded(
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _showAddNoteDialog([DateTime? specificDay]) {
    final TextEditingController noteController = TextEditingController();
    final targetDate = specificDay ?? _selectedDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            'Adicionar Nota para ${DateFormat('dd/MM/yyyy').format(targetDate)}'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            hintText: 'Digite sua nota aqui',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (noteController.text.isNotEmpty) {
                setState(() {
                  final key = DateTime(
                    targetDate.year,
                    targetDate.month,
                    targetDate.day,
                  );
                  if (_notes[key] == null) {
                    _notes[key] = [];
                  }
                  _notes[key]!.add(noteController.text);
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
