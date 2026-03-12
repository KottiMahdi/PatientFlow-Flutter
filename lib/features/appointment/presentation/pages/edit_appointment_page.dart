import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:management_cabinet_medical_mobile/features/appointment/domain/entities/appointment.dart';
import 'package:management_cabinet_medical_mobile/features/appointment/presentation/providers/appointment_provider.dart';

class EditAppointmentPage extends StatefulWidget {
  final String documentId;
  final AppointmentEntity appointmentEntity;
  final VoidCallback onAppointmentUpdated;

  const EditAppointmentPage({
    super.key,
    required this.documentId,
    required this.appointmentEntity,
    required this.onAppointmentUpdated,
  });

  @override
  State<EditAppointmentPage> createState() => _EditAppointmentPageState();
}

class _EditAppointmentPageState extends State<EditAppointmentPage> {
  // Controllers for text input fields
  late final TextEditingController _patientNameController;
  late final TextEditingController _reasonController;
  final _formKey = GlobalKey<FormState>();

  // Variables to store selected date and time
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  // Loading state
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing appointment data
    _patientNameController =
        TextEditingController(text: widget.appointmentEntity.patientName);
    _reasonController =
        TextEditingController(text: widget.appointmentEntity.reason);

    // Parse existing date from appointment data (DD/MM/YYYY format)
    _parseExistingDate();

    // Parse existing time from appointment data
    _parseExistingTime();
  }

  void _parseExistingDate() {
    try {
      String dateStr = widget.appointmentEntity.date;
      if (dateStr.isNotEmpty) {
        List<String> dateParts = dateStr.split('/');
        if (dateParts.length == 3) {
          int day = int.parse(dateParts[0]);
          int month = int.parse(dateParts[1]);
          int year = int.parse(dateParts[2]);

          // Validate date components
          if (day >= 1 &&
              day <= 31 &&
              month >= 1 &&
              month <= 12 &&
              year >= 1900) {
            selectedDate = DateTime(year, month, day);
          } else {
            debugPrint('Invalid date components: $day/$month/$year');
            selectedDate = DateTime.now();
          }
        } else {
          debugPrint('Invalid date format: $dateStr');
          selectedDate = DateTime.now();
        }
      } else {
        selectedDate = DateTime.now();
      }
    } catch (e) {
      debugPrint('Error parsing date: $e');
      selectedDate = DateTime.now();
    }
  }

  void _parseExistingTime() {
    try {
      String timeStr = widget.appointmentEntity.time;
      if (timeStr.isNotEmpty) {
        // Handle both 24-hour and 12-hour formats
        TimeOfDay? parsedTime = _parseTimeString(timeStr);
        if (parsedTime != null) {
          selectedTime = parsedTime;
        } else {
          selectedTime = TimeOfDay.now();
        }
      } else {
        selectedTime = TimeOfDay.now();
      }
    } catch (e) {
      debugPrint('Error parsing time: $e');
      selectedTime = TimeOfDay.now();
    }
  }

  TimeOfDay? _parseTimeString(String timeStr) {
    try {
      // Remove any extra spaces
      timeStr = timeStr.trim();

      // Try parsing as 24-hour format first (HH:mm)
      if (RegExp(r'^\d{1,2}:\d{2}$').hasMatch(timeStr)) {
        List<String> parts = timeStr.split(':');
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);

        if (hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59) {
          return TimeOfDay(hour: hour, minute: minute);
        }
      }

      // Try parsing as 12-hour format (HH:mm AM/PM)
      final format12Hour = DateFormat.jm(); // 12-hour format with AM/PM
      try {
        DateTime dateTime = format12Hour.parse(timeStr);
        return TimeOfDay.fromDateTime(dateTime);
      } catch (e) {
        debugPrint('Failed to parse 12-hour format: $e');
      }

      // Try other common formats
      final formatHm = DateFormat.Hm(); // 24-hour format HH:mm
      try {
        DateTime dateTime = formatHm.parse(timeStr);
        return TimeOfDay.fromDateTime(dateTime);
      } catch (e) {
        debugPrint('Failed to parse Hm format: $e');
      }

      return null;
    } catch (e) {
      debugPrint('Error in _parseTimeString: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  // Function to show date picker dialog
  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(), // Prevent selecting past dates
      lastDate:
          DateTime.now().add(const Duration(days: 365)), // One year from now
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Time picker function
  void _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime) {
      setState(() => selectedTime = picked);
    }
  }

  // Function to update appointment in Firestore
  Future<void> _updateAppointment() async {
    // Validate required fields
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Prevent multiple simultaneous updates
    if (_isUpdating) {
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      // Validate that date and time are selected
      if (selectedDate == null || selectedTime == null) {
        throw Exception('Please select both date and time');
      }

      // Format date and time strings consistently
      String dateString =
          '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';
      String timeString = selectedTime!.format(context);

      // Get provider reference
      final appointmentProvider =
          Provider.of<AppointmentProviderGlobal>(context, listen: false);

      // Use provider to update appointment
      await appointmentProvider.updateAppointment(
        documentId: widget.documentId,
        patientName: _patientNameController.text.trim(),
        date: dateString,
        time: timeString,
        reason: _reasonController.text.trim(),
        oldPatientName: widget.appointmentEntity.patientName,
        oldDate: widget.appointmentEntity.date,
        userId: widget.appointmentEntity.userId,
      );

      // Call the callback to refresh appointment list
      widget.onAppointmentUpdated();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment updated successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate back
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Error updating appointment: $e');

      // Show error message if something goes wrong
      if (mounted) {
        String errorMessage = 'Error updating appointment';
        if (e.toString().contains('permission')) {
          errorMessage = 'Permission denied. Please check your access rights.';
        } else if (e.toString().contains('network')) {
          errorMessage = 'Network error. Please check your connection.';
        } else if (e.toString().contains('not found')) {
          errorMessage = 'Appointment not found. It may have been deleted.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Appointment",
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
                enabled: !_isUpdating,
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
                  if (value.trim().length < 2) {
                    return 'Patient name must be at least 2 characters';
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
                enabled: !_isUpdating,
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
                  if (value.trim().length < 5) {
                    return 'Reason must be at least 5 characters';
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
                  // Check if selected date is not in the past
                  final today = DateTime.now();
                  final selectedDateOnly = DateTime(selectedDate!.year,
                      selectedDate!.month, selectedDate!.day);
                  final todayOnly =
                      DateTime(today.year, today.month, today.day);

                  if (selectedDateOnly.isBefore(todayOnly)) {
                    return 'Cannot select a past date';
                  }
                  return null;
                },
                builder: (FormFieldState<DateTime> state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: _isUpdating
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
                                  : Colors.grey.shade400,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: _isUpdating ? Colors.grey.shade100 : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: _isUpdating
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
                                  color: _isUpdating ? Colors.grey : null,
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
                        onTap: _isUpdating
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
                                  : Colors.grey.shade400,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: _isUpdating ? Colors.grey.shade100 : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: _isUpdating
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
                                  color: _isUpdating ? Colors.grey : null,
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
                      onPressed: _isUpdating
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
                      onPressed: _isUpdating ? null : _updateAppointment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: _isUpdating
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text("Update"),
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
