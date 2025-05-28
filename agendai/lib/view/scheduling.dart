import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';
import 'package:agendai/widgets/sidebar.dart';
class Event {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final Color color;
  final String category; // Para ligar aos CalendarDetailItem

  Event({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.color,
    required this.category,
  });
}

// Estrutura de dados para os detalhes do calendário no painel lateral.
class CalendarDetailItem {
  final String name;
  final Color color;
  bool isVisible;

  CalendarDetailItem({
    required this.name,
    required this.color,
    this.isVisible = true,
  });
}
// O widget principal da página de agendamento, StatefulWidget para gerir o estado.
class Scheduling extends StatefulWidget {
  const Scheduling({super.key});

  @override
  State<Scheduling> createState() => _SchedulingState();
}

class _SchedulingState extends State<Scheduling> {
  // Gerador de UUID para IDs de eventos únicos.
  final Uuid _uuid = const Uuid();

  // Estado para o dia focado e selecionado no calendário.
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Lista de meses para o dropdown.
  final List<String> _months = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];
  String? _selectedMonth;

  // Lista de eventos de exemplo.
  late List<Event> _events;

  // Lista de detalhes do calendário de exemplo.
  late List<CalendarDetailItem> _calendarDetails;

  // Hora de início e fim para a vista de agendamento.
  final int _startHour = 8;
  final int _endHour = 18;
  final double _hourHeight = 60.0; // Altura de cada slot de hora em pixels.

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedMonth = _months[_focusedDay.month - 1];

    // Inicializar com alguns dados de exemplo.
    _calendarDetails = [
      CalendarDetailItem(name: "Operating Systems", color: Colors.blue.shade300),
      CalendarDetailItem(name: "UI Design", color: Colors.cyan.shade300),
      CalendarDetailItem(name: "Foreign Language", color: Colors.orange.shade300),
      CalendarDetailItem(name: "Computer Networks", color: Colors.red.shade300),
      CalendarDetailItem(name: "Databases", color: Colors.green.shade300),
      CalendarDetailItem(name: "C# Programming", color: Colors.purple.shade300),
    ];

    _events = [
      Event(
        id: _uuid.v4(),
        title: "Operating Systems Lecture",
        startTime: DateTime(_focusedDay.year, _focusedDay.month, _focusedDay.day, 9, 0),
        endTime: DateTime(_focusedDay.year, _focusedDay.month, _focusedDay.day, 10, 20),
        color: _calendarDetails[0].color,
        category: _calendarDetails[0].name,
      ),
      Event(
        id: _uuid.v4(),
        title: "UI Design Workshop",
        startTime: DateTime(_focusedDay.year, _focusedDay.month, _focusedDay.day, 12, 30),
        endTime: DateTime(_focusedDay.year, _focusedDay.month, _focusedDay.day, 13, 50),
        color: _calendarDetails[1].color,
        category: _calendarDetails[1].name,
      ),
      Event(
        id: _uuid.v4(),
        title: "Operating Systems Lab",
        // Exemplo para um dia diferente na mesma semana (se _focusedDay for segunda-feira, isto será terça-feira)
        startTime: DateTime(_focusedDay.year, _focusedDay.month, _focusedDay.day + (_focusedDay.weekday <= 2 ? (2 - _focusedDay.weekday) : (9 - _focusedDay.weekday)), 10, 30),
        endTime: DateTime(_focusedDay.year, _focusedDay.month, _focusedDay.day + (_focusedDay.weekday <= 2 ? (2 - _focusedDay.weekday) : (9 - _focusedDay.weekday)), 11, 50),
        color: _calendarDetails[0].color,
        category: _calendarDetails[0].name,
      ),
    ];
  }

  // Constrói a barra superior da página.
  Widget _buildTopBar() {
    // Determina o início e o fim da semana atual.
    // Ajuste para garantir que a semana comece corretamente com base em _focusedDay.
    // A imagem de referência parece usar Domingo como primeiro dia da semana.
    DateTime startOfWeek = _focusedDay.subtract(Duration(days: _focusedDay.weekday % 7)); // Domingo é 0 se weekday for 7 (Sunday)
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));


    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          const Text(
            "My schedule",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 20),
          Text(
            "${DateFormat('MMMM, dd').format(startOfWeek)} - ${DateFormat('dd').format(endOfWeek)}",
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
          const Spacer(),
          // Dropdown para selecionar o mês.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: DropdownButton<String>(
              value: _selectedMonth,
              underline: const SizedBox(), // Remove a linha de sublinhado padrão
              icon: const Icon(Icons.arrow_drop_down),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedMonth = newValue;
                    int monthIndex = _months.indexOf(newValue);
                    // Mantém o dia do mês, se possível, ou vai para o último dia do novo mês
                    int currentDay = _focusedDay.day;
                    int year = _focusedDay.year;
                    int newMonth = monthIndex + 1;
                    int daysInNewMonth = DateTime(year, newMonth + 1, 0).day; // Dias no novo mês
                    _focusedDay = DateTime(year, newMonth, currentDay > daysInNewMonth ? daysInNewMonth : currentDay);
                    _selectedDay = _focusedDay; // Sincroniza o dia selecionado com o mês focado
                  });
                }
              },
              items: _months.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 16),
          // Botão para adicionar novo evento.
          ElevatedButton.icon(
            icon: const Icon(Icons.add, size: 18),
            label: const Text("Add new"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _showAddEventDialog,
          ),
          const SizedBox(width: 24),
          // Secção do perfil do utilizador (placeholder).
          Row(
            children: [
              const CircleAvatar(
                // backgroundImage: NetworkImage('URL_DA_IMAGEM_DO_PERFIL_AQUI'), // Descomentar e adicionar URL
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Vladislav Maidan", // Nome do utilizador como na imagem
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Group: IT3-20-1cx", // Grupo como na imagem
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.arrow_drop_down),
                onPressed: () {
                  // Lógica para o dropdown do perfil do utilizador
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Constrói a linha de conteúdo principal com a vista semanal e a barra lateral.
  Widget _buildMainContentRow() {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vista de agendamento semanal.
          Expanded(
            flex: 3, // A vista de agendamento ocupa mais espaço
            child: _buildWeeklyScheduleView(),
          ),
          // Barra lateral direita.
          Container(
            width: 300, // Largura fixa para a barra lateral
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(left: BorderSide(color: Colors.grey.shade300)),
            ),
            child: _buildRightSidebar(),
          ),
        ],
      ),
    );
  }

  // Constrói a vista de agendamento semanal.
  Widget _buildWeeklyScheduleView() {
    // Determina os dias da semana atual para exibir.
    // A imagem de referência mostra Domingo como o primeiro dia da semana.
    DateTime startOfWeek = _focusedDay.subtract(Duration(days: _focusedDay.weekday % 7));
    if (_focusedDay.weekday == DateTime.sunday) { // Em Dart, Sunday é 7.
        startOfWeek = _focusedDay.subtract(Duration(days: 0)); // Se já é domingo
    } else {
        startOfWeek = _focusedDay.subtract(Duration(days: _focusedDay.weekday));
    }


    List<DateTime> weekDays = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho dos dias da semana.
          Padding(
            padding: const EdgeInsets.only(left: 60.0, top: 16.0, bottom:8.0, right: 16.0), // Alinhar com a coluna de tempo
            child: Row(
              children: [
                //const SizedBox(width: 0), // Espaço para a coluna de tempo // Removido pois o padding esquerdo já cuida disso
                ...weekDays.map((day) => Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDay = day;
                        _focusedDay = day; // Também foca no dia clicado
                         _selectedMonth = _months[_focusedDay.month - 1];
                      });
                    },
                    child: Column(
                      children: [
                          Text(
                          DateFormat('EEE').format(day), // Dia da semana (Dom, Seg, Ter)
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                        ),
                        Container(
                           padding: const EdgeInsets.all(4.0),
                           decoration: BoxDecoration(
                             color: isSameDay(day, _selectedDay) ? Colors.blue.shade400 : Colors.transparent,
                             shape: BoxShape.circle,
                           ),
                          child: Text(
                            DateFormat('d').format(day), // Dia do mês
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: isSameDay(day, _selectedDay) ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )).toList(),
              ],
            ),
          ),
          // Grelha de agendamento principal.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimeColumn(), // Coluna com as etiquetas de tempo.
              // Colunas para cada dia da semana.
              Expanded(
                child: SingleChildScrollView( // Permite rolagem horizontal se as colunas dos dias excederem a largura
                  scrollDirection: Axis.horizontal,
                  child: Row( // Contém as colunas dos dias
                    children: weekDays.map((day) {
                      // Filtra eventos para este dia específico e que estão visíveis.
                      List<Event> eventsForDay = _events.where((event) {
                        final calendarDetail = _calendarDetails.firstWhere(
                          (detail) => detail.name == event.category,
                          // Provide a default CalendarDetailItem if not found, to avoid errors
                          // This default item should ideally not match any real category or be invisible.
                          orElse: () => CalendarDetailItem(name: "UnknownCategoryPlaceholder", color: Colors.transparent, isVisible: false)
                        );
                        return isSameDay(event.startTime, day) && calendarDetail.isVisible;
                      }).toList();
                      return _buildDayColumn(day, eventsForDay);
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Constrói a coluna de etiquetas de tempo.
  Widget _buildTimeColumn() {
    List<Widget> timeSlots = [];
    for (int hour = _startHour; hour <= _endHour; hour++) {
      timeSlots.add(
        Container(
          height: _hourHeight,
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(top: 4), // Pequeno padding para o texto da hora
          child: Text(
            "${hour.toString().padLeft(2, '0')}:00",
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ),
      );
    }
    return Container(
      width: 60, // Largura da coluna de tempo
      padding: const EdgeInsets.only(top:0), // Alinha com o topo das colunas de dia
      child: Column(children: timeSlots),
    );
  }

  // Constrói uma única coluna de dia na vista semanal.
  Widget _buildDayColumn(DateTime dayDate, List<Event> eventsForDay) {
    // Altura total da coluna do dia.
    double totalHeight = (_endHour - _startHour + 1) * _hourHeight; // +1 for the visual slot of the end hour

    return Container(
      width: 150, // Largura de cada coluna de dia
      height: totalHeight,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.grey.shade200),
          // Adiciona uma borda direita a todas exceto à última coluna de dia (Sábado)
           right: dayDate.weekday == DateTime.saturday ? BorderSide(color: Colors.grey.shade200) : BorderSide.none, // Add right border to Saturday too
        ),
      ),
      child: Stack(
        children: [
          // Linhas de fundo para as horas.
          ...List.generate(_endHour - _startHour + 1, (index) { // +1 para incluir a linha inferior da última hora
            return Positioned(
              top: index * _hourHeight,
              left: 0,
              right: 0,
              child: Container(
                height: _hourHeight, // A altura da célula da hora
                decoration: BoxDecoration(
                  border: Border( // Desenha apenas a linha inferior para cada célula de hora
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
              ),
            );
          }),
          // Renderiza os eventos para este dia.
          ...eventsForDay.map((event) => _buildEventWidget(event, dayDate)).toList(),
        ],
      ),
    );
  }

  // Constrói um widget de evento individual.
  Widget _buildEventWidget(Event event, DateTime dayDate) {
    // Calcula a posição e a altura do evento.
    double top = (event.startTime.hour - _startHour + (event.startTime.minute / 60.0)) * _hourHeight;
    double height = (event.endTime.difference(event.startTime).inMinutes / 60.0) * _hourHeight;

    // Garante que o evento não comece antes do _startHour visualmente.
    if (event.startTime.hour < _startHour) {
        final visibleStartTime = DateTime(event.startTime.year, event.startTime.month, event.startTime.day, _startHour, 0);
        if (event.endTime.isAfter(visibleStartTime)) {
            height = (event.endTime.difference(visibleStartTime).inMinutes / 60.0) * _hourHeight;
        } else {
            height = 0; // Event ends before visual start
        }
        top = 0;
    }
     // Garante que o evento não ultrapasse o _endHour visualmente.
    DateTime visualEndTimeLimit = DateTime(dayDate.year, dayDate.month, dayDate.day, _endHour, 0);
    if (event.endTime.isAfter(visualEndTimeLimit)) {
        if(event.startTime.isBefore(visualEndTimeLimit)) {
             height = (visualEndTimeLimit.difference(event.startTime).inMinutes / 60.0) * _hourHeight;
             // Adjust if original top was also modified
             if (event.startTime.hour < _startHour) {
                 DateTime visualStartTime = DateTime(dayDate.year, dayDate.month, dayDate.day, _startHour, 0);
                 height = (visualEndTimeLimit.difference(visualStartTime).inMinutes / 60.0) * _hourHeight;
             }
        } else {
            height = 0; // Event starts at or after visual end
        }
    }


    if (height <= 0) return const SizedBox.shrink(); // Não renderiza se a altura for inválida

    // Calcula uma cor de borda ligeiramente mais escura.
    final HSLColor hslColor = HSLColor.fromColor(event.color);
    final HSLColor darkerHslColor = hslColor.withLightness((hslColor.lightness - 0.1).clamp(0.0, 1.0));
    final Color borderColor = darkerHslColor.toColor();

    return Positioned(
      top: top.clamp(0.0, (_endHour - _startHour) * _hourHeight), // Clamp top position
      left: 5, // Pequeno preenchimento dentro da coluna do dia
      right: 5,
      height: height.clamp(0.0, (_endHour - event.startTime.hour - (event.startTime.minute/60.0)) * _hourHeight ), // Clamp height
      child: Tooltip(
        message: "${event.title}\n${DateFormat.Hm().format(event.startTime)} - ${DateFormat.Hm().format(event.endTime)}",
        child: GestureDetector(
          onTap: () {
            // Lógica para editar ou ver detalhes do evento
            _showEditEventDialog(event);
          },
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: event.color.withOpacity(0.8),
              borderRadius: BorderRadius.circular(4),
              border: Border(left: BorderSide(color: borderColor, width: 3)),
            ),
            child: Text(
              "${event.title}\n${DateFormat.Hm().format(event.startTime)} - ${DateFormat.Hm().format(event.endTime)}",
              style: const TextStyle(color: Colors.white, fontSize: 10),
              overflow: TextOverflow.ellipsis,
              maxLines: 3, // Ajuste conforme necessário para o conteúdo
            ),
          ),
        ),
      ),
    );
  }

  // Constrói a barra lateral direita com o calendário e os detalhes.
  Widget _buildRightSidebar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Calendário de seleção de mês/dia.
        TableCalendar(
          locale: 'en_US', // Pode ser alterado para pt_BR ou pt_PT
          firstDay: DateTime.utc(2000, 1, 1),
          lastDay: DateTime.utc(2100, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: CalendarFormat.month, // Mostra apenas a vista de mês
          startingDayOfWeek: StartingDayOfWeek.sunday, // Começa a semana no Domingo como na imagem
          headerStyle: const HeaderStyle(
            formatButtonVisible: false, // Esconde o botão de formato (semana, 2 semanas, mês)
            titleCentered: true,
            titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.blue.shade400, // Cor de seleção mais proeminente
              shape: BoxShape.circle,
            ),
              outsideDaysVisible: false, // Esconde dias fora do mês atual
          ),
          onDaySelected: (selectedDay, focusedDay) {
            if (!isSameDay(_selectedDay, selectedDay)) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay; // Atualiza _focusedDay também
                  _selectedMonth = _months[_focusedDay.month - 1]; // Atualiza o dropdown do mês
              });
            }
          },
          onPageChanged: (focusedDay) {
            setState(() {
                _focusedDay = focusedDay;
                _selectedMonth = _months[_focusedDay.month - 1]; // Atualiza o dropdown do mês
                // If the selected day is not in the new focused month, update selectedDay to the focusedDay
                if (_selectedDay == null || _selectedDay!.month != _focusedDay.month || _selectedDay!.year != _focusedDay.year) {
                   _selectedDay = _focusedDay;
                }
            });
          },
        ),
        const SizedBox(height: 24),
        // Secção de Detalhes do Calendário.
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Calendar Details",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.blue),
              onPressed: () {
                // Lógica para adicionar novo detalhe de calendário
                _showAddCalendarDetailDialog();
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Lista de detalhes do calendário.
        Expanded(child: _buildCalendarDetailsList()),
      ],
    );
  }

  // Constrói a lista de detalhes do calendário.
  Widget _buildCalendarDetailsList() {
    if (_calendarDetails.isEmpty) {
      return const Center(child: Text("No calendar categories yet."));
    }
    return ListView.builder(
      itemCount: _calendarDetails.length,
      itemBuilder: (context, index) {
        final detail = _calendarDetails[index];
        return CheckboxListTile(
          title: Text(detail.name, style: const TextStyle(fontSize: 14)),
          value: detail.isVisible,
          onChanged: (bool? value) {
            if (value != null) {
              setState(() {
                detail.isVisible = value;
              });
            }
          },
          secondary: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: detail.color,
              borderRadius: BorderRadius.circular(4) // Pequeno arredondamento para o quadrado de cor
            ),
          ),
          controlAffinity: ListTileControlAffinity.leading, // Checkbox à esquerda
          dense: true,
          contentPadding: EdgeInsets.zero,
        );
      },
    );
  }

  // Mostra um diálogo para adicionar um novo evento.
  void _showAddEventDialog() {
    final TextEditingController titleController = TextEditingController();
    // Define a hora inicial para o dia selecionado no calendário, ou hoje se nenhum dia estiver selecionado.
    DateTime initialDialogDate = _selectedDay ?? DateTime.now();
    TimeOfDay initialStartTimeOfDay = const TimeOfDay(hour: 9, minute: 0); // Padrão 9:00 AM
    TimeOfDay initialEndTimeOfDay = const TimeOfDay(hour: 10, minute: 0); // Padrão 10:00 AM


    DateTime selectedStartTime = DateTime(initialDialogDate.year, initialDialogDate.month, initialDialogDate.day, initialStartTimeOfDay.hour, initialStartTimeOfDay.minute);
    DateTime selectedEndTime = DateTime(initialDialogDate.year, initialDialogDate.month, initialDialogDate.day, initialEndTimeOfDay.hour, initialEndTimeOfDay.minute);

    CalendarDetailItem? selectedCategory = _calendarDetails.isNotEmpty ? _calendarDetails.first : null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder( // Necessário para atualizar o estado dentro do diálogo
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Add New Event"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: "Event Title"),
                    ),
                    const SizedBox(height: 20),
                    // Seletores de Data e Hora
                    Text("Start: ${DateFormat('EEE, MMM d, HH:mm').format(selectedStartTime)}"),
                    ElevatedButton(
                      child: const Text("Select Start Date & Time"),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedStartTime,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (date == null) return;
                        final time = await showTimePicker( // ignore: use_build_context_synchronously
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(selectedStartTime),
                        );
                        if (time == null) return;
                        setDialogState(() {
                          selectedStartTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                            // Garante que a hora de fim não seja anterior à nova hora de início
                          if (selectedEndTime.isBefore(selectedStartTime)) {
                            selectedEndTime = selectedStartTime.add(const Duration(hours: 1));
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Text("End: ${DateFormat('EEE, MMM d, HH:mm').format(selectedEndTime)}"),
                    ElevatedButton(
                      child: const Text("Select End Date & Time"),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedEndTime,
                          firstDate: selectedStartTime, // Garante que a data de fim não seja anterior à de início
                          lastDate: DateTime(2101),
                        );
                        if (date == null) return;
                        final time = await showTimePicker( // ignore: use_build_context_synchronously
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(selectedEndTime),
                        );
                        if (time == null) return;
                        setDialogState(() {
                          selectedEndTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                           if (selectedEndTime.isBefore(selectedStartTime)) {
                            // Optionally show a message or automatically adjust start time
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(backgroundColor: Colors.orangeAccent, content: Text("End time cannot be before start time. Adjusting start time."))
                            );
                            selectedStartTime = selectedEndTime.subtract(const Duration(hours:1)); // Example adjustment
                          }
                        });
                      },
                    ),
                      const SizedBox(height: 20),
                    if (_calendarDetails.isNotEmpty)
                      DropdownButtonFormField<CalendarDetailItem>(
                        decoration: const InputDecoration(labelText: "Category", border: OutlineInputBorder()),
                        value: selectedCategory,
                        items: _calendarDetails.map((CalendarDetailItem category) {
                          return DropdownMenuItem<CalendarDetailItem>(
                            value: category,
                            child: Row(
                              children: [
                                Container(width: 12, height: 12, color: category.color, margin: const EdgeInsets.only(right: 8)),
                                Text(category.name),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (CalendarDetailItem? newValue) {
                            setDialogState(() {
                              selectedCategory = newValue;
                            });
                        },
                      )
                    else
                      const Text("Please add a calendar category first in the sidebar."),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text("Add Event"),
                  onPressed: () {
                    if (titleController.text.isNotEmpty && selectedCategory != null) {
                      if (selectedEndTime.isBefore(selectedStartTime) || selectedEndTime.isAtSameMomentAs(selectedStartTime)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(backgroundColor: Colors.redAccent, content: Text("End time must be after start time."))
                          );
                        return;
                      }
                      setState(() {
                        _events.add(Event(
                          id: _uuid.v4(),
                          title: titleController.text,
                          startTime: selectedStartTime,
                          endTime: selectedEndTime,
                          color: selectedCategory!.color,
                          category: selectedCategory!.name,
                        ));
                      });
                      Navigator.of(context).pop();
                    } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(backgroundColor: Colors.redAccent, content: Text("Please fill all fields and select a category."))
                        );
                    }
                  },
                ),
              ],
            );
          }
        );
      },
    );
  }

  // Mostra um diálogo para editar um evento existente.
  void _showEditEventDialog(Event event) {
    final TextEditingController titleController = TextEditingController(text: event.title);
    DateTime selectedStartTime = event.startTime;
    DateTime selectedEndTime = event.endTime;
    
    // --- CORRECTED LOGIC FOR selectedCategory INITIALIZATION ---
    CalendarDetailItem? selectedCategory;
    if (_calendarDetails.isNotEmpty) {
      // If categories exist, try to find a match for event.category.
      // If not found, default to the first category in the list.
      selectedCategory = _calendarDetails.firstWhere(
        (detail) => detail.name == event.category,
        orElse: () => _calendarDetails.first, // _calendarDetails is guaranteed not empty here
      );
    } else {
      // If no categories exist at all, selectedCategory remains null.
      // The DropdownButtonFormField will be replaced by a Text widget later if this is the case.
      selectedCategory = null;
    }
    // --- END OF CORRECTION ---

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Edit Event: ${event.title}"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: "Event Title"),
                    ),
                    const SizedBox(height: 20),
                    Text("Start: ${DateFormat('EEE, MMM d, HH:mm').format(selectedStartTime)}"),
                    ElevatedButton(
                      child: const Text("Select Start Date & Time"),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedStartTime,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (date == null) return;
                        final time = await showTimePicker( // ignore: use_build_context_synchronously
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(selectedStartTime),
                        );
                        if (time == null) return;
                        setDialogState(() {
                          selectedStartTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                          if (selectedEndTime.isBefore(selectedStartTime)) {
                            selectedEndTime = selectedStartTime.add(const Duration(hours: 1));
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Text("End: ${DateFormat('EEE, MMM d, HH:mm').format(selectedEndTime)}"),
                    ElevatedButton(
                      child: const Text("Select End Date & Time"),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedEndTime,
                          firstDate: selectedStartTime, // Garante que a data de fim não seja anterior à de início
                          lastDate: DateTime(2101),
                        );
                        if (date == null) return;
                        final time = await showTimePicker( // ignore: use_build_context_synchronously
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(selectedEndTime),
                        );
                        if (time == null) return;
                        setDialogState(() {
                          selectedEndTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                           if (selectedEndTime.isBefore(selectedStartTime)) {
                             ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(backgroundColor: Colors.orangeAccent, content: Text("End time cannot be before start time. Adjusting start time."))
                            );
                            selectedStartTime = selectedEndTime.subtract(const Duration(hours:1));
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    if (_calendarDetails.isNotEmpty)
                      DropdownButtonFormField<CalendarDetailItem>(
                        decoration: const InputDecoration(labelText: "Category", border: OutlineInputBorder()),
                        value: selectedCategory, // This can be null if no categories or no match initially
                        items: _calendarDetails.map((CalendarDetailItem category) {
                          return DropdownMenuItem<CalendarDetailItem>(
                            value: category,
                            child: Row(
                              children: [
                                Container(width: 12, height: 12, color: category.color, margin: const EdgeInsets.only(right: 8)),
                                Text(category.name),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (CalendarDetailItem? newValue) {
                          setDialogState(() {
                            selectedCategory = newValue;
                          });
                        },
                      )
                    else
                      const Text("No categories available. Please add a category first."),
                  ],
                ),
              ),
              actions: <Widget>[
                  TextButton(
                    onPressed: () {
                        // Confirmation Dialog for Delete
                        showDialog(
                            context: context,
                            builder: (BuildContext alertContext) {
                                return AlertDialog(
                                    title: const Text("Confirm Delete"),
                                    content: Text("Are you sure you want to delete the event '${event.title}'?"),
                                    actions: [
                                        TextButton(
                                            child: const Text("Cancel"),
                                            onPressed: () => Navigator.of(alertContext).pop(),
                                        ),
                                        TextButton(
                                            child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                            onPressed: () {
                                                setState(() {
                                                    _events.removeWhere((e) => e.id == event.id);
                                                });
                                                Navigator.of(alertContext).pop(); // Close confirmation dialog
                                                Navigator.of(context).pop(); // Close edit dialog
                                            },
                                        ),
                                    ],
                                );
                            },
                        );
                    },
                    child: const Text("Delete", style: TextStyle(color: Colors.red))),
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text("Save Changes"),
                  onPressed: () {
                    if (titleController.text.isNotEmpty && selectedCategory != null) {
                      if (selectedEndTime.isBefore(selectedStartTime) || selectedEndTime.isAtSameMomentAs(selectedStartTime)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(backgroundColor: Colors.redAccent, content: Text("End time must be after start time."))
                          );
                        return;
                      }
                      setState(() {
                        final eventIndex = _events.indexWhere((e) => e.id == event.id);
                        if (eventIndex != -1) {
                          _events[eventIndex] = Event(
                            id: event.id, // Mantém o mesmo ID
                            title: titleController.text,
                            startTime: selectedStartTime,
                            endTime: selectedEndTime,
                            color: selectedCategory!.color,
                            category: selectedCategory!.name,
                          );
                        }
                      });
                      Navigator.of(context).pop();
                    } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(backgroundColor: Colors.redAccent, content: Text("Please fill all fields and select a category."))
                        );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

    // Mostra um diálogo para adicionar um novo detalhe de calendário.
  void _showAddCalendarDetailDialog() {
    final TextEditingController nameController = TextEditingController();
    Color selectedColor = Colors.blue.shade300; // Cor padrão inicial

    // Prepara uma lista de cores para o seletor
    final List<Color> colorOptions = [
      Colors.blue.shade300, Colors.green.shade300, Colors.red.shade300, Colors.orange.shade300,
      Colors.purple.shade300, Colors.teal.shade300, Colors.pink.shade300, Colors.amber.shade300,
      Colors.cyan.shade300, Colors.brown.shade300, Colors.indigo.shade300, Colors.lime.shade300,
    ];
    if (!colorOptions.contains(selectedColor)) {
      selectedColor = colorOptions.first;
    }


    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Add Calendar Category"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Category Name"),
                    ),
                    const SizedBox(height: 20),
                    const Text("Select Color:"),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100, // Adjusted height for potentially two rows of colors
                      child: Wrap( // Usa Wrap para quebrar para a próxima linha se necessário
                        spacing: 8.0, // Espaço horizontal entre os círculos de cor
                        runSpacing: 8.0, // Espaço vertical entre as linhas de círculos de cor
                        children: colorOptions.map((color) {
                          return GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                selectedColor = color;
                              });
                            },
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selectedColor == color ? Theme.of(context).colorScheme.onSurface : Colors.transparent,
                                  width: 2.5,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text("Add Category"),
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      // Verifica se a categoria já existe (case-insensitive)
                      if (_calendarDetails.any((detail) => detail.name.toLowerCase() == nameController.text.trim().toLowerCase())) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(backgroundColor: Colors.orangeAccent, content: Text("Category '${nameController.text.trim()}' already exists."))
                        );
                        return;
                      }
                      setState(() {
                        _calendarDetails.add(CalendarDetailItem(
                          name: nameController.text.trim(),
                          color: selectedColor,
                          isVisible: true,
                        ));
                      });
                      Navigator.of(context).pop();
                    } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(backgroundColor: Colors.redAccent, content: Text("Please enter a category name."))
                        );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }


  // Widget principal da página de agendamento.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Cor de fundo geral
      body: Row( // Main layout is now a Row
        children: [
          const Sidebar(selected: 'Agenda'), // Added Sidebar
          Expanded( // The original content is now Expanded
            child: Column(
              children: [
                _buildTopBar(),
                _buildMainContentRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}