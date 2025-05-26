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
    String statusText = status; // Default to the provided status

    // Normalize status text for comparison
    String lowerStatus = status.toLowerCase();

    if (lowerStatus == 'active' || lowerStatus == 'ativo') {
      backgroundColor = Colors.green.shade100;
      textColor = Colors.green.shade800;
      iconData = Icons.check_circle;
      statusText = 'Active'; // Standardize display text
    } else if (lowerStatus == 'inactive' || lowerStatus == 'inativo') {
      backgroundColor = Colors.red.shade100;
      textColor = Colors.red.shade800;
      iconData = Icons.cancel;
      statusText = 'Inactive'; // Standardize display text
    } else { // Default for other statuses like 'Pending'
      backgroundColor = Colors.orange.shade100;
      textColor = Colors.orange.shade800;
      iconData = Icons.hourglass_empty;
      // statusText remains as is, or you can map it e.g. 'Pending'
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
  // columnWidthsPercentages is not directly used by DataTable for flexible widths,
  // but kept for potential future use or if swapping to a 'Table' widget.
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
    // Optionally reset sort when data changes significantly
    // _sortColumnIndex = -1; 
  }

  void _onSelectAll(bool? selected) {
    setState(() {
      _selectAll = selected ?? false;
      for (int i = 0; i < _selectedRows.length; i++) {
        _selectedRows[i] = _selectAll;
      }
      _notifySelectionChange();
    });
  }

  void _onRowSelected(int index, bool? selected) {
    // Ensure index is within bounds, relevant if data can change rapidly
    if (index < 0 || index >= _selectedRows.length) return;
    setState(() {
      _selectedRows[index] = selected ?? false;
      _selectAll = _selectedRows.every((isSelected) => isSelected) && _selectedRows.isNotEmpty;
      _notifySelectionChange();
    });
  }

  void _notifySelectionChange() {
    if (widget.onSelectionChanged != null) {
      final selectedIndices = <int>[];
      for (int i = 0; i < _selectedRows.length; i++) {
        if (_selectedRows[i]) {
          selectedIndices.add(i); // These indices are for the currently displayed (possibly sorted) data
        }
      }
      widget.onSelectionChanged!(selectedIndices);
    }
  }

  void _sortData(int dataTableColumnIndex) {
    // dataTableColumnIndex is the index received from DataTable's onSort,
    // which includes the checkbox column.
    // We need to map it to an index within widget.headers.
    int headerIndex = dataTableColumnIndex - 1; // Subtract 1 for the checkbox column

    if (headerIndex < 0 || headerIndex >= widget.headers.length) {
      // Clicked on checkbox column or actions column (if it were sortable)
      return; 
    }

    setState(() {
      if (_sortColumnIndex == headerIndex) {
        _isAscending = !_isAscending;
      } else {
        _sortColumnIndex = headerIndex;
        _isAscending = true;
      }

      // Create a list of indices to sort, then rebuild _internalData based on sorted original data
      // This helps if _selectedRows needs to map back to original unsorted data indices.
      // For simplicity here, we sort _internalData directly.
      // Be mindful if actions (edit/delete) need original indices.
      _internalData.sort((a, b) {
        if (a.length <= headerIndex || b.length <= headerIndex) {
          return 0; 
        }
        final aValue = a[headerIndex];
        final bValue = b[headerIndex];

        double? aNum = double.tryParse(aValue);
        double? bNum = double.tryParse(bValue);

        int comparison;
        if (aNum != null && bNum != null) {
          comparison = aNum.compareTo(bNum);
        } else {
          comparison = aValue.toLowerCase().compareTo(bValue.toLowerCase()); // Case-insensitive string sort
        }
        return _isAscending ? comparison : -comparison;
      });
      
      // After sorting, selection state needs to be reset or remapped.
      // Simplest is to reset:
      _selectedRows = List<bool>.filled(_internalData.length, false);
      _selectAll = false;
      _notifySelectionChange(); // Notify that selection has changed (cleared)
    });
  }

  @override
  Widget build(BuildContext context) {
    // This LayoutBuilder ensures that the DataTable can be constrained
    // to take the full width available to the ResponsiveTable widget.
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox( // Force DataTable to be at least as wide as its parent
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              headingRowHeight: 48.0,
              dataRowMinHeight: 48.0, 
              dataRowMaxHeight: 52.0, 
              columnSpacing: 16.0, // Give some default spacing
              horizontalMargin: 12.0, // Give some horizontal margin
              headingRowColor: MaterialStateProperty.resolveWith(
                  (states) => const Color(0xFFF0F4F8)), 
              
              sortAscending: _isAscending,
              // DataTable's sortColumnIndex includes the checkbox column, so add 1
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

    columns.add(
      DataColumn(
        label: Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 4.0), 
          child: Checkbox(
            visualDensity: VisualDensity.compact,
            value: _selectAll,
            onChanged: _selectedRows.isNotEmpty ? _onSelectAll : null, // Disable if no data
            activeColor: Theme.of(context).primaryColor,
            side: BorderSide(color: Colors.grey.shade400),
          ),
        ),
      ),
    );

    for (int i = 0; i < widget.headers.length; i++) {
      final headerText = widget.headers[i];
      columns.add(
        DataColumn(
          // Wrap label in Expanded to allow it to take available space within the column.
          // This is more relevant if column widths were fixed or proportionally set.
          // With content-driven widths, it ensures text doesn't overflow its cell.
          label: Expanded( 
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min, // Important for Expanded to work in Row
                children: [
                  Flexible( // Allow text to wrap or truncate
                    child: Text(
                      headerText,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF4A5568), 
                      ),
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
          // Pass the DataTable's column index (which includes checkbox col)
          onSort: (columnIndex, ascending) => _sortData(columnIndex), 
        ),
      );
    }

    columns.add(
      DataColumn(
        label: Container(
          width: 56, // Fixed width for actions column
          alignment: Alignment.center,
          // child: Text('Ações', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF4A5568))),
        ),
      ),
    );
    return columns;
  }

  List<DataRow> _buildRows() {
    List<DataRow> rows = [];
    if (_internalData.isEmpty) return rows;

    for (int i = 0; i < _internalData.length; i++) {
      final rowData = _internalData[i];
      rows.add(
        DataRow(
          selected: _selectedRows[i],
          onSelectChanged: (selected) => _onRowSelected(i, selected),
          color: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return Theme.of(context).primaryColor.withOpacity(0.12);
            }
            // Removed alternating row colors for a cleaner look like the image
            // if (i.isEven) return Colors.white.withOpacity(0.5); 
            // return Colors.grey.shade50.withOpacity(0.5);     
            return Colors.transparent; // Transparent for card background to show
          }),
          cells: _buildCellsForRow(rowData, i),
        ),
      );
    }
    return rows;
  }

  List<DataCell> _buildCellsForRow(List<String> rowData, int rowIndex) {
    List<DataCell> cells = [];

    cells.add(
      DataCell(
        Padding(
          padding: const EdgeInsets.only(left:12.0, right: 4.0),
          child: Checkbox(
            visualDensity: VisualDensity.compact,
            value: _selectedRows[rowIndex],
            onChanged: (selected) => _onRowSelected(rowIndex, selected),
            activeColor: Theme.of(context).primaryColor,
            side: BorderSide(color: Colors.grey.shade400),
          ),
        ),
      ),
    );

    for (int j = 0; j < widget.headers.length; j++) {
      final cellData = (j < rowData.length) ? rowData[j] : ''; 
      final header = widget.headers[j];
      Widget cellWidget;

      if (header.toLowerCase() == 'status') {
        cellWidget = StatusChip(status: cellData);
      } else {
        cellWidget = Text(
          cellData,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
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
        Container(
          width: 56,
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
                child: Text('Editar'),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text('Excluir'),
              ),
            ],
          ),
        ),
      ),
    );
    return cells;
  }
}
