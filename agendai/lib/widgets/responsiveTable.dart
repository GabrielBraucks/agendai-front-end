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

    if (lowerStatus == 'active' || lowerStatus == 'ativo') {
      backgroundColor = Colors.green.shade100;
      textColor = Colors.green.shade800;
      iconData = Icons.check_circle;
      statusText = 'Active'; 
    } else if (lowerStatus == 'inactive' || lowerStatus == 'inativo') {
      backgroundColor = Colors.red.shade100;
      textColor = Colors.red.shade800;
      iconData = Icons.cancel;
      statusText = 'Inactive'; 
    } else { 
      backgroundColor = Colors.orange.shade100;
      textColor = Colors.orange.shade800;
      iconData = Icons.hourglass_empty;
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

  @override
  void initState() {
    super.initState();
    _initializeData();
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
    // _sortColumnIndex = -1; // Reset sort if data fundamentally changes
  }

  void _onSelectAll(bool? selected) {
    if (_internalData.isEmpty) return; // Safety check, though checkbox should be disabled
    setState(() {
      _selectAll = selected ?? false;
      for (int i = 0; i < _selectedRows.length; i++) {
        _selectedRows[i] = _selectAll;
      }
      _notifySelectionChange();
    });
  }

  void _onRowSelected(int index, bool? selected) {
    if (index < 0 || index >= _selectedRows.length) return; // Bounds check
    setState(() {
    print(_selectedRows);
      _selectedRows[index] = selected ?? false;
      if (_internalData.isNotEmpty) {
        _selectAll = _selectedRows.every((isSelected) => isSelected);
      } else {
        _selectAll = false; // Should be handled by _internalData.isEmpty check too
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
    int headerIndex = dataTableColumnIndex - 1; 

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

      _internalData.sort((a, b) {
        if (a.length <= headerIndex || b.length <= headerIndex) return 0; 
        
        final aValue = a[headerIndex];
        final bValue = b[headerIndex];

        double? aNum = double.tryParse(aValue);
        double? bNum = double.tryParse(bValue);

        int comparison;
        if (aNum != null && bNum != null) {
          comparison = aNum.compareTo(bNum);
        } else {
          comparison = aValue.toLowerCase().compareTo(bValue.toLowerCase()); 
        }
        return _isAscending ? comparison : -comparison;
      });
      
      // Reset selection after sort, as indices change meaning
      _selectedRows = List<bool>.filled(_internalData.length, false);
      _selectAll = false;
      _notifySelectionChange(); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
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
              sortColumnIndex: _sortColumnIndex != -1 ? _sortColumnIndex + 1 : null,
              
              columns: _buildColumns(),
              rows: _buildRows(),
            ),
          ),
        );
      },
    );
  }

  List<DataColumn> _buildColumns() {
    List<DataColumn> columns = [];

    // columns.add(
    //   DataColumn(
    //     label: Padding(
    //       padding: const EdgeInsets.only(left: 12.0, right: 4.0), 
    //       child: Checkbox(
    //         visualDensity: VisualDensity.compact,
    //         value: _selectAll,
    //         // Disable checkbox if there is no data to select
    //         onChanged: _internalData.isNotEmpty ? _onSelectAll : null, 
    //         activeColor: Theme.of(context).primaryColor,
    //         side: BorderSide(color: Colors.grey.shade400),
    //       ),
    //     ),
    //   ),
    // );

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

    columns.add(
      DataColumn(
        label: Container( // Placeholder for actions column header
          width: 56, 
          alignment: Alignment.center,
        ),
      ),
    );
    return columns;
  }

  List<DataRow> _buildRows() {
    List<DataRow> rows = [];
    if (_internalData.isEmpty) return rows; // No rows if no data

    for (int i = 0; i < _internalData.length; i++) {
      final rowData = _internalData[i];
      // This check ensures _selectedRows is accessed safely if its length
      // somehow mismatches _internalData during a rapid update.
      final bool isSelected = (i < _selectedRows.length) ? _selectedRows[i] : false;

      rows.add(
        DataRow(
          selected: isSelected,
          onSelectChanged: (selected) => _onRowSelected(i, selected),
          color: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return Theme.of(context).primaryColor.withOpacity(0.12);
            }
            return Colors.transparent; 
          }),
          cells: _buildCellsForRow(rowData, i, isSelected), // Pass isSelected for checkbox
        ),
      );
    }
    return rows;
  }

  List<DataCell> _buildCellsForRow(List<String> rowData, int rowIndex, bool currentIsSelected) {
    List<DataCell> cells = [];
    
    // cells.add(
    //   DataCell(
    //     Padding(
    //       padding: const EdgeInsets.only(left:12.0, right: 4.0),
    //       child: Checkbox(
    //         visualDensity: VisualDensity.compact,
    //         value: currentIsSelected, // Use passed currentIsSelected for reliability
    //         onChanged: (selected) => _onRowSelected(rowIndex, selected),
    //         activeColor: Theme.of(context).primaryColor,
    //         side: BorderSide(color: const Color.fromARGB(255, 126, 46, 46)),
    //       ),
    //     ),
    //   ),
    // );

    for (int j = 0; j < widget.headers.length; j++) {
      final cellData = (j < rowData.length) ? rowData[j] : ''; 
      final header = widget.headers[j];
      Widget cellWidget;

      if (header.toLowerCase() == 'status') {
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
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 8), Text('Editar')]),
                ),
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
    return cells;
  }
}
