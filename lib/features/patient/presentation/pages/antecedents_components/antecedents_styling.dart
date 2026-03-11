import 'package:flutter/material.dart';

// Get category icon based on category name
IconData getCategoryIcon(String category) {
  switch (category) {
    case 'Antécédents obstétricaux':
      return Icons.pregnant_woman;
    case 'Antécédents gynécologiques':
      return Icons.female;
    case 'Antécédents menstruels':
      return Icons.calendar_month;
    case 'Antécédents familiaux':
      return Icons.family_restroom;
    case 'Antécédents médicaux':
      return Icons.medical_services;
    case 'Antécédents chirurgicaux':
      return Icons.healing;
    case 'Facteurs de risque':
      return Icons.warning_amber;
    case 'Allergique':
      return Icons.health_and_safety;
    default:
      return Icons.folder;
  }
}

// Get category color based on category name
Color getCategoryColor(String category) {
  switch (category) {
    case 'Antécédents obstétricaux':
      return Colors.pink.shade300;
    case 'Antécédents gynécologiques':
      return Colors.purple.shade300;
    case 'Antécédents menstruels':
      return Colors.indigo.shade300;
    case 'Antécédents familiaux':
      return Colors.blue.shade300;
    case 'Antécédents médicaux':
      return Colors.cyan.shade300;
    case 'Antécédents chirurgicaux':
      return Colors.teal.shade300;
    case 'Facteurs de risque':
      return Colors.orange.shade300;
    case 'Allergique':
      return Colors.red.shade300;
    default:
      return Colors.grey.shade300;
  }
}

// Get darker category color for buttons
Color getCategoryDarkColor(String category) {
  switch (category) {
    case 'Antécédents obstétricaux':
      return Colors.pink.shade700;
    case 'Antécédents gynécologiques':
      return Colors.purple.shade700;
    case 'Antécédents menstruels':
      return Colors.indigo.shade700;
    case 'Antécédents familiaux':
      return Colors.blue.shade700;
    case 'Antécédents médicaux':
      return Colors.cyan.shade700;
    case 'Antécédents chirurgicaux':
      return Colors.teal.shade700;
    case 'Facteurs de risque':
      return Colors.orange.shade700;
    case 'Allergique':
      return Colors.red.shade700;
    default:
      return Colors.grey.shade700;
  }
}

// Get lighter category color for backgrounds
Color getCategoryLightColor(String category) {
  switch (category) {
    case 'Antécédents obstétricaux':
      return Colors.pink.shade50;
    case 'Antécédents gynécologiques':
      return Colors.purple.shade50;
    case 'Antécédents menstruels':
      return Colors.indigo.shade50;
    case 'Antécédents familiaux':
      return Colors.blue.shade50;
    case 'Antécédents médicaux':
      return Colors.cyan.shade50;
    case 'Antécédents chirurgicaux':
      return Colors.teal.shade50;
    case 'Facteurs de risque':
      return Colors.orange.shade50;
    case 'Allergique':
      return Colors.red.shade50;
    default:
      return Colors.grey.shade50;
  }
}

