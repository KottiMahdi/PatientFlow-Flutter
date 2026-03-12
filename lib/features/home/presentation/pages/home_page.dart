import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'package:management_cabinet_medical_mobile/features/patient/presentation/pages/add_patient_page.dart';
import 'package:management_cabinet_medical_mobile/features/profile/presentation/providers/profile_provider.dart';
import 'package:management_cabinet_medical_mobile/features/weather/presentation/providers/weather_provider.dart';
import 'package:management_cabinet_medical_mobile/features/patient/presentation/providers/patient_provider.dart';
import 'package:management_cabinet_medical_mobile/features/waiting_room/presentation/providers/waiting_room_provider.dart';
import 'package:management_cabinet_medical_mobile/features/waiting_room/domain/entities/waiting_room_patient.dart';
import 'package:management_cabinet_medical_mobile/features/appointment/presentation/pages/appointment_scheduler_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String userRole = 'Not Provided yet';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PatientProviderGlobal>(context, listen: false)
          .fetchPatients();
      Provider.of<ProfileProviderGlobal>(context, listen: false)
          .loadUserData(context);
      Provider.of<WeatherProviderGlobal>(context, listen: false).loadWeather();

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        Provider.of<WaitingRoomProviderGlobal>(context, listen: false)
            .init(currentUser.uid);
      }
    });
  }

  Widget _buildWeatherWidget() {
    return Consumer<WeatherProviderGlobal>(
      builder: (context, weatherProvider, child) {
        if (weatherProvider.isLoadingWeather) {
          return const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Loading...',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          );
        }

        if (weatherProvider.weatherError.isNotEmpty) {
          return GestureDetector(
            onTap: () {
              weatherProvider.refreshWeather();
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh, color: Colors.white70, size: 16),
                SizedBox(width: 4),
                Text(
                  'Tap to retry',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          );
        }

        if (weatherProvider.weather != null) {
          return GestureDetector(
            onTap: () {
              weatherProvider.refreshWeather();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.network(
                    'https://openweathermap.org/img/wn/${weatherProvider.weather!.icon}@2x.png',
                    width: 24,
                    height: 24,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.wb_sunny,
                          color: Colors.white, size: 16);
                    },
                  ),
                  const SizedBox(width: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${weatherProvider.weather!.temperature.round()}°C',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        weatherProvider.weather!.cityName,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.refresh,
                    color: Colors.white70,
                    size: 16,
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final patientProvider = Provider.of<PatientProviderGlobal>(context);
    final profileProvider = Provider.of<ProfileProviderGlobal>(context);
    final waitingRoomProvider = Provider.of<WaitingRoomProviderGlobal>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Medical Management',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(child: _buildWeatherWidget()),
          ),
        ],
      ),
      body: patientProvider.isLoading || profileProvider.isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Color(0xFF2A79B0)),
                  const SizedBox(height: 16),
                  Text(
                    'Loading profile...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Color(0xFF1E3A8A),
                        child:
                            Icon(Icons.person, size: 40, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, ${profileProvider.nameController.text}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E3A8A),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              profileProvider.selectedSpecialization ??
                                  userRole,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Today: ${DateFormat('EEEE, d MMMM yyyy').format(waitingRoomProvider.selectedDate)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: waitingRoomProvider.selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
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
                          if (picked != null &&
                              picked != waitingRoomProvider.selectedDate) {
                            waitingRoomProvider.changeDate(picked);
                          }
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildStatusCard(
                        context,
                        Icons.people,
                        waitingRoomProvider.waitingCount.toString(),
                        'Waiting',
                        Colors.green[100]!,
                        Colors.green,
                      ),
                      _buildStatusCard(
                        context,
                        Icons.medical_services,
                        waitingRoomProvider.inConsultationCount.toString(),
                        'In Consultation',
                        Colors.orange[100]!,
                        Colors.orange,
                      ),
                      _buildStatusCard(
                        context,
                        Icons.check_circle,
                        waitingRoomProvider.completedCount.toString(),
                        'Completed',
                        Colors.purple[100]!,
                        Colors.purple,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Quick Access',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddPatientPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.person),
                        label: const Text('Add Patient'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AppointmentSchedulerPage(
                                  onAppointmentAdded: () {}),
                            ),
                          );
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: const Text(
                          'Add Appointment',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Today\'s Appointments',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  _buildAppointmentsList(context, waitingRoomProvider),
                ],
              ),
            ),
    );
  }

  Widget _buildAppointmentsList(
      BuildContext context, WaitingRoomProviderGlobal provider) {
    final allTodaysPatients = [
      ...provider.appointmentsPatients,
      ...provider.waitingPatients,
      ...provider.inConsultationPatients,
      ...provider.completedPatients,
    ];

    if (allTodaysPatients.isEmpty) {
      return const Center(
        child: Text('No appointments for today'),
      );
    }

    return Column(
      children: allTodaysPatients.map((patient) {
        String displayStatus;
        switch (patient.status) {
          case WaitingRoomStatus.waiting:
            displayStatus = 'Waiting';
            break;
          case WaitingRoomStatus.inConsultation:
            displayStatus = 'In Consultation';
            break;
          case WaitingRoomStatus.completed:
            displayStatus = 'Completed';
            break;
          default:
            displayStatus = 'Scheduled';
        }

        return _buildAppointmentCard(
          context,
          patient.name,
          patient.time,
          'Appointment',
          displayStatus,
        );
      }).toList(),
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    IconData icon,
    String count,
    String label,
    Color backgroundColor,
    Color? iconColor,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Expanded(
      child: Card(
        color: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Column(
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(height: 8),
              Text(
                count,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth < 400 ? 18 : 22,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: screenWidth < 400 ? 11 : 14,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(
    BuildContext context,
    String patientName,
    String time,
    String purpose,
    String status,
  ) {
    Color statusColor;
    switch (status) {
      case 'Waiting':
        statusColor = Colors.green;
        break;
      case 'In Consultation':
        statusColor = Colors.orange;
        break;
      case 'Completed':
        statusColor = Colors.purple;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.person),
        ),
        title: Text(patientName),
        subtitle: Text('$time - $purpose'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: TextStyle(color: statusColor),
          ),
        ),
        onTap: () {
          // Navigate to patient details
        },
      ),
    );
  }
}
