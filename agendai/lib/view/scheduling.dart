import 'package:agendai/entity/scheduling.dart' as entity;
import 'package:agendai/presenter/scheduling_presenter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kalender/kalender.dart'; // Assuming this is the correct package
import 'package:provider/provider.dart';

// Enum for different calendar views
enum CalendarViewType { month, week, day }

class Scheduling extends StatefulWidget {
  const Scheduling({super.key});

  @override
  State<Scheduling> createState() => _SchedulingState();
}

class _SchedulingState extends State<Scheduling> {
  final eventsController = DefaultEventsController<entity.Scheduling>(); // Store full event data
  final calendarController = CalendarController();

  CalendarViewType _currentView = CalendarViewType.month;

  @override
  void initState() {
    super.initState();
    // Initialize locale for intl package (ensure it's done in main.dart ideally)
    // initializeDateFormatting('pt_BR', null); // Already done in main usually

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadSchedulings();
    });
  }

  /// Loads schedulings from the API and adds them to the calendar
  Future<void> loadSchedulings() async {
    final presenter = Provider.of<SchedulingPresenter>(context, listen: false);
    // Ensure isLoading is properly managed in presenter
    if (presenter.loadingScheduling) return;
    await presenter.getScheduling();

    eventsController.clearEvents();

    for (var agendamento in presenter.scheduling) {
      addSchedulingEvent(agendamento);
    }
    // No need to call setState here as EventsController updates the CalendarView
  }

  /// Adds a scheduling entity as a CalendarEvent
  void addSchedulingEvent(entity.Scheduling agendamento) {
    try {
      final dateParts = agendamento.data.split('-');
      final timeParts = agendamento.horario.split(':');

      if (dateParts.length != 3 || timeParts.length < 2) {
        print('Invalid date or time format for scheduling: ${agendamento.id}');
        return;
      }

      final date = DateTime(
        int.parse(dateParts[0]), // year
        int.parse(dateParts[1]), // month
        int.parse(dateParts[2]), // day
        int.parse(timeParts[0]), // hour
        int.parse(timeParts[1]), // minute
        timeParts.length > 2 ? int.parse(timeParts[2]) : 0, // seconds (optional)
      );

      Duration duration;
      if (agendamento.duracao.contains(':')) {
        final durationParts = agendamento.duracao.split(':');
        duration = Duration(
          hours: int.parse(durationParts[0]),
          minutes: int.parse(durationParts[1]),
        );
      } else {
        duration = Duration(minutes: int.parse(agendamento.duracao));
      }

      eventsController.addEvent(CalendarEvent<entity.Scheduling>(
        dateTimeRange: DateTimeRange(start: date, end: date.add(duration)),
        eventData: agendamento, // Store the full scheduling object
      ));
    } catch (e) {
      print('Error parsing scheduling event: ${agendamento.id} - $e');
    }
  }

  // Enhanced Tile Builder
  Widget _eventTileBuilder(CalendarEvent<entity.Scheduling> event, TileConfiguration tileConfiguration) {
    final agendamento = event.eventData;
    final Color tileColor = agendamento != null && agendamento.id % 2 == 0 ? Colors.blue.shade200 : Colors.green.shade200;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 1.0),
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: tileColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        agendamento?.nomeServico ?? 'Agendamento',
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey.shade900,
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: tileConfiguration.maxLines,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final presenter = Provider.of<SchedulingPresenter>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: ValueListenableBuilder<DateTimeRange>(
          valueListenable: calendarController.visibleDateTimeRange,
          builder: (context, dateTimeRange, _) {
            final dateFormat = _currentView == CalendarViewType.day
                ? DateFormat('dd MMMM yyyy', 'pt_BR')
                : DateFormat('MMMM yyyy', 'pt_BR');
            final titleText = dateFormat.format(dateTimeRange.start);
            return Text(titleText[0].toUpperCase() + titleText.substring(1));
          },
        ),
        actions: [
          // View Switcher
          PopupMenuButton<CalendarViewType>(
            icon: const Icon(Icons.view_module),
            tooltip: "Alterar Visualização",
            onSelected: (CalendarViewType result) {
              setState(() {
                _currentView = result;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<CalendarViewType>>[
              const PopupMenuItem<CalendarViewType>(
                value: CalendarViewType.month,
                child: Text('Mês'),
              ),
              const PopupMenuItem<CalendarViewType>(
                value: CalendarViewType.week,
                child: Text('Semana'),
              ),
              const PopupMenuItem<CalendarViewType>(
                value: CalendarViewType.day,
                child: Text('Dia'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.arrow_left),
            tooltip: "Anterior",
            onPressed: () => calendarController.animateToPreviousPage(),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_right),
            tooltip: "Próximo",
            onPressed: () => calendarController.animateToNextPage(),
          ),
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: "Hoje",
            onPressed: () => calendarController.animateToDate(DateTime.now()),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Recarregar",
            onPressed: loadSchedulings,
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: "Novo Agendamento",
            onPressed: () => _showAddEventDialog(null), // Pass null for new event
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Overall padding for the calendar area
        child: presenter.loadingScheduling && eventsController.events.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : CalendarView<entity.Scheduling>(
                eventsController: eventsController,
                calendarController: calendarController,
                viewConfiguration: _getViewConfiguration(),
                tileComponents: TileComponents(
                  monthTileBuilder: _eventTileBuilder,
                  multiDayTileBuilder: _eventTileBuilder,
                  scheduleTileBuilder: _eventTileBuilder, // For schedule list view if used
                ),
                callbacks: CalendarCallbacks<entity.Scheduling>(
                  onEventTapped: _onEventTapped,
                  onDateTapped: _onDateTapped,
                  // onEventCreated: (event) => eventsController.addEvent(event), // For drag & drop creation
                ),
                headerComponents: CalendarHeaderComponents( // Customize header appearance
                  calendarHeaderBuilder: (context, dateTimeRange, viewConfiguration) {
                     return DefaultCalendarHeader(
                        dateTimeRange: dateTimeRange,
                        viewConfiguration: viewConfiguration,
                        onTodayButtonTapped: () => calendarController.animateToDate(DateTime.now()),
                     );
                  }
                ),
              ),
      ),
    );
  }

  ViewConfiguration _getViewConfiguration() {
    switch (_currentView) {
      case CalendarViewType.month:
        return const MonthViewConfiguration(
          // Custom month view options if needed
          // e.g., showWeekNumbers: true,
        );
      case CalendarViewType.week:
        return const WeekViewConfiguration(
          // Custom week view options
          // e.g., timelineWidth: 500,
        );
      case CalendarViewType.day:
        return const DayViewConfiguration(
          // Custom day view options
          // e.g., hourlineTimelineOverlap: 10,
        );
    }
  }

  void _onEventTapped(CalendarEvent<entity.Scheduling> event) {
    final agendamento = event.eventData;
    if (agendamento == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(agendamento.nomeServico),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cliente: ${agendamento.nomeCliente}'),
            Text('Data: ${DateFormat('dd/MM/yyyy', 'pt_BR').format(event.start)}'),
            Text('Horário: ${DateFormat.Hm('pt_BR').format(event.start)} - ${DateFormat.Hm('pt_BR').format(event.end)}'),
            Text('Duração: ${agendamento.duracao}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Fechar')),
          // TODO: Add Edit/Delete buttons here
        ],
      ),
    );
  }

  void _onDateTapped(DateTime date) {
    _showAddEventDialog(date);
  }


  void _showAddEventDialog(DateTime? preselectedDate) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final cpfController = TextEditingController();
    // TODO: Replace with actual service data from presenter or API
    String? selectedServiceId = "1"; // Placeholder
    List<DropdownMenuItem<String>> serviceItems = [
       const DropdownMenuItem(value: "1", child: Text('Corte de Cabelo (Mock)')),
       const DropdownMenuItem(value: "2", child: Text('Manicure (Mock)')),
    ];


    DateTime selectedDate = preselectedDate ?? DateTime.now();
    TimeOfDay selectedTime = preselectedDate != null 
                             ? TimeOfDay.fromDateTime(preselectedDate) 
                             : TimeOfDay.now();
    
    // State for the dialog itself
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();


    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // Use StatefulBuilder to manage state within the dialog (for date/time pickers)
        return StatefulBuilder(
          builder: (stfContext, stfSetState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(children: [
                Icon(Icons.event_available, color: Theme.of(stfContext).primaryColor),
                const SizedBox(width: 8),
                const Text('Novo Agendamento'),
              ]),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Service Selection
                      Card(
                        elevation: 0, color: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Serviço', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(stfContext).primaryColor)),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                filled: true, fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                              ),
                              value: selectedServiceId,
                              items: serviceItems,
                              hint: const Text('Selecione um serviço'),
                              onChanged: (value) {
                                stfSetState(() { selectedServiceId = value; });
                              },
                              validator: (value) => value == null ? 'Selecione um serviço' : null,
                            ),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Client Info
                      Card(
                        elevation: 0, color: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Icon(Icons.person, size: 18, color: Theme.of(stfContext).primaryColor),
                              const SizedBox(width: 8),
                              Text('Informações do Cliente', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(stfContext).primaryColor)),
                            ]),
                            const SizedBox(height: 12),
                            TextFormField(controller: nameController, decoration: _inputDecoration('Nome Completo', Icons.person_outline), validator: (v) => v!.isEmpty ? 'Nome é obrigatório' : null),
                            const SizedBox(height: 12),
                            TextFormField(controller: emailController, decoration: _inputDecoration('Email', Icons.email_outlined), keyboardType: TextInputType.emailAddress, validator: (v) => v!.isEmpty || !v.contains('@') ? 'Email inválido' : null),
                            const SizedBox(height: 12),
                            TextFormField(controller: phoneController, decoration: _inputDecoration('Telefone', Icons.phone_outlined), keyboardType: TextInputType.phone, validator: (v) => v!.isEmpty ? 'Telefone é obrigatório' : null),
                            const SizedBox(height: 12),
                            TextFormField(controller: cpfController, decoration: _inputDecoration('CPF (Opcional)', Icons.badge_outlined)),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Date and Time
                      Card(
                        elevation: 0, color: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Icon(Icons.calendar_today, size: 18, color: Theme.of(stfContext).primaryColor),
                              const SizedBox(width: 8),
                              Text('Data e Horário', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(stfContext).primaryColor)),
                            ]),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: () async {
                                final DateTime? pickedDate = await showDatePicker(
                                  context: stfContext, initialDate: selectedDate,
                                  firstDate: DateTime.now().subtract(const Duration(days: 30)), // Allow past for demo
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                  builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: Theme.of(context).primaryColor)), child: child!),
                                );
                                if (pickedDate != null) {
                                  stfSetState(() { selectedDate = pickedDate; });
                                }
                              },
                              child: _dateTimePickerDisplay(DateFormat('dd/MM/yyyy', 'pt_BR').format(selectedDate), Icons.calendar_month),
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: () async {
                                final TimeOfDay? pickedTime = await showTimePicker(
                                  context: stfContext, initialTime: selectedTime,
                                  builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: Theme.of(context).primaryColor)), child: child!),
                                );
                                if (pickedTime != null) {
                                  stfSetState(() { selectedTime = pickedTime; });
                                }
                              },
                              child: _dateTimePickerDisplay('${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}', Icons.access_time),
                            ),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                TextButton(onPressed: () => Navigator.of(stfContext).pop(), child: const Text('Cancelar')),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Agendar'),
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(stfContext).primaryColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      if (selectedServiceId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, selecione um serviço.'), backgroundColor: Colors.orange,));
                        return;
                      }
                      try {
                        await Provider.of<SchedulingPresenter>(context, listen: false).createScheduling(
                          idService: int.parse(selectedServiceId!), // Use actual service ID
                          date: DateFormat('yyyy-MM-dd').format(selectedDate),
                          time: "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}:00",
                          email: emailController.text,
                          cpf: cpfController.text,
                          name: nameController.text,
                          celPhone: phoneController.text,
                        );
                        await loadSchedulings(); // Reload events
                        Navigator.of(stfContext).pop();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Agendamento criado com sucesso!'), backgroundColor: Colors.green));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Falha ao criar agendamento: ${e.toString()}'), backgroundColor: Colors.red));
                      }
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

  InputDecoration _inputDecoration(String label, IconData? prefixIcon) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.grey.shade600) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  Widget _dateTimePickerDisplay(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        Icon(icon, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 16)),
        const Spacer(),
        Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
      ]),
    );
  }
}
