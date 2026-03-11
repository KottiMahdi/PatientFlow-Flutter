import 'package:flutter/material.dart';

Widget buildInfoRow(IconData icon, String text, {bool isMultiline = false}) {
  return Row(
    crossAxisAlignment:
    isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
    children: [
      Icon(
        icon,
        color: Colors.blueAccent.shade400,
        size: 20,
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: TextStyle(
            fontSize: isMultiline ? 14 : 15,
            fontWeight: isMultiline ? FontWeight.normal : FontWeight.w500,
          ),
          softWrap: true,
          overflow: TextOverflow.visible,
        ),
      ),
    ],
  );
}