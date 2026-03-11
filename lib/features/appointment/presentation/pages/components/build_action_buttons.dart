import 'package:flutter/material.dart';
import 'package:management_cabinet_medical_mobile/features/appointment/domain/entities/appointment.dart';
import 'package:management_cabinet_medical_mobile/core/utils/button_style.dart';
import '../delete_appointment.dart';
import '../edit_appointment_page.dart';

class AppointmentActionButtons extends StatelessWidget {
  final BuildContext context;
  final int index;
  final AppointmentEntity appointment;
  final Function fetchData;

  const AppointmentActionButtons({
    super.key,
    required this.context,
    required this.index,
    required this.appointment,
    required this.fetchData,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Edit button
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditAppointmentPage(
                  documentId: appointment.documentId,
                  appointmentEntity: appointment,
                  onAppointmentUpdated: () => fetchData(),
                ),
              ),
            );
          },
          style: ButtonStyles.elevatedButtonStyle(Colors.green),
          child: const Text("Edit", style: ButtonStyles.buttonTextStyle),
        ),
        const SizedBox(width: 20),
        // Delete button
        ElevatedButton(
          onPressed: () {
            debugPrint(
                "Deleting appointment with documentId: ${appointment.documentId}");
            AppointmentDeleteHandler.showDeleteConfirmation(
              context: context,
              appointmentId: appointment.documentId,
            );
          },
          style: ButtonStyles.elevatedButtonStyle(Colors.red),
          child: const Text("Delete", style: ButtonStyles.buttonTextStyle),
        ),
      ],
    );
  }
}
