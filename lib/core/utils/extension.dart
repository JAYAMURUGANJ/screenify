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
    case 'edit_document':
      return Icons.edit_document;
    case 'table_chart':
      return Icons.table_chart;
    default:
      return Icons.assessment;
  }
}
