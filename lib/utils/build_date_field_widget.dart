import 'package:flutter/material.dart';
import 'build_text_field.dart';

Widget buildDateField(
    BuildContext context,
    String label,
    TextEditingController controller,
    void Function(void Function()) setStateFunction,
    ) {
  return GestureDetector(
    onTap: () async {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2030),
      );
      if (pickedDate != null) {
        // Set the selected date in the controller or state
        setStateFunction(() {
          controller.text =
          "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
        });
      }
    },
    child: AbsorbPointer(
      child: buildTextField(
          context, label, controller, Icons.calendar_today, TextInputType.datetime),
    ),
  );
}