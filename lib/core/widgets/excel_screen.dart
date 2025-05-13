import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;

class ExcelAssessment extends StatefulWidget {
  const ExcelAssessment({super.key});

  @override
  State<ExcelAssessment> createState() => _ExcelAssessmentState();
}

class _ExcelAssessmentState extends State<ExcelAssessment> {
  late List<TestData> _referenceData;
  late TestDataSource dataSource;
  bool _isAssessmentCompleted = false;
  int _score = 0;
  final int maxScore = 100;
  List<String> _feedbackItems = [];
  bool _isExpanded =
      true; // Controls the expansion state of the instruction panel

  // Cell selection and editing variables
  RowColumnIndex? _selectedCell;
  final TextEditingController _cellEditingController = TextEditingController();
  bool _isEditing = false;
  final FocusNode _cellFocusNode = FocusNode();

  // Formula bar variables
  final TextEditingController _formulaController = TextEditingController();
  String _activeCellReference = 'A1';

  // Excel data structure
  List<List<ExcelCellData>> _excelData = [];

  @override
  void initState() {
    super.initState();
    // Initialize with sample data
    _referenceData = [
      TestData('Laptops', 35000, 42000, 38000, 40000),
      TestData('Monitors', 18500, 21200, 19800, 23400),
      TestData('Keyboards', 9200, 8700, 10500, 9800),
      TestData('Mice', 7500, 8200, 7800, 8600),
      TestData('Headphones', 12800, 14500, 13200, 15800),
    ];

    // Initialize user's data grid with empty values
    dataSource = TestDataSource(
      List.generate(5, (index) => TestData('', 0, 0, 0, 0)),
    );

    // Initialize excel data structure (11 rows x 7 columns)
    _initializeExcelData();

    // Set up focus node listener for handling cell editing
    _cellFocusNode.addListener(() {
      if (!_cellFocusNode.hasFocus && _isEditing) {
        _finishEditing();
      }
    });
  }

  @override
  void dispose() {
    _cellEditingController.dispose();
    _formulaController.dispose();
    _cellFocusNode.dispose();
    super.dispose();
  }

  void _initializeExcelData() {
    _excelData = List.generate(11, (rowIndex) {
      return List.generate(7, (colIndex) {
        if (rowIndex == 0 && colIndex == 0) {
          // Title cell (A1)
          return ExcelCellData(
            value: "Quarterly Sales Report",
            isHeader: true,
            colSpan: 7,
            alignment: Alignment.center,
          );
        } else if (rowIndex == 2) {
          // Header row (row 3)
          final headers = [
            'Product',
            'Q1',
            'Q2',
            'Q3',
            'Q4',
            'Total',
            'Average',
          ];
          return ExcelCellData(
            value: headers[colIndex],
            isHeader: true,
            backgroundColor: const Color(0xFFD8E4BC),
          );
        } else if (rowIndex >= 3 && rowIndex < 8) {
          // Data rows (rows 4-8)
          if (colIndex == 0) {
            return ExcelCellData(value: ""); // Product name
          } else if (colIndex < 5) {
            return ExcelCellData(
              value: "",
              isNumeric: true,
              format: "\$#,##0.00",
            );
          } else if (colIndex == 5) {
            // Total column
            return ExcelCellData(
              formula: "=SUM(B${rowIndex + 1}:E${rowIndex + 1})",
              isNumeric: true,
              format: "\$#,##0.00",
              backgroundColor: const Color(0xFFC6EFCE),
            );
          } else {
            // Average column
            return ExcelCellData(
              formula: "=AVERAGE(B${rowIndex + 1}:E${rowIndex + 1})",
              isNumeric: true,
              format: "\$#,##0.00",
              backgroundColor: const Color(0xFFC6EFCE),
            );
          }
        } else if (rowIndex == 9) {
          // Grand Total row
          if (colIndex == 0) {
            return ExcelCellData(
              value: "Grand Total",
              isHeader: true,
              backgroundColor: const Color(0xFFD8E4BC),
            );
          } else if (colIndex < 5) {
            return ExcelCellData(
              formula:
                  "=SUM(${String.fromCharCode(65 + colIndex)}4:${String.fromCharCode(65 + colIndex)}8)",
              isNumeric: true,
              format: "\$#,##0.00",
              backgroundColor: const Color(0xFFD8E4BC),
            );
          } else if (colIndex == 5) {
            return ExcelCellData(
              formula: "=SUM(F4:F8)",
              isNumeric: true,
              format: "\$#,##0.00",
              backgroundColor: const Color(0xFFD8E4BC),
            );
          } else {
            return ExcelCellData(
              formula: "=AVERAGE(G4:G8)",
              isNumeric: true,
              format: "\$#,##0.00",
              backgroundColor: const Color(0xFFD8E4BC),
            );
          }
        } else {
          // Empty cells
          return ExcelCellData(value: "");
        }
      });
    });
  }

