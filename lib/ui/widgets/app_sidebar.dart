import 'package:flutter/material.dart';

import '../../utils/enum_helper.dart';

class AppSidebar extends StatefulWidget {
  final VoidCallback onEmbedWord;
  final VoidCallback onEmbedExcel;
  final VoidCallback onEmbedPowerPoint;
  final SelectedApp initialSelection;
  final Function(SelectedApp) onSelectionChanged;
  final bool isLoading;

  const AppSidebar({
    super.key,
    required this.onEmbedWord,
    required this.onEmbedExcel,
    required this.onEmbedPowerPoint,
    this.initialSelection = SelectedApp.none,
    required this.onSelectionChanged,
    this.isLoading = false,
  });

  @override
  AppSidebarState createState() => AppSidebarState();
}

class AppSidebarState extends State<AppSidebar> {
  late SelectedApp _selectedApp;

  @override
  void initState() {
    super.initState();
    _selectedApp = widget.initialSelection;
  }

  void _selectApp(SelectedApp app, VoidCallback onEmbed) {
    if (_selectedApp == SelectedApp.none && !widget.isLoading) {
      setState(() => _selectedApp = app);
      widget.onSelectionChanged(app);
      onEmbed();
    }
  }

  void clearSelection() {
    setState(() => _selectedApp = SelectedApp.none);
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
            _buildHeaderText(),
            const Divider(),
            const SizedBox(height: 16),
            _buildAppButton(
              title: 'Word',
              subtitle: 'For Mailing and Document editing',
              icon: Icons.description,
              color: Colors.blue,
              onPressed: () => _selectApp(SelectedApp.word, widget.onEmbedWord),
              isSelected: _selectedApp == SelectedApp.word,
              isDisabled: _isDisabled(SelectedApp.word),
            ),
            const SizedBox(height: 16),
            _buildAppButton(
              title: 'Excel',
              subtitle: 'For Spreadsheets and data',
              icon: Icons.table_chart,
              color: Colors.green,
              onPressed:
                  () => _selectApp(SelectedApp.excel, widget.onEmbedExcel),
              isSelected: _selectedApp == SelectedApp.excel,
              isDisabled: _isDisabled(SelectedApp.excel),
            ),
            const SizedBox(height: 16),
            _buildAppButton(
              title: 'PowerPoint',
              subtitle: 'For Presentations and slides',
              icon: Icons.slideshow,
              color: Colors.orange,
              onPressed:
                  () => _selectApp(
                    SelectedApp.powerPoint,
                    widget.onEmbedPowerPoint,
                  ),
              isSelected: _selectedApp == SelectedApp.powerPoint,
              isDisabled: _isDisabled(SelectedApp.powerPoint),
            ),
            const Spacer(),
            const Divider(),
            const SizedBox(height: 16),
            _buildInfoRow(),
          ],
        ),
      ),
    );
  }

  bool _isDisabled(SelectedApp app) {
    return (_selectedApp != SelectedApp.none && _selectedApp != app) ||
        widget.isLoading;
  }

  Widget _buildHeaderText() {
    return const Padding(
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
    );
  }

  Widget _buildInfoRow() {
    final isSelected = _selectedApp != SelectedApp.none;
    final infoColor = isSelected ? Colors.amber[700] : Colors.grey[700];
    final icon = isSelected ? Icons.warning_amber_rounded : Icons.info_outline;
    final message =
        isSelected
            ? 'Only one application can be opened at a time. Close current app to open another.'
            : 'Applications will be embedded in the right panel when selected';

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: infoColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: infoColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
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
    required bool isDisabled,
  }) {
    return Opacity(
      opacity: isDisabled && !isSelected ? 0.6 : 1.0,
      child: Container(
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
            onTap: isDisabled && !isSelected ? null : onPressed,
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
                    isDisabled && !isSelected
                        ? Icons.lock
                        : isSelected
                        ? Icons.check_circle
                        : Icons.arrow_forward_ios,
                    size: isSelected ? 20 : 16,
                    color: isSelected ? color : const Color(0xFFBDC3C7),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension ColorExtension on Color {
  Color darken(double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
