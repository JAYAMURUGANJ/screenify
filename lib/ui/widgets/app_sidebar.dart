import 'package:flutter/material.dart';

class AppSidebar extends StatelessWidget {
  final VoidCallback onEmbedWord;
  final VoidCallback onEmbedExcel;
  final VoidCallback onEmbedPowerPoint;

  const AppSidebar({
    super.key,
    required this.onEmbedWord,
    required this.onEmbedExcel,
    required this.onEmbedPowerPoint,
  });

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
              onPressed: onEmbedWord,
            ),
            const SizedBox(height: 16),
            _buildAppButton(
              title: 'Microsoft Excel',
              subtitle: 'Spreadsheets and data',
              icon: Icons.table_chart,
              color: Colors.green,
              onPressed: onEmbedExcel,
            ),
            const SizedBox(height: 16),
            _buildAppButton(
              title: 'Microsoft PowerPoint',
              subtitle: 'Presentations and slides',
              icon: Icons.slideshow,
              color: Colors.orange,
              onPressed: onEmbedPowerPoint,
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
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
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
                    color: color.withOpacity(0.1),
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
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFFBDC3C7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