  void _evaluateAssessment() {
    int score = 0;
    List<String> feedback = [];

    // Convert Excel data to TestData for evaluation
    List<TestData> userEnteredData = [];
    for (int row = 3; row < 8; row++) {
      if (_excelData[row][0].value.isNotEmpty) {
        userEnteredData.add(
          TestData(
            _excelData[row][0].value,
            _getCellNumericValue(row, 1),
            _getCellNumericValue(row, 2),
            _getCellNumericValue(row, 3),
            _getCellNumericValue(row, 4),
          ),
        );
      }
    }

    // Check product names (20 points)
    int productNameScore = 0;
    for (int i = 0; i < _referenceData.length; i++) {
      if (i < userEnteredData.length) {
        if (userEnteredData[i].product.toLowerCase() ==
            _referenceData[i].product.toLowerCase()) {
          productNameScore += 4; // 4 points per correct product name
        }
      }
    }
    score += productNameScore;
    feedback.add('Product Names: $productNameScore/20 points');

    // Check quarterly values (40 points)
    int quarterlyValueScore = 0;
    for (int i = 0; i < _referenceData.length; i++) {
      if (i < userEnteredData.length) {
        if (userEnteredData[i].q1 == _referenceData[i].q1) {
          quarterlyValueScore += 2;
        }
        if (userEnteredData[i].q2 == _referenceData[i].q2) {
          quarterlyValueScore += 2;
        }
        if (userEnteredData[i].q3 == _referenceData[i].q3) {
          quarterlyValueScore += 2;
        }
        if (userEnteredData[i].q4 == _referenceData[i].q4) {
          quarterlyValueScore += 2;
        }
      }
    }
    score += quarterlyValueScore;
    feedback.add('Quarterly Values: $quarterlyValueScore/40 points');

    // Check data structure (20 points)
    int rowScore = min(
      20,
      (userEnteredData.length == _referenceData.length)
          ? 20
          : (userEnteredData.length >= _referenceData.length * 0.8)
          ? 15
          : (userEnteredData.length >= _referenceData.length * 0.6)
          ? 10
          : 5,
    );
    score += rowScore;
    feedback.add('Data Structure: $rowScore/20 points');

    // Check formulas (20 points)
    int formulaScore = 0;

    // Check SUM formulas (10 points)
    bool hasSumFormulas = false;
    for (int row = 3; row < 8; row++) {
      if (_excelData[row][5].formula != null &&
          _excelData[row][5].formula!.toUpperCase().contains('SUM')) {
        hasSumFormulas = true;
        break;
      }
    }

    if (hasSumFormulas) {
      formulaScore += 10;
      feedback.add('SUM Formulas: 10/10 points');
    } else {
      feedback.add('SUM Formulas: 0/10 points');
    }

    // Check AVERAGE formulas (10 points)
    bool hasAverageFormulas = false;
    for (int row = 3; row < 8; row++) {
      if (_excelData[row][6].formula != null &&
          _excelData[row][6].formula!.toUpperCase().contains('AVERAGE')) {
        hasAverageFormulas = true;
        break;
      }
    }

    if (hasAverageFormulas) {
      formulaScore += 10;
      feedback.add('AVERAGE Formulas: 10/10 points');
    } else {
      feedback.add('AVERAGE Formulas: 0/10 points');
    }

    score += formulaScore;

    setState(() {
      _score = score;
      _feedbackItems = feedback;
      _isAssessmentCompleted = true;
    });
  }

