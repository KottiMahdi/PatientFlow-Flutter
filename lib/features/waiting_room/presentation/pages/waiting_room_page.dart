import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:management_cabinet_medical_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:management_cabinet_medical_mobile/features/waiting_room/domain/entities/waiting_room_patient.dart';
import 'package:management_cabinet_medical_mobile/features/waiting_room/presentation/providers/waiting_room_provider.dart';
import 'package:management_cabinet_medical_mobile/features/waiting_room/presentation/pages/classes/waititng_room_column_classe.dart';

class WaitingRoomMainPage extends StatefulWidget {
  const WaitingRoomMainPage({super.key});

  @override
  WaitingRoomMainPageState createState() => WaitingRoomMainPageState();
}

class WaitingRoomMainPageState extends State<WaitingRoomMainPage> {
  bool _isManualDateSelection = false;

  // Define columnData map
  final Map<WaitingRoomStatus, Map<String, dynamic>> columnData = {
    WaitingRoomStatus.appointments: {
      'title': 'Appointments',
      'icon': Icons.calendar_today,
      'color': Colors.blue,
      'nextStatus': WaitingRoomStatus.waiting
    },
    WaitingRoomStatus.waiting: {
      'title': 'Waiting',
      'icon': Icons.access_time,
      'color': Colors.green,
      'nextStatus': WaitingRoomStatus.inConsultation
    },
    WaitingRoomStatus.inConsultation: {
      'title': 'In Consultation',
      'icon': Icons.medical_services,
      'color': Colors.orange,
      'nextStatus': WaitingRoomStatus.completed
    },
    WaitingRoomStatus.completed: {
      'title': 'Completed',
      'icon': Icons.check_circle,
      'color': Colors.grey,
      'nextStatus': null,
    }
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider =
          Provider.of<AuthProviderGlobal>(context, listen: false);
      if (authProvider.user != null) {
        Provider.of<WaitingRoomProviderGlobal>(context, listen: false)
            .init(authProvider.user!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final waitingRoomProvider = Provider.of<WaitingRoomProviderGlobal>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Track Patient',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            Text(
              DateFormat('EEEE, d MMMM yyyy')
                  .format(waitingRoomProvider.selectedDate),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: screenWidth * 0.04,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(screenWidth * 0.02),
            ),
            child: IconButton(
              icon: Icon(Icons.calendar_today,
                  size: screenWidth * 0.06, color: Colors.white),
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: waitingRoomProvider.selectedDate,
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
                if (picked != null &&
                    picked != waitingRoomProvider.selectedDate) {
                  waitingRoomProvider.changeDate(picked);
                  setState(() {
                    _isManualDateSelection = true;
                  });
                }
              },
            ),
          ),
          if (_isManualDateSelection)
            Container(
              margin: EdgeInsets.only(right: screenWidth * 0.02),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
              ),
              child: IconButton(
                icon: Icon(Icons.clear,
                    size: screenWidth * 0.06, color: Colors.white),
                onPressed: () {
                  waitingRoomProvider.changeDate(DateTime.now());
                  setState(() {
                    _isManualDateSelection = false;
                  });
                },
              ),
            )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEBF0F5), Color(0xFFF5F7FA)],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (waitingRoomProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenWidth * 0.02,
                ),
                child: isTablet
                    ? GridView.count(
                        crossAxisCount: screenWidth > 1200 ? 4 : 2,
                        childAspectRatio: 0.9,
                        crossAxisSpacing: screenWidth * 0.03,
                        mainAxisSpacing: screenWidth * 0.02,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildColumn(
                              context,
                              waitingRoomProvider.appointmentsPatients,
                              WaitingRoomStatus.appointments),
                          _buildColumn(
                              context,
                              waitingRoomProvider.waitingPatients,
                              WaitingRoomStatus.waiting),
                          _buildColumn(
                              context,
                              waitingRoomProvider.inConsultationPatients,
                              WaitingRoomStatus.inConsultation),
                          _buildColumn(
                              context,
                              waitingRoomProvider.completedPatients,
                              WaitingRoomStatus.completed),
                        ],
                      )
                    : Column(
                        children: [
                          _buildColumn(
                              context,
                              waitingRoomProvider.appointmentsPatients,
                              WaitingRoomStatus.appointments),
                          SizedBox(height: screenWidth * 0.03),
                          _buildColumn(
                              context,
                              waitingRoomProvider.waitingPatients,
                              WaitingRoomStatus.waiting),
                          SizedBox(height: screenWidth * 0.03),
                          _buildColumn(
                              context,
                              waitingRoomProvider.inConsultationPatients,
                              WaitingRoomStatus.inConsultation),
                          SizedBox(height: screenWidth * 0.03),
                          _buildColumn(
                              context,
                              waitingRoomProvider.completedPatients,
                              WaitingRoomStatus.completed),
                        ],
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildColumn(BuildContext context, List<WaitingRoomPatient> patients,
      WaitingRoomStatus status) {
    return WaitingRoomColumn(
      title: columnData[status]!['title'] as String,
      icon: columnData[status]!['icon'] as IconData,
      color: columnData[status]!['color'] as Color,
      patients: patients,
      onPatientMove: (patient) {
        Provider.of<WaitingRoomProviderGlobal>(context, listen: false)
            .movePatient(patient.id,
                columnData[status]!['nextStatus'] as WaitingRoomStatus);
      },
      onPatientDropped: (patient) {
        Provider.of<WaitingRoomProviderGlobal>(context, listen: false)
            .movePatient(patient.id, status);
      },
      targetStatus: status,
    );
  }
}
