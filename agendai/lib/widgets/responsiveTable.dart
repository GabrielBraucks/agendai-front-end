import 'package:flutter/material.dart';

// Helper class for status chip
class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData iconData;
    String statusText = status;

    String lowerStatus = status.toLowerCase();

    if (lowerStatus == 'active' || lowerStatus == 'ativo' || lowerStatus == 'pago') {
      backgroundColor = Colors.green.shade100;
      textColor = Colors.green.shade800;
      iconData = Icons.check_circle;
      statusText = status[0].toUpperCase() + status.substring(1);
    } else if (lowerStatus == 'inactive' || lowerStatus == 'inativo' || lowerStatus == 'pendente') {
      backgroundColor = Colors.orange.shade100;
      textColor = Colors.orange.shade800;
      iconData = Icons.hourglass_empty;
      statusText = status[0].toUpperCase() + status.substring(1);
    } else {
      backgroundColor = Colors.red.shade100;
      textColor = Colors.red.shade800;
      iconData = Icons.cancel;
      statusText = status[0].toUpperCase() + status.substring(1);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, color: textColor, size: 14),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class ResponsiveTable extends StatefulWidget {
  final List<String> headers;
  final List<List<String>> data;
  final Function(List<int> selectedIndices)? onSelectionChanged;
  final Function(int rowIndex)? onEdit;
  final Function(int rowIndex)? onDelete;
  final Map<String, double>? columnWidthsPercentages;

  const ResponsiveTable({
    Key? key,
    required this.headers,
    required this.data,
    this.onSelectionChanged,
    this.onEdit,
    this.onDelete,
    this.columnWidthsPercentages,
  }) : super(key: key);

  @override
  _ResponsiveTableState createState() => _ResponsiveTableState();
}

