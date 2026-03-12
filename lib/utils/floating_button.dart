import 'package:flutter/material.dart';

class FloatingButton extends StatelessWidget {
  /// Callback to be executed when the button is pressed.
  final VoidCallback onPressed;

  /// The text label of the button.
  final String label;

  /// The icon to display on the button.
  final IconData icon;

  /// Optional padding for the button.
  final EdgeInsets padding;

  /// Optional background color for the button.
  final Color backgroundColor;

  /// Optional foreground (text/icon) color for the button.
  final Color foregroundColor;

  const FloatingButton({
    super.key,
    required this.onPressed,
    this.label = '',
    this.icon = Icons.add,
    this.padding = const EdgeInsets.only(left: 31),
    this.backgroundColor = const Color(0xFF448AFF), // BlueAccent.shade400
    this.foregroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton.extended(
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(label),
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
          ),
        ],
      ),
    );
  }
}
