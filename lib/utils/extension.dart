// Function to map icon string from JSON to IconData
import 'package:flutter/material.dart';

IconData getIconFromString(String iconName) {
  switch (iconName) {
    case 'quiz':
      return Icons.quiz;
    case 'email':
      return Icons.email;
    case 'keyboard':
      return Icons.keyboard;
    case 'assignment':
      return Icons.assignment;
    case 'table_chart':
      return Icons.table_chart;
    default:
      return Icons.assessment;
  }
}

// Function to map color string from JSON to Color
Color getColorFromString(String colorName) {
  switch (colorName) {
    case 'purple':
      return Colors.purple;
    case 'orange':
      return Colors.orange;
    case 'green':
      return Colors.green;
    case 'blue':
      return Colors.blue;
    case 'teal':
      return Colors.teal;
    default:
      return Colors.indigo;
  }
}
