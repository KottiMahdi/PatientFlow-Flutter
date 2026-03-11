import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:management_cabinet_medical_mobile/features/appointment/presentation/providers/appointment_provider.dart';
import 'package:management_cabinet_medical_mobile/utils/floating_button.dart';
import 'package:management_cabinet_medical_mobile/features/appointment/presentation/pages/appointment_scheduler_page.dart';
import 'package:management_cabinet_medical_mobile/features/appointment/presentation/pages/components/build_action_buttons.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  @override
  void initState() {
    super.initState();
    // Initialize data fetch when widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppointmentProviderGlobal>(context, listen: false)
          .fetchAppointments();
    });
  }

  /// Opens a date picker and updates the selected date
  Future<void> _selectDate(BuildContext context) async {
    final provider =
        Provider.of<AppointmentProviderGlobal>(context, listen: false);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
      // Custom theme for date picker
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E3A8A),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E3A8A),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1E3A8A),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    // Update selected date if user picked a new date
    if (picked != null && picked != provider.selectedDate) {
      provider.setSelectedDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Consumer<AppointmentProviderGlobal>(
      builder: (context, appointmentProvider, child) {
        return Scaffold(
          // App bar with date display and date selection controls
          appBar: AppBar(
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Appointments',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                // Format and display the currently selected date
                Text(
                  DateFormat('EEEE, d MMMM yyyy')
                      .format(appointmentProvider.selectedDate),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF1E3A8A),
            actions: [
              // Calendar icon to open date picker
              Container(
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                ),
                child: IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.white),
                  onPressed: () => _selectDate(context),
                  tooltip: 'Select Date',
                ),
              ),
              // Clear button to reset date to today (only shown when date is manually selected)
              if (appointmentProvider.isManualDateSelection)
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white),
                  onPressed: () => appointmentProvider.resetToToday(),
                  tooltip: 'Reset to Today',
                )
            ],
          ),
          body: GestureDetector(
            // Dismiss keyboard when tapping outside input fields
            onTap: () => FocusScope.of(context).unfocus(),
            // Pull-to-refresh functionality
            child: RefreshIndicator(
              onRefresh: () => appointmentProvider.fetchAppointments(),
              color: const Color(0xFF1E3A8A),
              // Conditional UI based on appointment data availability
              child: appointmentProvider.appointmentList.isEmpty
                  ? Center(
                      // Show loading indicator or empty state message
                      child: !appointmentProvider.isLoading
                          ? Column(
                              // Empty state - no appointments for selected date
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.event_busy,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No appointments found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Button to add a new appointment
                                TextButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AppointmentSchedulerPage(
                                          onAppointmentAdded: () {
                                            Provider.of<AppointmentProviderGlobal>(
                                                    context,
                                                    listen: false)
                                                .fetchAppointments();
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Appointment'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFF1E3A8A),
                                  ),
                                ),
                              ],
                            )
                          : const CircularProgressIndicator(
                              // Loading indicator while fetching data
                              color: Color(0xFF1E3A8A),
                            ),
                    )
                  : ListView.builder(
                      // List of appointments with proper padding
                      padding: const EdgeInsets.only(
                          left: 12, right: 12, bottom: 70, top: 16),
                      itemCount: appointmentProvider.appointmentList.length,
                      itemBuilder: (context, index) {
                        final appointment =
                            appointmentProvider.appointmentList[index];
                        // Appointment card widget
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Card(
                            margin: EdgeInsets.zero,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  // Header with time information
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent.shade400
                                          .withValues(alpha: 0.1),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.access_time,
                                          size: 20,
                                          color: Color(0xFF1E3A8A),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          appointment.time,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E3A8A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Appointment details section
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            // Patient avatar with initial
                                            CircleAvatar(
                                              backgroundColor:
                                                  const Color(0xFF1E3A8A)
                                                      .withValues(alpha: 0.2),
                                              radius: 24,
                                              child: Text(
                                                appointment.patientName
                                                    .substring(0, 1)
                                                    .toUpperCase(),
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF1E3A8A),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Patient name display
                                                  Text(
                                                    appointment.patientName,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  // Appointment reason display
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: Text(
                                                      " Reason : ${appointment.reason}",
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.black87,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                      maxLines: 4,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Divider(
                                            height: 1,
                                            thickness: 1,
                                            color: Colors.grey.shade200),
                                        const SizedBox(height: 12),
                                        // Action buttons for the appointment (edit, delete, etc.)
                                        AppointmentActionButtons(
                                          context: context,
                                          index: index,
                                          appointment: appointment,
                                          fetchData: Provider.of<
                                                      AppointmentProviderGlobal>(
                                                  context,
                                                  listen: false)
                                              .fetchAppointments,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
          // Floating action button to add new appointments
          floatingActionButton: FloatingButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppointmentSchedulerPage(
                    onAppointmentAdded: () {
                      Provider.of<AppointmentProviderGlobal>(context,
                              listen: false)
                          .fetchAppointments();
                    },
                  ),
                ),
              );
            },
            label: 'Schedule Appointment',
            icon: Icons.calendar_today,
            backgroundColor: const Color(0xFF1E3A8A),
            foregroundColor: Colors.white,
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }
}
