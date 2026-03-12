import 'package:flutter/material.dart';

// Delete functionality class
class DeletePatientService {
  // Show delete confirmation dialog
  static Future<void> showDeleteConfirmationDialog({
    required BuildContext context,
    required String patientName,
    required Function() onConfirm,
  }) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Patient'),
          content: Text('Are you sure you want to delete $patientName?'),
          actions: [
            TextButton(
              child: const Text(
                'Cancel',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                onConfirm();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Delete button widget
  static Widget buildDeleteButton({
    required BuildContext context,
    required String patientName,
    required Function() onDelete,
  }) {
    return IconButton(
      icon: const Icon(Icons.delete, color: Colors.red),
      onPressed: () {
        showDeleteConfirmationDialog(
          context: context,
          patientName: patientName,
          onConfirm: onDelete,
        );
      },
    );
  }
}
