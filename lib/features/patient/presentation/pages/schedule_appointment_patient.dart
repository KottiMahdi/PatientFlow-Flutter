import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:management_cabinet_medical_mobile/features/patient/domain/entities/patient.dart';
import 'package:management_cabinet_medical_mobile/features/appointment/presentation/providers/appointment_provider.dart';
import 'package:management_cabinet_medical_mobile/features/waiting_room/domain/entities/waiting_room_patient.dart';
import 'package:management_cabinet_medical_mobile/features/waiting_room/presentation/providers/waiting_room_provider.dart';
import 'package:management_cabinet_medical_mobile/features/auth/presentation/providers/auth_provider.dart';

// Function to create a modified version of addAppointment that includes patient data
void schedulePatientAppointment(
    BuildContext context, PatientEntity patientData, VoidCallback fetchData) {
  // Get patient data
  final String patientName = '${patientData.name} ${patientData.prenom}';

  // Controllers for text input fields
  final patientNameController =
      TextEditingController(text: patientName); // Pre-filled with patient name
  final reasonController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // Variables to store selected date and time
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  // Function to show date picker dialog
  void selectDate(BuildContext context, Function setState) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2161),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Time picker function
  void selectTime(BuildContext context, Function setState) async {
    // Show time picker dialog
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime:
          selectedTime ?? TimeOfDay.now(), // Current time or existing selection
    );
    // Update state if valid time selected
    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  // Show the appointment creation dialog
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          "Schedule Appointment for $patientName",
          style: const TextStyle(
              color: Color(0xFF1E3A8A),
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
        // Use StatefulBuilder to manage state within the dialog
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Patient Name Input (read-only since pre-filled)
                    TextFormField(
                      controller: patientNameController,
                      readOnly: true, // Make it read-only
                      decoration: InputDecoration(
                        labelText: 'Patient Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon:
                            const Icon(Icons.person, color: Color(0xFF1E3A8A)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Appointment reason input field
                    TextFormField(
                      controller: reasonController,
                      decoration: InputDecoration(
                        labelText: 'Reason for Appointment',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon:
                            const Icon(Icons.notes, color: Color(0xFF1E3A8A)),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter reason for appointment';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Date selection with validation
                    FormField<DateTime>(
                      validator: (value) {
                        if (selectedDate == null) {
                          return 'Please select a date';
                        }
                        return null;
                      },
                      builder: (FormFieldState<DateTime> state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                selectDate(context, setState);
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                minimumSize: const Size(double.infinity, 48),
                              ),
                              child: Text(selectedDate == null
                                  ? 'Select Date'
                                  : 'Selected Date: ${selectedDate!.toLocal().toString().split(' ')[0]}'),
                            ),
                            if (state.hasError)
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 12, top: 8),
                                child: Text(
                                  state.errorText!,
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Time selection with validation
                    FormField<TimeOfDay>(
                      validator: (value) {
                        if (selectedTime == null) {
                          return 'Please select a time';
                        }
                        return null;
                      },
                      builder: (FormFieldState<TimeOfDay> state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                selectTime(context, setState);
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                minimumSize: const Size(double.infinity, 48),
                              ),
                              child: Text(selectedTime == null
                                  ? 'Select Time'
                                  : 'Selected Time: ${selectedTime!.format(context)}'),
                            ),
                            if (state.hasError)
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 12, top: 8),
                                child: Text(
                                  state.errorText!,
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
        // Dialog action buttons
        actions: [
          // Cancel button
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel"),
          ),
          // Add button
          ElevatedButton(
            onPressed: () async {
              // Validate required fields
              if (formKey.currentState!.validate()) {
                try {
                  final formattedDate =
                      '${selectedDate!.toLocal().day}/${selectedDate!.toLocal().month}/${selectedDate!.toLocal().year}';
                  final formattedTime = selectedTime!.format(context);

                  final authProvider =
                      Provider.of<AuthProviderGlobal>(context, listen: false);
                  final appointmentProvider =
                      Provider.of<AppointmentProviderGlobal>(context,
                          listen: false);
                  final waitingRoomProvider =
                      Provider.of<WaitingRoomProviderGlobal>(context,
                          listen: false);

                  final userId = authProvider.user?.uid;
                  if (userId == null) {
                    throw Exception("User not authenticated");
                  }

                  // Add new appointment using provider
                  final appointmentSuccess =
                      await appointmentProvider.addAppointment(
                    patientName: patientNameController.text,
                    date: formattedDate,
                    time: formattedTime,
                    reason: reasonController.text,
                    userId: userId,
                  );

                  if (!appointmentSuccess) {
                    throw Exception("Failed to add appointment");
                  }

                  // Add to waiting room using provider
                  final waitingRoomSuccess =
                      await waitingRoomProvider.addPatient(
                    userId: userId,
                    name: patientNameController.text.trim(),
                    time: formattedTime,
                    date: formattedDate,
                    status: WaitingRoomStatus.appointments,
                  );

                  if (!waitingRoomSuccess) {
                    throw Exception("Failed to add to waiting room");
                  }

                  if (!context.mounted) {
                    return;
                  }

                  Navigator.of(context).pop(); // Close the dialog
                  fetchData(); // Optional: Refresh data if needed

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Appointment scheduled successfully!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                } catch (e) {
                  // Show error message
                  if (!context.mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error scheduling appointment: $e'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                  debugPrint('Error scheduling appointment: $e');
                }
              }
            },
            child: const Text("Schedule"),
          ),
        ],
      );
    },
  );
}
