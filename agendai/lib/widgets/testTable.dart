import 'package:flutter/material.dart';

class TestTable extends StatefulWidget {
  //final List<String> headers;
  //final List<List<String>> data;
  final List<Map<String, dynamic>>? dataMap;
  final Function(List<int> selectedIndices)? onSelectionChanged;
  final Function(dynamic rowId)? onEdit;
  final Function(dynamic rowId)? onDelete;
  //final Map<String, double>? columnWidthsPercentages;
  //final Map<String, String>? columnLabels;
  final bool showActions;
  final String idField;

  const TestTable({
    super.key,
    //required this.headers,
    //required this.data,
    this.dataMap,
    this.onSelectionChanged,
    this.onEdit,
    this.onDelete,
    //this.columnWidthsPercentages,
    // this.columnLabels,
    this.showActions = true,
    this.idField = 'id',
  });

  @override
  _TestTableState createState() => _TestTableState();
}

class _TestTableState extends State<TestTable> {
  late List<List<String>> _internalData;
  late List<bool> _selectedRows;
  bool _selectAll = false;
  final int _sortColumnIndex = -1;
  final bool _isAscending = true;

  // @override
  // void initState() {
  //   super.initState();
  //   _initializeData();
  // }

  @override
  // void didUpdateWidget(TestTable oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   if (widget.data != oldWidget.data || widget.headers != oldWidget.headers) {
  //     _initializeData();
  //   }
  // }

  // void _initializeData() {
  //   _internalData = List<List<String>>.from(
  //       widget.data.map((row) => List<String>.from(row)));
  //   _selectedRows = List<bool>.filled(_internalData.length, false);
  //   _selectAll = false;
  //   // _sortColumnIndex = -1; // Reset sort if data fundamentally changes
  // }

  void _onSelectAll(bool? selected) {
    if (_internalData.isEmpty)
      return; // Safety check, though checkbox should be disabled
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
      _selectedRows[index] = selected ?? false;
      if (_selectedRows.isNotEmpty) {
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

  @override
  Widget build(BuildContext context) {
    final columns = widget.dataMap!.first.keys.toList();
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
              headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0xFF4A5568)),
              dataTextStyle:
                  TextStyle(fontSize: 13, color: Colors.grey.shade800),
              headingRowColor: WidgetStateProperty.resolveWith(
                  (states) => const Color(0xFFF0F4F8)),
              sortAscending: _isAscending,
              sortColumnIndex:
                  _sortColumnIndex != -1 ? _sortColumnIndex + 1 : null,
              columns: [
                ...columns.map((col) => DataColumn(
                      label: Text(col),
                    )),
                if (widget.showActions)
                  DataColumn(
                    label: Container(
                      width: 56,
                      alignment: Alignment.center,
                    ),
                  ),
              ],
              rows: widget.dataMap!.map((row) {
                final rowId = row[widget.idField];
                List<DataCell> cells = columns.map((col) {
                  return DataCell(Text(row[col]?.toString() ?? ''));
                }).toList();

                if (widget.showActions) {
                  cells.add(
                    DataCell(
                      SizedBox(
                        width: 56,
                        child: Container(
                          alignment: Alignment.center,
                          child: PopupMenuButton<String>(
                            icon: Icon(
                              Icons.more_vert,
                              color: Colors.grey.shade600,
                              size: 20,
                            ),
                            tooltip: "Ações",
                            onSelected: (value) {
                              if (value == 'edit' && widget.onEdit != null) {
                                widget.onEdit!(rowId);
                              } else if (value == 'delete' &&
                                  widget.onDelete != null) {
                                widget.onDelete!(rowId);
                              }
                            },
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'edit',
                                child: Row(children: [
                                  Icon(Icons.edit_outlined, size: 18),
                                  SizedBox(width: 8),
                                  Text('Editar')
                                ]),
                              ),
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: Row(children: [
                                  Icon(Icons.delete_outline,
                                      size: 18, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Excluir',
                                      style: TextStyle(color: Colors.red))
                                ]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return DataRow(
                  onSelectChanged: (selected) => _onRowSelected(
                    widget.dataMap!.indexOf(row),
                    selected,
                  ),
                  cells: cells,
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
