import 'package:flutter/material.dart';

import '../../utils/enum_helper.dart';

class AppSidebar extends StatefulWidget {
  final VoidCallback onEmbedWord;
  final VoidCallback onEmbedExcel;
  final VoidCallback onEmbedPowerPoint;
  final SelectedApp initialSelection;
  final Function(SelectedApp) onSelectionChanged;

  const AppSidebar({
    super.key,
    required this.onEmbedWord,
    required this.onEmbedExcel,
    required this.onEmbedPowerPoint,
    this.initialSelection = SelectedApp.none,
    required this.onSelectionChanged,
  });

  @override
  AppSidebarState createState() => AppSidebarState();
}

// Make the state class public (not private with _)
class AppSidebarState extends State<AppSidebar> {
  late SelectedApp _selectedApp;

  @override
  void initState() {
    super.initState();
    _selectedApp = widget.initialSelection;
  }

  void _selectApp(SelectedApp app, VoidCallback onEmbed) {
    setState(() {
      _selectedApp = app;
    });
    widget.onSelectionChanged(app);
    onEmbed();
  }

  // Public method to clear selection (called when app is closed)
  void clearSelection() {
    setState(() {
      _selectedApp = SelectedApp.none;
    });
    widget.onSelectionChanged(SelectedApp.none);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 8.0, bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Office Applications',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Select an application to Work',
                    style: TextStyle(fontSize: 14, color: Color(0xFF7F8C8D)),
                  ),
                ],
              ),
            ),
            const Divider(),
            const SizedBox(height: 16),
            _buildAppButton(
              title: 'Microsoft Word',
              subtitle: 'Document editing',
              icon: Icons.description,
              color: Colors.blue,
              onPressed: () => _selectApp(SelectedApp.word, widget.onEmbedWord),
              isSelected: _selectedApp == SelectedApp.word,
            ),
            const SizedBox(height: 16),
            _buildAppButton(
              title: 'Microsoft Excel',
              subtitle: 'Spreadsheets and data',
              icon: Icons.table_chart,
              color: Colors.green,
              onPressed:
                  () => _selectApp(SelectedApp.excel, widget.onEmbedExcel),
              isSelected: _selectedApp == SelectedApp.excel,
            ),
            const SizedBox(height: 16),
            _buildAppButton(
              title: 'Microsoft PowerPoint',
              subtitle: 'Presentations and slides',
              icon: Icons.slideshow,
              color: Colors.orange,
              onPressed:
                  () => _selectApp(
                    SelectedApp.powerPoint,
                    widget.onEmbedPowerPoint,
                  ),
              isSelected: _selectedApp == SelectedApp.powerPoint,
            ),
            const Spacer(),
            const Divider(),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: Colors.grey[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Applications will be embedded in the right panel when selected',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required bool isSelected,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: isSelected ? Border.all(color: color, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color:
                isSelected
                    ? color.withOpacity(0.3)
                    : Colors.black.withOpacity(0.05),
            blurRadius: isSelected ? 8 : 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(isSelected ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color:
                              isSelected
                                  ? color.darken(0.2)
                                  : const Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              isSelected
                                  ? color.withOpacity(0.8)
                                  : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSelected ? Icons.check_circle : Icons.arrow_forward_ios,
                  size: isSelected ? 20 : 16,
                  color: isSelected ? color : const Color(0xFFBDC3C7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Extension to darken colors
extension ColorExtension on Color {
  Color darken(double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
