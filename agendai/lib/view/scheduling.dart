import 'package:agendai/entity/customer.dart';
import 'package:agendai/entity/employee.dart';
import 'package:agendai/entity/service.dart';
import 'package:agendai/presenter/customer_presenter.dart';
import 'package:agendai/presenter/employees_presenter.dart';
import 'package:agendai/entity/scheduling.dart' as entity;
import 'package:agendai/presenter/scheduling_presenter.dart';
import 'package:agendai/presenter/servico_presenter.dart';
import 'package:agendai/widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kalender/kalender.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart'; // Import for initializing date formatting

// Enum to represent different calendar view types
enum CalendarViewType { month, week, day }

class Scheduling extends StatefulWidget {
  const Scheduling({super.key});

  @override
  State<Scheduling> createState() => _SchedulingState();
}

class _SchedulingState extends State<Scheduling> {
  final eventsController = DefaultEventsController();
  final calendarController = CalendarController();

  // State variable to hold the current view type
  CalendarViewType _currentViewType = CalendarViewType.month;

  // Flag to check if the calendar controller is ready to be used.
  bool _isCalendarReady = false;
  
  // Add state for services, customers, and employees
  List<Servico> _services = [];
  Servico? _selectedService;
  List<Customer> _customers = [];
  Customer? _selectedCustomer;
  List<Employee> _employees = [];
  Employee? _selectedEmployee;