  double _getCellNumericValue(int row, int col) {
    if (_excelData[row][col].isNumeric) {
      // If it's a formula cell, should return the calculated value
      // For this example, we'll just return the parsed value
      final value = _excelData[row][col].value;
      if (value.isNotEmpty) {
        return double.tryParse(value.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
      }
    }
    return 0;
  }

  void _exportToExcel() async {
    final workbook = xlsio.Workbook();
    final sheet = workbook.worksheets[0];
    sheet.name = 'Sales Report';

    // Add a title
    sheet.getRangeByName('A1').setText('Quarterly Sales Report');
    final titleStyle = workbook.styles.add('TitleStyle');
    titleStyle.fontSize = 16;
    titleStyle.bold = true;
    sheet.getRangeByName('A1:G1').cellStyle = titleStyle;
    sheet.getRangeByName('A1:G1').merge();

    // Add headers
    final headerRow = 3;
    final headerStyle = workbook.styles.add('HeaderStyle');
    headerStyle.bold = true;
    headerStyle.hAlign = xlsio.HAlignType.center;
    headerStyle.backColor = '#D8E4BC';
    headerStyle.borders.all.lineStyle = xlsio.LineStyle.thin;

    final headers = ['Product', 'Q1', 'Q2', 'Q3', 'Q4', 'Total', 'Average'];

    for (int i = 0; i < headers.length; i++) {
      final column = String.fromCharCode(65 + i); // A, B, C, ...
      sheet.getRangeByName('$column$headerRow').setText(headers[i]);
      sheet.getRangeByName('$column$headerRow').cellStyle = headerStyle;
    }

    // Add data
    final dataStyle = workbook.styles.add('DataStyle');
    dataStyle.borders.all.lineStyle = xlsio.LineStyle.thin;

    final currencyStyle = workbook.styles.add('CurrencyStyle');
    currencyStyle.numberFormat = r'_($* #,##0.00_)';
    currencyStyle.borders.all.lineStyle = xlsio.LineStyle.thin;

    // Export Excel data from our model
    for (int row = 3; row < 8; row++) {
      if (_excelData[row][0].value.isNotEmpty) {
        final excelRow = row + 1; // Excel rows are 1-based

        // Add product name
        sheet.getRangeByName('A$excelRow').setText(_excelData[row][0].value);
        final cellStyle =
            _excelData[row][0].isBold == true ? headerStyle : dataStyle;
        sheet.getRangeByName('A$excelRow').cellStyle = cellStyle;

        // Add quarterly values
        for (int col = 1; col <= 4; col++) {
          final value = _getCellNumericValue(row, col);
          final column = String.fromCharCode(65 + col); // B, C, D, E
          sheet.getRangeByName('$column$excelRow').setNumber(value);

          // Apply custom cell style if needed
          if (_excelData[row][col].isBold == true) {
            final customStyle = workbook.styles.add('CustomStyle${row}_$col');
            customStyle.numberFormat = r'_($* #,##0.00_)';
            customStyle.borders.all.lineStyle = xlsio.LineStyle.thin;
            customStyle.bold = true;
            sheet.getRangeByName('$column$excelRow').cellStyle = customStyle;
          } else {
            sheet.getRangeByName('$column$excelRow').cellStyle = currencyStyle;
          }

          // Apply background color if set
          if (_excelData[row][col].backgroundColor != null) {
            final color = _excelData[row][col].backgroundColor!;
            // Convert color to hex string
            final hexColor = '#${color.value.toRadixString(16).substring(2)}';
            sheet.getRangeByName('$column$excelRow').cellStyle.backColor =
                hexColor;
          }
        }

        // Handle merge cells
        for (int col = 0; col < _excelData[row].length; col++) {
          if (_excelData[row][col].colSpan != null &&
              _excelData[row][col].colSpan! > 1) {
            final startColumn = String.fromCharCode(65 + col);
            final endColumn = String.fromCharCode(
              65 + col + _excelData[row][col].colSpan! - 1,
            );
            sheet
                .getRangeByName('$startColumn$excelRow:$endColumn$excelRow')
                .merge();

            // Ensure the cell has the correct value
            sheet
                .getRangeByName('$startColumn$excelRow')
                .setText(_excelData[row][col].value);

            // Center merged cells
            sheet.getRangeByName('$startColumn$excelRow').cellStyle.hAlign =
                xlsio.HAlignType.center;

            // Skip to next unmerged cell
            col += _excelData[row][col].colSpan! - 1;
          }
        }

        // Add formulas
        if (_excelData[row][5].formula != null) {
          sheet.getRangeByName('F$excelRow').formula =
              _excelData[row][5].formula;
        } else {
          sheet.getRangeByName('F$excelRow').formula =
              '=SUM(B$excelRow:E$excelRow)';
        }

        if (_excelData[row][6].formula != null) {
          sheet.getRangeByName('G$excelRow').formula =
              _excelData[row][6].formula;
        } else {
          sheet.getRangeByName('G$excelRow').formula =
              '=AVERAGE(B$excelRow:E$excelRow)';
        }
      }
    }

    // Rest of the export method remains the same...

    // Save the file
    final bytes = workbook.saveAsStream();
    workbook.dispose();

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/CandidateSubmission.xlsx';
    final file = File(path);
    await file.writeAsBytes(bytes);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Excel file exported to: $path'),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _resetAssessment() {
    setState(() {
      dataSource = TestDataSource(
        List.generate(5, (index) => TestData('', 0, 0, 0, 0)),
      );
      _isAssessmentCompleted = false;
      _score = 0;
      _feedbackItems.clear();
      _initializeExcelData();
      _selectedCell = null;
      _cellEditingController.clear();
      _formulaController.clear();
      _activeCellReference = 'A1';
    });
  }

  String _getCellReference(int row, int col) {
    final column = String.fromCharCode(65 + col); // Convert 0->A, 1->B, etc.
    return '$column${row + 1}'; // Excel rows are 1-based
  }

  void _selectCell(int row, int col) {
    // Don't allow selection of the title span cell except for the first cell
    if (row == 0 && col > 0) return;

    setState(() {
      if (_isEditing) _finishEditing();

      _selectedCell = RowColumnIndex(row, col);
      _activeCellReference = _getCellReference(row, col);

      // Update formula bar
      final cell = _excelData[row][col];
      if (cell.formula != null) {
        _formulaController.text = cell.formula!;
      } else {
        _formulaController.text = cell.value;
      }
    });
  }

  void _startEditing() {
    if (_selectedCell == null) return;

    final row = _selectedCell!.rowIndex;
    final col = _selectedCell!.columnIndex;
    final cell = _excelData[row][col];

    setState(() {
      _isEditing = true;
      _cellEditingController.text = cell.formula ?? cell.value;
      // Request focus on the next frame to ensure the text field is properly built
      Future.microtask(() => _cellFocusNode.requestFocus());
    });
  }

  void _finishEditing() {
    if (!_isEditing || _selectedCell == null) return;

    final row = _selectedCell!.rowIndex;
    final col = _selectedCell!.columnIndex;
    final value = _cellEditingController.text;

    setState(() {
      if (value.startsWith('=')) {
        _excelData[row][col].formula = value;
        _excelData[row][col].value = _evaluateFormula(value, row, col);
      } else {
        _excelData[row][col].formula = null;
        _excelData[row][col].value = value;
      }

      _isEditing = false;
      _cellEditingController.clear();

      // Update formula bar
      _formulaController.text = value;

      // Update data source for assessment
      _updateDataSourceFromExcelData();
    });
  }

  void _updateFormulaBar() {
    if (_selectedCell == null) return;

    final row = _selectedCell!.rowIndex;
    final col = _selectedCell!.columnIndex;
    final value = _formulaController.text;

    setState(() {
      if (value.startsWith('=')) {
        _excelData[row][col].formula = value;
        _excelData[row][col].value = _evaluateFormula(value, row, col);
      } else {
        _excelData[row][col].formula = null;
        _excelData[row][col].value = value;
      }

      // Update data source for assessment
      _updateDataSourceFromExcelData();
    });
  }

  String _evaluateFormula(String formula, int row, int col) {
    // This is a simplified formula evaluator
    // In a real implementation, you'd need a proper formula parser
    try {
      if (formula.toUpperCase().startsWith('=SUM(')) {
        // Handle SUM formula
        final rangeStr = formula.substring(5, formula.length - 1);
        final parts = rangeStr.split(':');
        if (parts.length == 2) {
          final start = _parseCellReference(parts[0]);
          final end = _parseCellReference(parts[1]);

          double sum = 0;
          for (int r = start.rowIndex; r <= end.rowIndex; r++) {
            for (int c = start.columnIndex; c <= end.columnIndex; c++) {
              if (r < _excelData.length && c < _excelData[r].length) {
                final value = _excelData[r][c].value;
                if (value.isNotEmpty) {
                  sum +=
                      double.tryParse(
                        value.replaceAll(RegExp(r'[^\d.]'), ''),
                      ) ??
                      0;
                }
              }
            }
          }
          return '\$${sum.toStringAsFixed(2)}';
        }
      } else if (formula.toUpperCase().startsWith('=AVERAGE(')) {
        // Handle AVERAGE formula
        final rangeStr = formula.substring(9, formula.length - 1);
        final parts = rangeStr.split(':');
        if (parts.length == 2) {
          final start = _parseCellReference(parts[0]);
          final end = _parseCellReference(parts[1]);

          double sum = 0;
          int count = 0;
          for (int r = start.rowIndex; r <= end.rowIndex; r++) {
            for (int c = start.columnIndex; c <= end.columnIndex; c++) {
              if (r < _excelData.length && c < _excelData[r].length) {
                final value = _excelData[r][c].value;
                if (value.isNotEmpty) {
                  sum +=
                      double.tryParse(
                        value.replaceAll(RegExp(r'[^\d.]'), ''),
                      ) ??
                      0;
                  count++;
                }
              }
            }
          }

          if (count > 0) {
            return '\$${(sum / count).toStringAsFixed(2)}';
          }
        }
      }
    } catch (e) {
      debugPrint('Formula evaluation error: $e');
    }

    return ''; // Return empty string if formula can't be evaluated
  }

  RowColumnIndex _parseCellReference(String ref) {
    // Parse cell references like A1, B2, etc.
    final pattern = RegExp(r'([A-Z])(\d+)');
    final match = pattern.firstMatch(ref);

    if (match != null) {
      final col = match.group(1)!.codeUnitAt(0) - 'A'.codeUnitAt(0);
      final row = int.parse(match.group(2)!) - 1; // Convert to 0-based index
      return RowColumnIndex(row, col);
    }

    return RowColumnIndex(0, 0); // Default to A1 if parsing fails
  }

  void _updateDataSourceFromExcelData() {
    // Update the data source from Excel data
    final data = <TestData>[];

    for (int row = 3; row < 8; row++) {
      if (_excelData[row][0].value.isNotEmpty) {
        data.add(
          TestData(
            _excelData[row][0].value,
            _getCellNumericValue(row, 1),
            _getCellNumericValue(row, 2),
            _getCellNumericValue(row, 3),
            _getCellNumericValue(row, 4),
          ),
        );
      }
    }

    dataSource = TestDataSource(data);
  }

  void _applyCellFormat(Color backgroundColor) {
    if (_selectedCell == null) return;

    final row = _selectedCell!.rowIndex;
    final col = _selectedCell!.columnIndex;

    setState(() {
      _excelData[row][col].backgroundColor = backgroundColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Excel Skills Assessment'),
        actions: [
          TextButton(onPressed: _resetAssessment, child: const Text('Reset')),
        ],
      ),
      body: Column(
        children: [
          // Top panel with instructions and sample data
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isExpanded ? 300 : 60,
            child: Card(
              margin: const EdgeInsets.all(8),
              elevation: 3,
              child: Column(
                children: [
                  // Header with expand/collapse functionality
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      color: Colors.blue.shade50,
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Task: Recreate the sample Excel report with product names, values, and formulas',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Icon(
                            _isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Expandable content
                  if (_isExpanded)
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Sample data
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Sample Data:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Expanded(child: _buildReferenceTable()),
                                ],
                              ),
                            ),
                          ),

                          // Requirements
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Requirements:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  _buildRequirementItem(
                                    'Product names must match exactly',
                                  ),
                                  _buildRequirementItem(
                                    'Enter quarterly values as shown',
                                  ),
                                  _buildRequirementItem(
                                    'Use SUM() for "Total" column',
                                  ),
                                  _buildRequirementItem(
                                    'Use AVERAGE() for "Average" column',
                                  ),
                                  _buildRequirementItem(
                                    'Include Grand Total row at bottom',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Main Excel workspace
          Expanded(
            child: Card(
              margin: const EdgeInsets.all(8),
              elevation: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: Colors.grey.shade100,
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        const Icon(Icons.edit_document, color: Colors.green),
                        const SizedBox(width: 8),
                        const Text(
                          'Your Excel Worksheet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),

                        ElevatedButton.icon(
                          onPressed: _exportToExcel,
                          icon: const Icon(Icons.download),
                          label: const Text('Download'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!_isAssessmentCompleted)
                          ElevatedButton(
                            onPressed: _evaluateAssessment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text('Submit'),
                          ),
                      ],
                    ),
                  ),

                  // Excel interface or results
                  Expanded(
                    child:
                        _isAssessmentCompleted
                            ? _buildAssessmentResults()
                            : _buildExcelInterface(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
          const SizedBox(width: 4),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildReferenceTable() {
    return DataTable(
      columnSpacing: 12,
      headingRowHeight: 32,
      dataRowHeight: 28,
      headingTextStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12,
        color: Colors.black,
      ),
      dataTextStyle: const TextStyle(fontSize: 12),
      columns: const [
        DataColumn(label: Text('Product')),
        DataColumn(label: Text('Q1')),
        DataColumn(label: Text('Q2')),
        DataColumn(label: Text('Q3')),
        DataColumn(label: Text('Q4')),
      ],
      rows:
          _referenceData.map((data) {
            return DataRow(
              cells: [
                DataCell(Text(data.product)),
                DataCell(Text('\$${data.q1.toStringAsFixed(0)}')),
                DataCell(Text('\$${data.q2.toStringAsFixed(0)}')),
                DataCell(Text('\$${data.q3.toStringAsFixed(0)}')),
                DataCell(Text('\$${data.q4.toStringAsFixed(0)}')),
              ],
            );
          }).toList(),
    );
  }

  Widget _buildExcelInterface() {
    return ListView(
      children: [
        // Enhanced formula bar with formatting options
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: Colors.grey.shade200,
          child: Row(
            children: [
              Text(
                _activeCellReference,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.functions, size: 16),
              const SizedBox(width: 4),
              // Reduced width TextField (now half the original size)
              SizedBox(
                width:
                    MediaQuery.of(context).size.width *
                    0.4, // 40% of screen width
                child: TextField(
                  controller: _formulaController,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(),
                    hintText: 'Enter value or formula',
                  ),
                  onSubmitted: (_) => _updateFormulaBar(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: _updateFormulaBar,
                tooltip: 'Apply formula',
                iconSize: 20,
              ),
              // Display remaining space with some content
              // Formatting toolbar row (unchanged)
              if (_selectedCell != null)
                IconButton(
                  icon: const Icon(Icons.format_bold),
                  tooltip: 'Bold',
                  onPressed: _toggleBoldFormat,
                  iconSize: 20,
                  color: _isCellBold() ? Colors.blue : Colors.black,
                ),

              // Cell merge/split options
              IconButton(
                icon: const Icon(Icons.call_merge),
                tooltip: 'Merge cells',
                onPressed: _showMergeCellDialog,
                iconSize: 20,
              ),
              IconButton(
                icon: const Icon(Icons.call_split),
                tooltip: 'Split cells',
                onPressed: _splitSelectedCell,
                iconSize: 20,
              ),

              // Cell color options
              const Text('Fill: '),
              IconButton(
                icon: const Icon(Icons.format_color_fill, color: Colors.white),
                tooltip: 'White',
                onPressed: () => _applyCellFormat(Colors.white70),
                iconSize: 20,
              ),
              IconButton(
                icon: const Icon(Icons.format_color_fill, color: Colors.orange),
                tooltip: 'Orange',
                onPressed: () => _applyCellFormat(Colors.orange.shade100),
                iconSize: 20,
              ),
              IconButton(
                icon: const Icon(Icons.format_color_fill, color: Colors.green),
                tooltip: 'Green',
                onPressed: () => _applyCellFormat(Colors.green.shade100),
                iconSize: 20,
              ),
              IconButton(
                icon: const Icon(Icons.format_color_fill, color: Colors.blue),
                tooltip: 'Blue',
                onPressed: () => _applyCellFormat(Colors.blue.shade100),
                iconSize: 20,
              ),

              const Spacer(),
              Text('Selected: $_activeCellReference'),
            ],
          ),
        ),

        // Excel grid (unchanged)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildExcelGrid(),
        ),
      ],
    );
  }

  // Method to toggle bold formatting
  void _toggleBoldFormat() {
    if (_selectedCell == null) return;

    final row = _selectedCell!.rowIndex;
    final col = _selectedCell!.columnIndex;

    setState(() {
      _excelData[row][col].isBold = !(_excelData[row][col].isBold ?? false);
    });
  }

  // Method to check if a cell has bold formatting
  bool _isCellBold() {
    if (_selectedCell == null) return false;

    final row = _selectedCell!.rowIndex;
    final col = _selectedCell!.columnIndex;

    return _excelData[row][col].isBold ?? false;
  }

  // Method to show merge cells dialog
  void _showMergeCellDialog() {
    if (_selectedCell == null) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Merge Cells'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Select number of columns to merge:'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {
                        _mergeCells(2);
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.looks_two_outlined, color: Colors.green),
                    ),
                    IconButton(
                      onPressed: () {
                        _mergeCells(3);
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.looks_3_outlined, color: Colors.green),
                    ),

                    IconButton(
                      onPressed: () {
                        _mergeCells(4);
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.looks_4_outlined, color: Colors.green),
                    ),
                    IconButton(
                      onPressed: () {
                        _mergeCells(5);
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.looks_5_outlined, color: Colors.green),
                    ),
                    IconButton(
                      onPressed: () {
                        _mergeCells(6);
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.looks_6_outlined, color: Colors.green),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  // Method to merge cells
  void _mergeCells(int columnCount) {
    if (_selectedCell == null) return;

    final row = _selectedCell!.rowIndex;
    final col = _selectedCell!.columnIndex;

    // Check if we can merge (don't go out of bounds)
    if (col + columnCount > _excelData[row].length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot merge: Not enough columns available'),
        ),
      );
      return;
    }

    setState(() {
      // Store the value from first cell
      final cellValue = _excelData[row][col].value;
      final cellFormula = _excelData[row][col].formula;

      // Set the colSpan on the first cell
      _excelData[row][col].colSpan = columnCount;

      // Clear the content of other cells in the range
      for (int i = 1; i < columnCount; i++) {
        _excelData[row][col + i].value = '';
        _excelData[row][col + i].formula = null;
        _excelData[row][col + i].isMerged = true;
      }

      // Restore the value to the merged cell
      _excelData[row][col].value = cellValue;
      _excelData[row][col].formula = cellFormula;

      // Center text in merged cells by default
      _excelData[row][col].alignment = Alignment.center;
    });
  }

  // Method to split a previously merged cell
  void _splitSelectedCell() {
    if (_selectedCell == null) return;

    final row = _selectedCell!.rowIndex;
    final col = _selectedCell!.columnIndex;

    if (_excelData[row][col].colSpan == null ||
        _excelData[row][col].colSpan! <= 1) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No merged cells to split')));
      return;
    }

    setState(() {
      final columnCount = _excelData[row][col].colSpan!;
      final cellValue = _excelData[row][col].value;

      // Reset the colSpan
      _excelData[row][col].colSpan = null;

      // Keep the value only in the first cell
      _excelData[row][col].value = cellValue;
      _excelData[row][col].alignment = null;

      // Clear the isMerged flag on other cells
      for (int i = 1; i < columnCount; i++) {
        _excelData[row][col + i].isMerged = false;
      }
    });
  }

  // Update the _buildExcelGrid method to handle the new formatting options
  Widget _buildExcelGrid() {
    // Create column headers (A, B, C, etc.)
    List<Widget> columnHeaders = [];
    columnHeaders.add(
      Container(
        width: 40,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          border: Border.all(color: Colors.grey.shade400),
        ),
      ),
    );

    for (int col = 0; col < 7; col++) {
      final colLetter = String.fromCharCode(65 + col); // A, B, C, etc.
      columnHeaders.add(
        Container(
          width: 100,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Text(
            colLetter,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    // Create Excel grid
    List<Widget> rows = [];
    rows.add(Row(children: columnHeaders));

    for (int row = 0; row < _excelData.length; row++) {
      List<Widget> cells = [];

      // Add row number (1, 2, 3, etc.)
      cells.add(
        Container(
          width: 40,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Text(
            '${row + 1}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );

      // Add cells for this row
      for (int col = 0; col < _excelData[row].length; col++) {
        final cell = _excelData[row][col];

        // Skip if this cell is part of a merged range (but not the first cell)
        if (cell.isMerged) {
          continue;
        }

        final isSelected =
            _selectedCell != null &&
            _selectedCell!.rowIndex == row &&
            _selectedCell!.columnIndex == col;

        cells.add(
          GestureDetector(
            onTap: () => _selectCell(row, col),
            onDoubleTap: () {
              _selectCell(row, col);
              _startEditing();
            },
            child: Container(
              width:
                  cell.colSpan != null
                      ? (100 * cell.colSpan!).toDouble()
                      : 100.0,
              height: 24.0,
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? Colors.blue.withOpacity(0.3)
                        : (cell.backgroundColor ?? Colors.white),
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey.shade400,
                  width: isSelected ? 2 : 1,
                ),
              ),
              alignment:
                  cell.alignment ??
                  (cell.isNumeric
                      ? Alignment.centerRight
                      : Alignment.centerLeft),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child:
                  isSelected && _isEditing
                      ? TextField(
                        controller: _cellEditingController,
                        focusNode: _cellFocusNode,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _finishEditing(),
                      )
                      : Text(
                        cell.value,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight:
                              (cell.isHeader || cell.isBold == true)
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
            ),
          ),
        );

        // Skip columns if this is a merged cell
        if (cell.colSpan != null && cell.colSpan! > 1) {
          col += cell.colSpan! - 1;
        }
      }

      rows.add(Row(children: cells));
    }

    return Column(children: rows);
  }

  Widget _buildAssessmentResults() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      _score >= 70
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      '$_score%',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color:
                            _score >= 70
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                      ),
                    ),
                    Text(
                      _score >= 70 ? 'PASSED' : 'FAILED',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:
                            _score >= 70
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Assessment Results',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _score >= 70
                          ? 'Congratulations! You have passed the Excel skills assessment.'
                          : 'You did not pass the Excel skills assessment. Review the feedback and try again.',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Feedback:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _feedbackItems.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.feedback_outlined, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_feedbackItems[index])),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: _resetAssessment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Start Over'),
            ),
          ),
        ],
      ),
    );
  }
}