class _ResponsiveTableState extends State<ResponsiveTable> {
  late List<List<String>> _internalData;
  late List<bool> _selectedRows;
  bool _selectAll = false;
  int _sortColumnIndex = -1;
  bool _isAscending = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ResponsiveTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data || widget.headers != oldWidget.headers) {
      _initializeData();
    }
  }

  void _initializeData() {
    _internalData = List<List<String>>.from(widget.data.map((row) => List<String>.from(row)));
    _selectedRows = List<bool>.filled(_internalData.length, false);
    _selectAll = false;
    _sortColumnIndex = -1;
  }

  void _onSelectAll(bool? selected) {
    if (_internalData.isEmpty) return;
    setState(() {
      _selectAll = selected ?? false;
      for (int i = 0; i < _selectedRows.length; i++) {
        _selectedRows[i] = _selectAll;
      }
      _notifySelectionChange();
    });
  }

  void _onRowSelected(int index, bool? selected) {
    if (index < 0 || index >= _selectedRows.length) return;
    setState(() {
      _selectedRows[index] = selected ?? false;
      if (_internalData.isNotEmpty) {
        _selectAll = _selectedRows.every((isSelected) => isSelected);
      } else {
        _selectAll = false;
      }
      _notifySelectionChange();
    });
  }

  void _notifySelectionChange() {
    if (widget.onSelectionChanged != null) {
      final selectedIndices = <int>[];
      for (int i = 0; i < _selectedRows.length; i++) {
        if (_selectedRows[i]) {
          selectedIndices.add(i);
        }
      }
      widget.onSelectionChanged!(selectedIndices);
    }
  }

  void _sortData(int dataTableColumnIndex) {
    int headerIndex = dataTableColumnIndex;

    if (headerIndex < 0 || headerIndex >= widget.headers.length) {
      return;
    }

    setState(() {
      if (_sortColumnIndex == headerIndex) {
        _isAscending = !_isAscending;
      } else {
        _sortColumnIndex = headerIndex;
        _isAscending = true;
      }

      List<int> originalIndices = List.generate(_internalData.length, (i) => i);

      originalIndices.sort((a, b) {
        final aRow = _internalData[a];
        final bRow = _internalData[b];
        
        if (aRow.length <= headerIndex || bRow.length <= headerIndex) return 0;
        
        final aValue = aRow[headerIndex];
        final bValue = bRow[headerIndex];

        double? aNum = double.tryParse(aValue.replaceAll(RegExp(r'[^0-9.,]'), '').replaceAll(',', '.'));
        double? bNum = double.tryParse(bValue.replaceAll(RegExp(r'[^0-9.,]'), '').replaceAll(',', '.'));

        int comparison;
        if (aNum != null && bNum != null) {
          comparison = aNum.compareTo(bNum);
        } else {
          comparison = aValue.toLowerCase().compareTo(bValue.toLowerCase());
        }
        return _isAscending ? comparison : -comparison;
      });
      
      _internalData = originalIndices.map((i) => _internalData[i]).toList();
      _selectedRows = originalIndices.map((i) => _selectedRows[i]).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          trackVisibility: true,
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                headingRowHeight: 48.0,
                dataRowMinHeight: 48.0,
                dataRowMaxHeight: 52.0,
                columnSpacing: 16.0,
                horizontalMargin: 12.0,
                headingTextStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF4A5568)),
                dataTextStyle: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                headingRowColor: MaterialStateProperty.resolveWith(
                    (states) => const Color(0xFFF0F4F8)),
                
                sortAscending: _isAscending,
                sortColumnIndex: _sortColumnIndex == -1 ? null : _sortColumnIndex,
                
                onSelectAll: _internalData.isNotEmpty && widget.onSelectionChanged != null ? _onSelectAll : null,
                
                columns: _buildColumns(),
                rows: _buildRows(),
              ),
            ),
          ),
        );
      },
    );
  }

  List<DataColumn> _buildColumns() {
    List<DataColumn> columns = [];

    for (int i = 0; i < widget.headers.length; i++) {
      final headerText = widget.headers[i];
      columns.add(
        DataColumn(
          label: Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      headerText,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_sortColumnIndex == i)
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Icon(
                        _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 16,
                        color: const Color(0xFF4A5568),
                      ),
                    ),
                ],
              ),
            ),
          ),
          onSort: (columnIndex, ascending) => _sortData(columnIndex),
        ),
      );
    }

    // Actions column
    if (widget.onEdit != null || widget.onDelete != null) {
      columns.add(
        const DataColumn(
          label: SizedBox(
            width: 56,
            child: Center(child: Text("AÇÕES")),
          ),
        ),
      );
    }
    return columns;
  }

  List<DataRow> _buildRows() {
    if (_internalData.isEmpty) return [];

    return List.generate(_internalData.length, (i) {
        final rowData = _internalData[i];
        final isSelected = (i < _selectedRows.length) ? _selectedRows[i] : false;
        
        return DataRow(
            selected: isSelected,
            onSelectChanged: widget.onSelectionChanged != null ? (selected) => _onRowSelected(i, selected) : null,
            color: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
                return Theme.of(context).primaryColor.withOpacity(0.12);
            }
            return Colors.transparent;
            }),
            cells: _buildCellsForRow(rowData, i),
        );
    });
  }

  List<DataCell> _buildCellsForRow(List<String> rowData, int rowIndex) {
    List<DataCell> cells = [];

    for (int j = 0; j < widget.headers.length; j++) {
      final cellData = (j < rowData.length) ? rowData[j] : '';
      final header = widget.headers[j];
      Widget cellWidget;

      if (header.toLowerCase() == 'status' || header.toLowerCase() == 'pagamento') {
        cellWidget = StatusChip(status: cellData);
      } else {
        cellWidget = Text(
          cellData,
          overflow: TextOverflow.ellipsis,
        );
      }
      cells.add(DataCell(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          alignment: Alignment.centerLeft,
          child: cellWidget
        )
      ));
    }

    // Actions cell
    if (widget.onEdit != null || widget.onDelete != null) {
      cells.add(
        DataCell(
          SizedBox(
            width: 56,
            child: Container(
              alignment: Alignment.center,
              child: PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey.shade600, size: 20,),
                tooltip: "Ações",
                onSelected: (value) {
                  if (value == 'edit' && widget.onEdit != null) {
                    widget.onEdit!(rowIndex);
                  } else if (value == 'delete' && widget.onDelete != null) {
                    widget.onDelete!(rowIndex);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  if (widget.onEdit != null)
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 8), Text('Editar')]),
                    ),
                  if (widget.onDelete != null)
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(children: [Icon(Icons.delete_outline, size: 18, color: Colors.red), SizedBox(width: 8), Text('Excluir', style: TextStyle(color: Colors.red))]),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return cells;
  }
}
