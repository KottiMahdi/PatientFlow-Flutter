import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/appointment/presentation/providers/appointment_provider.dart';

class AppointmentSchedulerPage extends StatefulWidget {
  final VoidCallback onAppointmentAdded;

  const AppointmentSchedulerPage({
    super.key,
    required this.onAppointmentAdded,
  });

  @override
  State<AppointmentSchedulerPage> createState() =>
      _AppointmentSchedulerPageState();
}

class _AppointmentSchedulerPageState extends State<AppointmentSchedulerPage> {
  // Controllers for text input fields
  final _patientNameController = TextEditingController();
  final _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Variables to store selected date and time
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  // Loading state
  bool _isSaving = false;

  // Function to show date picker dialog
  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(), // Prevent past dates
      lastDate:
          DateTime.now().add(const Duration(days: 365)), // One year in future
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Time picker function
  void _selectTime(BuildContext context) async {
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

  // Function to save appointment to Firestore
  Future<void> _saveAppointment() async {
    // Validate required fields
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both date and time'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final provider =
          Provider.of<AppointmentProviderGlobal>(context, listen: false);
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      // Format date string
      String dateString =
          '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';

      // Add appointment using provider
      final success = await provider.addAppointment(
        patientName: _patientNameController.text.trim(),
        date: dateString,
        time: selectedTime!.format(context),
        reason: _reasonController.text.trim(),
        userId: currentUser.uid,
      );

      if (!mounted) {
        return;
      }

      if (success) {
        // Call the callback to refresh appointment list
        widget.onAppointmentAdded();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment scheduled successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back
        Navigator.of(context).pop();
      } else {
        throw Exception('Failed to add appointment');
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      // Show error message if something goes wrong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error scheduling appointment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Schedule New Appointment",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Patient Information",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 16),

              // Patient Name Input
              TextFormField(
                controller: _patientNameController,
                enabled: !_isSaving,
                decoration: InputDecoration(
                  labelText: 'Patient Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon:
                      const Icon(Icons.person, color: Color(0xFF1E3A8A)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter patient name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              const Text(
                "Appointment Details",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 16),

              // Appointment reason input field
              TextFormField(
                maxLines: 3,
                controller: _reasonController,
                enabled: !_isSaving,
                decoration: InputDecoration(
                  labelText: 'Reason for Appointment',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.notes, color: Color(0xFF1E3A8A)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter reason for appointment';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              const Text(
                "Schedule",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 16),

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
                      InkWell(
                        onTap: _isSaving
                            ? null
                            : () {
                                _selectDate(context);
                                state.didChange(selectedDate);
                              },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: state.hasError
                                    ? Colors.red
                                    : Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(12),
                            color: _isSaving ? Colors.grey.shade100 : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: _isSaving
                                    ? Colors.grey
                                    : const Color(0xFF1E3A8A),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                selectedDate == null
                                    ? 'Select Date'
                                    : 'Date: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _isSaving ? Colors.grey : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (state.hasError)
                        Padding(
                          padding: const EdgeInsets.only(left: 12, top: 8),
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
              const SizedBox(height: 16),

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
                      InkWell(
                        onTap: _isSaving
                            ? null
                            : () {
                                _selectTime(context);
                                state.didChange(selectedTime);
                              },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: state.hasError
                                    ? Colors.red
                                    : Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(12),
                            color: _isSaving ? Colors.grey.shade100 : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: _isSaving
                                    ? Colors.grey
                                    : const Color(0xFF1E3A8A),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                selectedTime == null
                                    ? 'Select Time'
                                    : 'Time: ${selectedTime!.format(context)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _isSaving ? Colors.grey : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (state.hasError)
                        Padding(
                          padding: const EdgeInsets.only(left: 12, top: 8),
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
              const SizedBox(height: 40),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving
                          ? null
                          : () {
                              Navigator.of(context).pop();
                            },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF1E3A8A)),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text("Cancel"),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveAppointment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text("Schedule"),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