class TestData {
  final String product;
  final double q1;
  final double q2;
  final double q3;
  final double q4;

  TestData(this.product, this.q1, this.q2, this.q3, this.q4);
}

class TestDataSource extends DataGridSource {
  final List<TestData> data;

  TestDataSource(this.data) {
    _populateRows();
  }

  List<DataGridRow> _dataGridRows = [];

  void _populateRows() {
    _dataGridRows =
        data.map<DataGridRow>((e) {
          return DataGridRow(
            cells: [
              DataGridCell<String>(columnName: 'product', value: e.product),
              DataGridCell<double>(columnName: 'q1', value: e.q1),
              DataGridCell<double>(columnName: 'q2', value: e.q2),
              DataGridCell<double>(columnName: 'q3', value: e.q3),
              DataGridCell<double>(columnName: 'q4', value: e.q4),
            ],
          );
        }).toList();
  }

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells:
          row.getCells().map<Widget>((cell) {
            return Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                cell.value is double
                    ? '\$${cell.value.toStringAsFixed(2)}'
                    : cell.value.toString(),
              ),
            );
          }).toList(),
    );
  }
}

// Update the ExcelCellData class to include additional properties
class ExcelCellData {
  String value;
  String? formula;
  bool isHeader;
  bool isNumeric;
  String? format;
  int? colSpan;
  Alignment? alignment;
  Color? backgroundColor;
  bool? isBold;
  bool isMerged; // Flag to indicate this cell is part of a merged range

  ExcelCellData({
    this.value = '',
    this.formula,
    this.isHeader = false,
    this.isNumeric = false,
    this.format,
    this.colSpan,
    this.alignment,
    this.backgroundColor,
    this.isBold,
    this.isMerged = false,
  });
}