  final tileComponents = TileComponents(
    tileBuilder: (event, renderProperties) {
      // Cast the data object to access its properties.
      final scheduling = event.data as entity.Scheduling;
      final formattedEvent =
          "${DateFormat.Hm('pt_BR').format(event.dateTimeRange.start)} - ${scheduling.nomeServico}";

      return Container(
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
            top: 2, // Added some top padding for better text visibility
          ),
          child: Text(
            formattedEvent,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 12, // Adjusted font size for potentially smaller tiles
            ),
            overflow: TextOverflow.ellipsis, // Handle text overflow
          ),
        ),
      );
    },
  );

  @override
  void initState() {
    super.initState();
    // Initialize date formatting for the 'pt_BR' locale
    initializeDateFormatting('pt_BR', null).then((_) {
      // Jump to today's date once formatting is initialized
      calendarController.animateToDate(DateTime.now());
      // Load schedulings after the first frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        loadSchedulings();
        _loadDropdownData();

        // Set the calendar ready flag to true after the first frame.
        if (mounted) {
          setState(() {
            _isCalendarReady = true;
          });
        }
      });
    });
  }
  
    Future<void> _loadDropdownData() async {
    final servicePresenter = Provider.of<ServicePresenter>(context, listen: false);
    final customerPresenter = Provider.of<CustomersPresenter>(context, listen: false);
    final employeePresenter = Provider.of<EmployeesPresenter>(context, listen: false);

    await servicePresenter.getServicos();
    await customerPresenter.fetchInternalCustomers();
    await employeePresenter.getEmployees();

    if(mounted) {
      setState(() {
        _services = servicePresenter.servicos;
        _customers = customerPresenter.internalCustomers;
        _employees = employeePresenter.funcionarios;
      });
    }
  }


  /// Carrega os agendamentos da API e adiciona ao calendário
  Future<void> loadSchedulings() async {
    final presenter = Provider.of<SchedulingPresenter>(context, listen: false);
    await presenter.getScheduling();

    eventsController.clearEvents();

    for (var agendamento in presenter.scheduling) {
      addSchedulingEvent(agendamento);
    }
  }

  /// Adiciona um agendamento como evento no calendário
  void addSchedulingEvent(entity.Scheduling agendamento) {
    try {
      final date = DateTime.parse(agendamento.inicio);
      final fim = DateTime.parse(agendamento.fim);

      // Pass the entire scheduling object as data for easy access later
      eventsController.addEvent(CalendarEvent<entity.Scheduling>(
        dateTimeRange: DateTimeRange(
          start: date,
          end: fim,
        ),
        data: agendamento,
      ));
    } catch (e) {
      // Log error or handle parsing issues
      print('Error parsing scheduling event: ${agendamento.id}, Error: $e');
    }
  }

  /// Builds the current view configuration based on _currentViewType
  ViewConfiguration get _currentViewConfiguration {
    switch (_currentViewType) {
      case CalendarViewType.month:
        return MonthViewConfiguration.singleMonth();
      case CalendarViewType.week:
        return MultiDayViewConfiguration.week();
      case CalendarViewType.day:
        return MultiDayViewConfiguration.singleDay();
      default:
        return MonthViewConfiguration.singleMonth();
    }
  }

  /// Formats the AppBar title based on the current view and visible date range
  String _formatAppBarTitle(DateTimeRange dateTimeRange) {
    final start = dateTimeRange.start;

    switch (_currentViewType) {
      case CalendarViewType.month:
        final mesAno = DateFormat('MMMM yyyy', 'pt_BR').format(start);
        return mesAno[0].toUpperCase() + mesAno.substring(1);
      case CalendarViewType.week:
        return 'Semana de ${DateFormat('d \'de\' MMMM', 'pt_BR').format(start)}';
      case CalendarViewType.day:
        final diaFormatado =
            DateFormat('EEEE, d \'de\' MMMM \'de\' yyyy', 'pt_BR')
                .format(start);
        return diaFormatado[0].toUpperCase() + diaFormatado.substring(1);
      default:
        return "Agenda";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Row(
      children: [
        const Sidebar(selected: 'Agendamento'),
        Expanded(
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: _isCalendarReady
                  ? ValueListenableBuilder<DateTimeRange>(
                      valueListenable: calendarController.visibleDateTimeRange,
                      builder: (context, dateTimeRange, _) {
                        return Text(_formatAppBarTitle(dateTimeRange));
                      },
                    )
                  : const Text('Agenda'), // Use a placeholder title initially.
              actions: [
                IconButton(
                  icon: const Icon(Icons.today),
                  tooltip: 'Hoje',
                  onPressed: () {
                    calendarController.animateToDate(DateTime.now());
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.view_module), // Icon for Month View
                  tooltip: 'Mês',
                  color: _currentViewType == CalendarViewType.month
                      ? Colors.indigo
                      : null,
                  onPressed: () {
                    if (_currentViewType != CalendarViewType.month) {
                      setState(() {
                        _currentViewType = CalendarViewType.month;
                      });
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.view_week), // Icon for Week View
                  tooltip: 'Semana',
                  color: _currentViewType == CalendarViewType.week
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  onPressed: () {
                    if (_currentViewType != CalendarViewType.week) {
                      setState(() {
                        _currentViewType = CalendarViewType.week;
                      });
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.view_day), // Icon for Day View
                  tooltip: 'Dia',
                  color: _currentViewType == CalendarViewType.day
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  onPressed: () {
                    if (_currentViewType != CalendarViewType.day) {
                      setState(() {
                        _currentViewType = CalendarViewType.day;
                      });
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_left),
                  onPressed: () {
                    calendarController.animateToPreviousPage();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_right),
                  onPressed: () {
                    calendarController.animateToNextPage();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Recarregar',
                  onPressed: () {
                    loadSchedulings();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.list),
                  tooltip: 'Todos Agendamentos',
                  onPressed: () {
                    _showAllSchedulingsDialog();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Novo Agendamento',
                  onPressed: () {
                    _showAddOrUpdateEventDialog();
                  },
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(8),
              child: Consumer<SchedulingPresenter>(builder: (context, presenter, child) {
                // The calendar should rebuild when scheduling data changes.
                // Re-calculating events here when presenter notifies listeners.
                eventsController.clearEvents();
                for (var agendamento in presenter.scheduling) {
                  addSchedulingEvent(agendamento);
                }

                if (presenter.loadingScheduling && eventsController.events.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                return CalendarView(
                  eventsController: eventsController,
                  calendarController: calendarController,
                  viewConfiguration: _currentViewConfiguration,
                  callbacks: CalendarCallbacks(
                    onEventCreated: (event) => eventsController.addEvent(event),
                    onTapped: (date) {
                      if (_currentViewType == CalendarViewType.month) {
                        setState(() {
                          _currentViewType = CalendarViewType.day;
                          calendarController.animateToDate(date);
                        });
                      }
                    },
                    onEventTapped: (event, anEventInstance) {
                      final scheduling = event.data;
                      if (scheduling != null) {
                        _showSchedulingDetailsDialog(scheduling as entity.Scheduling);
                      }
                    },
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
          ),
        ),
      ],
    ));
  }
  
  void _showSchedulingDetailsDialog(entity.Scheduling scheduling) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Detalhes do Agendamento'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Serviço: ${scheduling.nomeServico}'),
                Text('Cliente: ${scheduling.nomeCliente}'),
                Text('Funcionário: ${scheduling.nomeFuncionario}'),
                Text('Empresa: ${scheduling.nomeEmpresa}'),
                Text('Data: ${_formatDateISO(scheduling.inicio)}'),
                Text('Início: ${_formatTimeFromDateTimeISOString(scheduling.inicio)}'),
                Text('Fim: ${_formatTimeFromDateTimeISOString(scheduling.fim)}'),
                Text('Duração: ${_formatDuration(scheduling.duracao)}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Fechar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            // NEW: Edit Button
            TextButton(
              child: const Text('Editar'),
              onPressed: () {
                Navigator.of(context).pop(); // Close details dialog
                _showAddOrUpdateEventDialog(scheduling: scheduling); // Open update dialog
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text('Excluir'),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Confirmar Exclusão'),
                    content: const Text('Tem certeza que deseja excluir este agendamento?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Excluir'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  final presenter = Provider.of<SchedulingPresenter>(context, listen: false);
                  Navigator.of(context).pop(); 
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Excluindo agendamento...'),
                    backgroundColor: Colors.blue,
                  ));
                  
                  try {
                    await presenter.deleteScheduling(scheduling.id);
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Agendamento excluído com sucesso!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                     ScaffoldMessenger.of(context).hideCurrentSnackBar();
                     ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao excluir agendamento: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Merged Add and Update Dialog
  void _showAddOrUpdateEventDialog({entity.Scheduling? scheduling}) {
    final bool isUpdating = scheduling != null;

    if (isUpdating) {
      try {
        _selectedService = _services.firstWhere((s) => s.id == scheduling!.idServico);
      } catch (e) {
        _selectedService = null;
      }
      try {
        _selectedCustomer = _customers.firstWhere((c) => c.id == scheduling!.idCliente);
      } catch (e) {
        _selectedCustomer = null;
      }
      try {
        _selectedEmployee = _employees.firstWhere((e) => e.id == scheduling!.idEmpresa);
      } catch (e) {
        _selectedEmployee = null;
      }
    } else {
      _selectedService = null;
      _selectedCustomer = null;
      _selectedEmployee = null;
    }

    DateTime selectedDate = isUpdating ? DateTime.parse(_formatDateISO(scheduling.inicio)) : DateTime.now();
    TimeOfDay selectedTime = isUpdating ? TimeOfDay.fromDateTime(DateTime.parse(scheduling!.inicio).toLocal()) : TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1)));

    final GlobalKey<State> dialogKey = GlobalKey<State>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
            key: dialogKey,
            builder: (context, setDialogState) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(isUpdating ? Icons.edit_calendar : Icons.event_available,
                                  color: Theme.of(context).primaryColor),
                              const SizedBox(width: 8),
                              Text(
                                isUpdating ? 'Editar Agendamento' : 'Novo Agendamento',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Dropdowns
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
                                  DropdownButtonFormField<Servico>(
                                    value: _selectedService,
                                    hint: const Text('Selecione um Serviço'),
                                    items: _services.map((Servico service) {
                                      return DropdownMenuItem<Servico>(
                                        value: service,
                                        child: Text(service.nome),
                                      );
                                    }).toList(),
                                    onChanged: (Servico? newValue) {
                                      setDialogState(() {
                                        _selectedService = newValue;
                                      });
                                    },
                                    decoration: const InputDecoration(
                                      labelText: 'Serviço',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.work_outline),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  DropdownButtonFormField<Customer>(
                                    value: _selectedCustomer,
                                    hint: const Text('Selecione um Cliente'),
                                    items: _customers.map((Customer customer) {
                                      return DropdownMenuItem<Customer>(
                                        value: customer,
                                        child: Text(customer.nome),
                                      );
                                    }).toList(),
                                    onChanged: (Customer? newValue) {
                                      setDialogState(() {
                                        _selectedCustomer = newValue;
                                      });
                                    },
                                    decoration: const InputDecoration(
                                      labelText: 'Cliente',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.person_outline),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  DropdownButtonFormField<Employee>(
                                    value: _selectedEmployee,
                                    hint: const Text('Selecione um Funcionário'),
                                    items: _employees.map((Employee employee) {
                                      return DropdownMenuItem<Employee>(
                                        value: employee,
                                        child: Text(employee.nome),
                                      );
                                    }).toList(),
                                    onChanged: (Employee? newValue) {
                                      setDialogState(() {
                                        _selectedEmployee = newValue;
                                      });
                                    },
                                    decoration: const InputDecoration(
                                      labelText: 'Funcionário',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.badge_outlined),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Date and Time Pickers
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
                                  InkWell(
                                    onTap: () async {
                                      final DateTime? pickedDate =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: selectedDate,
                                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                        lastDate: DateTime.now().add(const Duration(days: 365)),
                                        locale: const Locale('pt', 'BR'),
                                      );
                                      if (pickedDate != null) {
                                        setDialogState(() {
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
                                            DateFormat('dd/MM/yyyy', 'pt_BR')
                                                .format(selectedDate),
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
                                      final TimeOfDay? pickedTime =
                                          await showTimePicker(
                                        context: context,
                                        initialTime: selectedTime,
                                      );
                                      if (pickedTime != null) {
                                        setDialogState(() {
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
                          const SizedBox(height: 20),
                          // Action Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancelar'),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () async {
                                  if (_selectedService == null ||
                                      _selectedCustomer == null ||
                                      _selectedEmployee == null) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content: Text('Por favor, preencha todos os campos.'),
                                      backgroundColor: Colors.red,
                                    ));
                                    return;
                                  }

                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) => const Dialog(
                                      child: Padding(
                                        padding: EdgeInsets.all(20.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CircularProgressIndicator(),
                                            SizedBox(width: 20),
                                            Text("Salvando..."),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );

                                  final presenter = context.read<SchedulingPresenter>();
                                  final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
                                  final timeStr = "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}:00";
                                  
                                  try {
                                    if (isUpdating) {
                                      await presenter.updateScheduling(
                                        scheduling.id,
                                        idService: _selectedService!.id!,
                                        idCliente: _selectedCustomer!.id!,
                                        idFuncionario: _selectedEmployee!.id!,
                                        date: dateStr,
                                        time: timeStr,
                                      );
                                    } else {
                                      await presenter.createScheduling(
                                        idService: _selectedService!.id!,
                                        idCliente: _selectedCustomer!.id!,
                                        idFuncionario: _selectedEmployee!.id!,
                                        date: dateStr,
                                        time: timeStr,
                                      );
                                    }

                                    Navigator.of(context).pop(); // Close loading
                                    Navigator.of(context).pop(); // Close add/update event dialog
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text('Agendamento ${isUpdating ? 'atualizado' : 'criado'} com sucesso!'),
                                      backgroundColor: Colors.green,
                                    ));
                                  } catch (e) {
                                    Navigator.of(context).pop(); // Close loading
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text('Erro ao salvar: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                    ));
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(isUpdating ? 'Salvar' : 'Agendar'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            });
      },
    );
  }
  void _showAllSchedulingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final presenter =
            Provider.of<SchedulingPresenter>(context, listen: false);

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.event_note,
                          color: Theme.of(context).primaryColor,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Todos os Agendamentos',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Expanded(
                  child: presenter.loadingScheduling &&
                          presenter.scheduling.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : presenter.scheduling.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons
                                        .calendar_today_outlined, // Changed Icon
                                    size: 80,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Nenhum agendamento encontrado',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: presenter.scheduling.length,
                              itemBuilder: (context, index) {
                                final agendamento = presenter.scheduling[index];

                                final colors = [
                                  Colors.blue.shade50,
                                  Colors.purple.shade50,
                                  Colors.green.shade50,
                                  Colors.orange.shade50,
                                  Colors.pink.shade50,
                                  Colors.teal.shade50,
                                ];
                                final color = colors[index % colors.length];
                                final textColor =
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white70
                                        : Colors.black87;

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: 1, // Reduced elevation
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                          color: color.withAlpha(150),
                                          width: 1) // Softer border
                                      ),
                                  clipBehavior: Clip
                                      .antiAlias, // Ensures content respects border radius
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: color,
                                              radius: 20, // Slightly smaller
                                              child: Text(
                                                agendamento
                                                        .nomeCliente.isNotEmpty
                                                    ? agendamento.nomeCliente[0]
                                                        .toUpperCase()
                                                    : (agendamento.nomeServico
                                                            .isNotEmpty
                                                        ? agendamento
                                                            .nomeServico[0]
                                                            .toUpperCase()
                                                        : 'A'), // Fallback to 'A' for Agendamento
                                                style: TextStyle(
                                                  fontSize:
                                                      18, // Slightly smaller
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      textColor, // Use dynamic text color
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                                width: 12), // Reduced width
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    agendamento.nomeCliente,
                                                    style: TextStyle(
                                                      fontSize:
                                                          17, // Slightly smaller
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: textColor,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  if (agendamento.nomeServico
                                                      .isNotEmpty) // Show client name if available
                                                    Text(
                                                      agendamento.nomeServico,
                                                      style: TextStyle(
                                                        fontSize:
                                                            13, // Slightly smaller
                                                        color: Colors
                                                            .grey.shade600,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                ],
                                              ),
                                            ),
                                            if (agendamento.id !=
                                                null) // Show ID if available
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal:
                                                      8, // Smaller padding
                                                  vertical:
                                                      4, // Smaller padding
                                                ),
                                                decoration: BoxDecoration(
                                                  color: color.withOpacity(
                                                      0.7), // More subtle
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12), // More rounded
                                                ),
                                                child: Text(
                                                  "ID: ${agendamento.id}",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        10, // Smaller font
                                                    color: textColor,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(
                                            height: 12), // Reduced height
                                        Divider(
                                            color: Colors.grey
                                                .shade300), // Softer divider
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            _infoItem(
                                                Icons.calendar_today_outlined,
                                                'Data',
                                                _formatDate(agendamento.data),
                                                Theme.of(context)
                                                    .colorScheme
                                                    .primary // Use theme color for icons
                                                ),
                                            _infoItem(
                                                Icons.access_time_outlined,
                                                'Horário',
                                                _formatTime(
                                                    agendamento.horario),
                                                Theme.of(context)
                                                    .colorScheme
                                                    .primary),
                                            _infoItem(
                                                Icons
                                                    .timelapse_outlined, // Changed icon
                                                'Duração',
                                                _formatDuration(agendamento
                                                    .duracao), // Use formatted duration
                                                Theme.of(context)
                                                    .colorScheme
                                                    .primary),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Fechar',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoItem(IconData icon, String label, String value, Color iconColor) {
    return Column(
      // Removed Expanded for more natural sizing
      crossAxisAlignment: CrossAxisAlignment.center, // Center align items
      children: [
        Icon(icon, color: iconColor, size: 20), // Slightly smaller icon
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11, // Slightly smaller
            color: Colors.grey.shade700, // Slightly darker grey
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13, // Slightly smaller
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatDateISO(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return dateTime
          .toLocal()
          .toString()
          .split(' ')[0]; // HH:mm format
    } catch (e) {
      return dateTimeString; // fallback
    }
  }

  String _formatDate(String date) {
    try {
      final dateTime = DateTime.parse(date);
      return DateFormat('dd/MM/yy', 'pt_BR').format(dateTime); // Shortened year
    } catch (e) {
      // Fallback for potentially different date string formats if not yyyy-MM-dd
      final parts = date.split('-');
      if (parts.length == 3) {
        return '${parts[2]}/${parts[1]}/${parts[0].substring(2)}'; // Attempt to format as dd/MM/yy
      }
      return date; // Return original if parsing fails
    }
  }

  String _formatTime(String time) {
    final timeParts = time.split(':');
    if (timeParts.length >= 2) {
      return '${timeParts[0]}:${timeParts[1]}';
    }
    return time;
  }

  String _formatTimeFromDateTimeISOString(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return dateTime
          .toLocal()
          .toString()
          .split(' ')[1]
          .split('.')[0]; // HH:mm format
    } catch (e) {
      return dateTimeString; // fallback
    }
  }

  String _formatTimeFromDateTimeString(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat.Hm('pt_BR').format(dateTime); // HH:mm format
    } catch (e) {
      return dateTimeString; // fallback
    }
  }

  String _formatDuration(String durationStr) {
    if (durationStr.contains(':')) {
      final parts = durationStr.split(':');
      final hours = int.tryParse(parts[0]) ?? 0;
      final minutes = int.tryParse(parts[1]) ?? 0;
      if (hours > 0 && minutes > 0) {
        return '${hours}h ${minutes}m';
      } else if (hours > 0) {
        return '${hours}h';
      } else {
        return '${minutes}m';
      }
    } else {
      final minutes = int.tryParse(durationStr) ?? 0;
      if (minutes >= 60) {
        final hours = minutes ~/ 60;
        final remainingMinutes = minutes % 60;
        if (remainingMinutes > 0) {
          return '${hours}h ${remainingMinutes}m';
        }
        return '${hours}h';
      }
      return '${minutes}m';
    }
  }
}
