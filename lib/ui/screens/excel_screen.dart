import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;

class ExcelSkillTestScreen extends StatefulWidget {
  const ExcelSkillTestScreen({super.key});

  @override
  State<ExcelSkillTestScreen> createState() => _ExcelSkillTestScreenState();
}

class _ExcelSkillTestScreenState extends State<ExcelSkillTestScreen> {
  late List<TestData> _referenceData;
  late TestDataSource _dataSource;
  bool _isAssessmentCompleted = false;
  int _score = 0;
  final int _maxScore = 100;
  List<String> _feedbackItems = [];

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
    _dataSource = TestDataSource(
      List.generate(5, (index) => TestData('', 0, 0, 0, 0)),
    );
  }

  void _evaluateAssessment() {
    int score = 0;
    List<String> feedback = [];

    // Check product names (20 points)
    int productNameScore = 0;
    for (int i = 0; i < _referenceData.length; i++) {
      if (i < _dataSource.data.length) {
        if (_dataSource.data[i].product.toLowerCase() ==
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
      if (i < _dataSource.data.length) {
        if (_dataSource.data[i].q1 == _referenceData[i].q1)
          quarterlyValueScore += 2;
        if (_dataSource.data[i].q2 == _referenceData[i].q2)
          quarterlyValueScore += 2;
        if (_dataSource.data[i].q3 == _referenceData[i].q3)
          quarterlyValueScore += 2;
        if (_dataSource.data[i].q4 == _referenceData[i].q4)
          quarterlyValueScore += 2;
      }
    }
    score += quarterlyValueScore;
    feedback.add('Quarterly Values: $quarterlyValueScore/40 points');

    // Check data structure (20 points)
    int rowScore = min(
      20,
      (_dataSource.data.length == _referenceData.length)
          ? 20
          : (_dataSource.data.length >= _referenceData.length * 0.8)
          ? 15
          : (_dataSource.data.length >= _referenceData.length * 0.6)
          ? 10
          : 5,
    );
    score += rowScore;
    feedback.add('Data Structure: $rowScore/20 points');

    // Check Excel formulas when exported (20 points)
    // This is calculated in the exportToExcel method and added to the score later

    setState(() {
      _score = score;
      _feedbackItems = feedback;
      _isAssessmentCompleted = true;
    });
  }

  void _exportToExcel() async {
    // Validate and score formulas - will add up to 20 points
    int formulaScore = 0;

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

    for (int i = 0; i < _dataSource.data.length; i++) {
      final row = _dataSource.data[i];
      final excelRow = i + headerRow + 1;

      sheet.getRangeByName('A$excelRow').setText(row.product);
      sheet.getRangeByName('A$excelRow').cellStyle = dataStyle;

      sheet.getRangeByName('B$excelRow').setNumber(row.q1);
      sheet.getRangeByName('C$excelRow').setNumber(row.q2);
      sheet.getRangeByName('D$excelRow').setNumber(row.q3);
      sheet.getRangeByName('E$excelRow').setNumber(row.q4);

      sheet.getRangeByName('B$excelRow:E$excelRow').cellStyle = currencyStyle;

      // Total formula
      sheet.getRangeByName('F$excelRow').formula =
          '=SUM(B$excelRow:E$excelRow)';

      // Average formula
      sheet.getRangeByName('G$excelRow').formula =
          '=AVERAGE(B$excelRow:E$excelRow)';
    }

    // Add Total row
    final totalRow = _dataSource.data.length + headerRow + 1;
    sheet.getRangeByName('A$totalRow').setText('Grand Total');
    sheet.getRangeByName('A$totalRow').cellStyle = headerStyle;

    // Add summary formulas
    for (int i = 1; i <= 4; i++) {
      final column = String.fromCharCode(65 + i); // B, C, D, E
      final startRow = headerRow + 1;
      final endRow = _dataSource.data.length + headerRow;

      sheet.getRangeByName('$column$totalRow').formula =
          '=SUM($column$startRow:$column$endRow)';
    }

    // Total of totals
    sheet.getRangeByName('F$totalRow').formula =
        '=SUM(F${headerRow + 1}:F${_dataSource.data.length + headerRow})';

    // Average of averages
    sheet.getRangeByName('G$totalRow').formula =
        '=AVERAGE(G${headerRow + 1}:G${_dataSource.data.length + headerRow})';

    // Check for formulas and update score
    if (_isAssessmentCompleted) {
      // 10 points for having SUM formulas
      if (sheet.getRangeByName('F4').formula!.contains('SUM')) {
        formulaScore += 10;
        _feedbackItems.add('SUM Formulas: 10/10 points');
      } else {
        _feedbackItems.add('SUM Formulas: 0/10 points');
      }

      // 10 points for having AVERAGE formulas
      if (sheet.getRangeByName('G4').formula!.contains('AVERAGE')) {
        formulaScore += 10;
        _feedbackItems.add('AVERAGE Formulas: 10/10 points');
      } else {
        _feedbackItems.add('AVERAGE Formulas: 0/10 points');
      }

      setState(() {
        _score += formulaScore;
        _feedbackItems = List.from(_feedbackItems);
      });
    }

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
      _dataSource = TestDataSource(
        List.generate(5, (index) => TestData('', 0, 0, 0, 0)),
      );
      _isAssessmentCompleted = false;
      _score = 0;
      _feedbackItems.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Excel Skills Assessment'),
        actions: [
          TextButton(
            onPressed: _resetAssessment,
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Instructions
          Container(
            color: Colors.blue.shade50,
            padding: const EdgeInsets.all(12),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Task: Recreate the sample Excel report on the right side, including product names, values, and proper formulas for totals and averages.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: Row(
              children: [
                // Left panel: Reference Excel
                Expanded(
                  flex: 1,
                  child: Card(
                    margin: const EdgeInsets.all(8),
                    elevation: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          color: Colors.grey.shade100,
                          padding: const EdgeInsets.all(8),
                          child: const Row(
                            children: [
                              Icon(Icons.table_chart, color: Colors.blue),
                              SizedBox(width: 8),
                              Text(
                                'Sample Excel Report',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(child: _buildReferenceTable()),
                        Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.grey.shade100,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Requirements:',
                                style: TextStyle(fontWeight: FontWeight.bold),
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
                      ],
                    ),
                  ),
                ),

                // Right panel: Candidate workspace
                Expanded(
                  flex: 1,
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
                              const Icon(
                                Icons.edit_document,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Your Excel Worksheet',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              if (!_isAssessmentCompleted)
                                ElevatedButton(
                                  onPressed: _evaluateAssessment,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  child: const Text('Submit Work'),
                                ),
                            ],
                          ),
                        ),
                        // Excel-like interface
                        Expanded(
                          child:
                              _isAssessmentCompleted
                                  ? _buildAssessmentResults()
                                  : _buildExcelInterface(),
                        ),
                        // Buttons at the bottom
                        Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.grey.shade100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    final newData = _dataSource.data.toList();
                                    newData.add(TestData('', 0, 0, 0, 0));
                                    _dataSource = TestDataSource(newData);
                                  });
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add Row'),
                              ),
                              ElevatedButton.icon(
                                onPressed: _exportToExcel,
                                icon: const Icon(Icons.file_download),
                                label: const Text('Export to Excel'),
                              ),
                            ],
                          ),
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
    );
  }

  Widget _buildExcelInterface() {
    return Column(
      children: [
        // Excel header row (column labels)
        Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              _buildExcelHeaderCell(''), // Empty corner cell
              _buildExcelHeaderCell('A'),
              _buildExcelHeaderCell('B'),
              _buildExcelHeaderCell('C'),
              _buildExcelHeaderCell('D'),
              _buildExcelHeaderCell('E'),
              _buildExcelHeaderCell('F'),
              _buildExcelHeaderCell('G'),
            ],
          ),
        ),

        // Excel body with row numbers and cells
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Title row (A1:G1)
                _buildExcelRow(1, [
                  _buildExcelCell(
                    'Quarterly Sales Report',
                    isSelected: false,
                    colSpan: 7,
                  ),
                  _buildExcelCell('', isVisible: false),
                  _buildExcelCell('', isVisible: false),
                  _buildExcelCell('', isVisible: false),
                  _buildExcelCell('', isVisible: false),
                  _buildExcelCell('', isVisible: false),
                  _buildExcelCell('', isVisible: false),
                ]),

                // Empty row (A2:G2)
                _buildExcelRow(
                  2,
                  List.generate(7, (index) => _buildExcelCell('')),
                ),

                // Header row (A3:G3)
                _buildExcelRow(3, [
                  _buildExcelCell('Product', isHeader: true),
                  _buildExcelCell('Q1', isHeader: true),
                  _buildExcelCell('Q2', isHeader: true),
                  _buildExcelCell('Q3', isHeader: true),
                  _buildExcelCell('Q4', isHeader: true),
                  _buildExcelCell('Total', isHeader: true),
                  _buildExcelCell('Average', isHeader: true),
                ]),

                // Data rows
                for (int i = 0; i < _dataSource.data.length; i++)
                  _buildExcelDataRow(i + 4, _dataSource.data[i]),

                // Empty rows for additional data
                for (
                  int i = _dataSource.data.length + 4;
                  i < _dataSource.data.length + 8;
                  i++
                )
                  _buildExcelRow(
                    i,
                    List.generate(7, (index) => _buildExcelCell('')),
                  ),

                // Total row
                _buildExcelRow(_dataSource.data.length + 9, [
                  _buildExcelCell('Grand Total', isHeader: true),
                  _buildExcelCell('', isFormula: true),
                  _buildExcelCell('', isFormula: true),
                  _buildExcelCell('', isFormula: true),
                  _buildExcelCell('', isFormula: true),
                  _buildExcelCell('', isFormula: true),
                  _buildExcelCell('', isFormula: true),
                ]),
              ],
            ),
          ),
        ),

        // Formula bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
            color: Colors.grey.shade50,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: const Text('A1', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: const Text('fx', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExcelHeaderCell(String text) {
    return Container(
      width: text.isEmpty ? 40 : 80,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  // Helper method to build Excel rows with row number
  Widget _buildExcelRow(int rowNum, List<Widget> cells) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row number
        Container(
          width: 40,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            '$rowNum',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        ...cells,
      ],
    );
  }

  // Helper method to build Excel data rows
  Widget _buildExcelDataRow(int rowNum, TestData data) {
    return _buildExcelRow(rowNum, [
      _buildExcelCell(data.product),
      _buildExcelCell('\$${data.q1 == 0 ? '' : data.q1.toStringAsFixed(2)}'),
      _buildExcelCell('\$${data.q2 == 0 ? '' : data.q2.toStringAsFixed(2)}'),
      _buildExcelCell('\$${data.q3 == 0 ? '' : data.q3.toStringAsFixed(2)}'),
      _buildExcelCell('\$${data.q4 == 0 ? '' : data.q4.toStringAsFixed(2)}'),
      _buildExcelCell('', isFormula: true),
      _buildExcelCell('', isFormula: true),
    ]);
  }

  // Helper method to build Excel cells
  Widget _buildExcelCell(
    String text, {
    bool isSelected = false,
    bool isHeader = false,
    bool isFormula = false,
    bool isVisible = true,
    int colSpan = 1,
  }) {
    if (!isVisible) return const SizedBox.shrink();

    return Container(
      width: (80 * colSpan).toDouble(),
      height: 24,
      alignment:
          text.startsWith('\$') ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color:
            isSelected
                ? Colors.blue.shade100
                : isHeader
                ? const Color(0xFFD8E4BC)
                : isFormula
                ? const Color(0xFFC6EFCE)
                : Colors.white,
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isFormula ? Colors.green.shade800 : null,
          fontStyle: isFormula ? FontStyle.italic : FontStyle.normal,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // You'll also need to modify the _exportToExcel method to use the data from your Excel-like interface

  // Add this method to handle cell editing - you'll need to implement this to capture user input
  void _handleCellEdit(int row, int col, String value) {
    // Map the cell coordinates to your data model
    if (row >= 4 && row < 4 + _dataSource.data.length) {
      final dataIndex = row - 4;
      switch (col) {
        case 0: // Product (A column)
          setState(() {
            _dataSource.data[dataIndex].product = value;
          });
          break;
        case 1: // Q1 (B column)
          setState(() {
            _dataSource.data[dataIndex].q1 =
                double.tryParse(value.replaceAll('\$', '')) ?? 0;
          });
          break;
        case 2: // Q2 (C column)
          setState(() {
            _dataSource.data[dataIndex].q2 =
                double.tryParse(value.replaceAll('\$', '')) ?? 0;
          });
          break;
        case 3: // Q3 (D column)
          setState(() {
            _dataSource.data[dataIndex].q3 =
                double.tryParse(value.replaceAll('\$', '')) ?? 0;
          });
          break;
        case 4: // Q4 (E column)
          setState(() {
            _dataSource.data[dataIndex].q4 =
                double.tryParse(value.replaceAll('\$', '')) ?? 0;
          });
          break;
        // Handle formula cells if needed
      }
    }
  }

  Widget _buildReferenceTable() {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header for the reference table
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.blue.shade50,
              child: const Center(
                child: Text(
                  'Quarterly Sales Report',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Column headers
            Container(
              color: const Color(0xFFD8E4BC),
              child: Row(
                children: [
                  _tableCell('Product', isHeader: true, flex: 2),
                  _tableCell('Q1', isHeader: true),
                  _tableCell('Q2', isHeader: true),
                  _tableCell('Q3', isHeader: true),
                  _tableCell('Q4', isHeader: true),
                  _tableCell('Total', isHeader: true),
                  _tableCell('Average', isHeader: true),
                ],
              ),
            ),

            // Data rows
            ..._referenceData.map((data) {
              final total = data.q1 + data.q2 + data.q3 + data.q4;
              final average = total / 4;

              return Row(
                children: [
                  _tableCell(data.product, flex: 2),
                  _tableCell('\$${data.q1.toStringAsFixed(2)}'),
                  _tableCell('\$${data.q2.toStringAsFixed(2)}'),
                  _tableCell('\$${data.q3.toStringAsFixed(2)}'),
                  _tableCell('\$${data.q4.toStringAsFixed(2)}'),
                  _tableCell('\$${total.toStringAsFixed(2)}', highlight: true),
                  _tableCell(
                    '\$${average.toStringAsFixed(2)}',
                    highlight: true,
                  ),
                ],
              );
            }),

            // Total row
            Row(
              children: [
                _tableCell('Grand Total', isHeader: true, flex: 2),
                _tableCell(
                  '\$${_referenceData.fold(0.0, (sum, item) => sum + item.q1).toStringAsFixed(2)}',
                  isHeader: true,
                ),
                _tableCell(
                  '\$${_referenceData.fold(0.0, (sum, item) => sum + item.q2).toStringAsFixed(2)}',
                  isHeader: true,
                ),
                _tableCell(
                  '\$${_referenceData.fold(0.0, (sum, item) => sum + item.q3).toStringAsFixed(2)}',
                  isHeader: true,
                ),
                _tableCell(
                  '\$${_referenceData.fold(0.0, (sum, item) => sum + item.q4).toStringAsFixed(2)}',
                  isHeader: true,
                ),
                _tableCell(
                  '\$${_referenceData.fold(0.0, (sum, item) => sum + item.q1 + item.q2 + item.q3 + item.q4).toStringAsFixed(2)}',
                  isHeader: true,
                  highlight: true,
                ),
                _tableCell(
                  '\$${(_referenceData.fold(0.0, (sum, item) => sum + ((item.q1 + item.q2 + item.q3 + item.q4) / 4)) / _referenceData.length).toStringAsFixed(2)}',
                  isHeader: true,
                  highlight: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentResults() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Score display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  _score >= 80
                      ? Colors.green.shade50
                      : _score >= 60
                      ? Colors.yellow.shade50
                      : Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    _score >= 80
                        ? Colors.green
                        : _score >= 60
                        ? Colors.yellow.shade700
                        : Colors.red,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Assessment Score: $_score%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color:
                        _score >= 80
                            ? Colors.green.shade700
                            : _score >= 60
                            ? Colors.yellow.shade700
                            : Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _score >= 80
                      ? 'Excellent work!'
                      : _score >= 60
                      ? 'Good attempt, but room for improvement.'
                      : 'Needs significant improvement.',
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        _score >= 80
                            ? Colors.green.shade700
                            : _score >= 60
                            ? Colors.yellow.shade700
                            : Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Detailed feedback
          Expanded(
            child: Card(
              elevation: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    color: Colors.grey.shade100,
                    child: const Text(
                      'Detailed Feedback',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Expanded(
                    child: ListView.builder(
                      itemCount: _feedbackItems.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Icon(
                            _feedbackItems[index].contains('0/')
                                ? Icons.close
                                : Icons.check,
                            color:
                                _feedbackItems[index].contains('0/')
                                    ? Colors.red
                                    : Colors.green,
                          ),
                          title: Text(_feedbackItems[index]),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _exportToExcel,
                icon: const Icon(Icons.file_download),
                label: const Text('Export Your Work'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
              ElevatedButton.icon(
                onPressed: _resetAssessment,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tableCell(
    String text, {
    bool isHeader = false,
    int flex = 1,
    bool highlight = false,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              isHeader
                  ? const Color(0xFFD8E4BC)
                  : highlight
                  ? const Color(0xFFC6EFCE)
                  : Colors.white,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: isHeader ? TextAlign.center : TextAlign.right,
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 14, color: Colors.green),
          const SizedBox(width: 4),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}

/// Data model
class TestData {
  TestData(this.product, this.q1, this.q2, this.q3, this.q4);

  String product;
  double q1, q2, q3, q4;
}

/// Data source for DataGrid
class TestDataSource extends DataGridSource {
  TestDataSource(this.data);

  List<TestData> data;

  @override
  List<DataGridRow> get rows =>
      data
          .map(
            (e) => DataGridRow(
              cells: [
                DataGridCell<String>(columnName: 'product', value: e.product),
                DataGridCell<double>(columnName: 'q1', value: e.q1),
                DataGridCell<double>(columnName: 'q2', value: e.q2),
                DataGridCell<double>(columnName: 'q3', value: e.q3),
                DataGridCell<double>(columnName: 'q4', value: e.q4),
              ],
            ),
          )
          .toList();

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells:
          row.getCells().map<Widget>((cell) {
            final bool isNumeric = cell.value is double;
            return Container(
              alignment:
                  isNumeric ? Alignment.centerRight : Alignment.centerLeft,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                isNumeric
                    ? (cell.value == 0
                        ? ''
                        : '\$${cell.value.toStringAsFixed(2)}')
                    : cell.value.toString(),
              ),
            );
          }).toList(),
    );
  }

  @override
  void handleSaveCell(
    DataGridRow dataGridRow,
    RowColumnIndex rowColumnIndex,
    GridColumn column,
    dynamic newValue,
  ) {
    final index = rows.indexOf(dataGridRow);
    final item = data[index];

    if (column.columnName == 'product') {
      item.product = newValue.toString();
    } else {
      final doubleValue =
          double.tryParse(newValue.toString().replaceAll('\$', '')) ?? 0;

      switch (column.columnName) {
        case 'q1':
          item.q1 = doubleValue;
          break;
        case 'q2':
          item.q2 = doubleValue;
          break;
        case 'q3':
          item.q3 = doubleValue;
          break;
        case 'q4':
          item.q4 = doubleValue;
          break;
      }
    }
    notifyListeners();
  }
}
