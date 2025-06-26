import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/track_patient_provider.dart';
import 'classes/waititng_room_column_classe.dart';

class WaitingRoomMainPage extends StatefulWidget {
  const WaitingRoomMainPage({Key? key}) : super(key: key);

  @override
  WaitingRoomMainPageState createState() => WaitingRoomMainPageState();
}

class WaitingRoomMainPageState extends State<WaitingRoomMainPage> {
  bool _isManualDateSelection = false;

  // Define columnData map
  final Map<PatientStatus, Map<String, dynamic>> columnData = {
    PatientStatus.Appointments: {
      'title': 'Appointments',
      'icon': Icons.calendar_today,
      'color': Colors.blue,
      'nextStatus': PatientStatus.waiting
    },
    PatientStatus.waiting: {
      'title': 'Waiting',
      'icon': Icons.access_time,
      'color': Colors.green,
      'nextStatus': PatientStatus.inConsultation
    },
    PatientStatus.inConsultation: {
      'title': 'In Consultation',
      'icon': Icons.medical_services,
      'color': Colors.orange,
      'nextStatus': PatientStatus.completed
    },
    PatientStatus.completed: {
      'title': 'Completed',
      'icon': Icons.check_circle,
      'color': Colors.purple,
      'nextStatus': PatientStatus.completed
    }
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PatientProvider>(context, listen: false).fetchPatients();
    });
  }

  @override
  Widget build(BuildContext context) {
    final patientProvider = Provider.of<PatientProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Track Patient',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
              Text(
                DateFormat('EEEE, d MMMM yyyy').format(patientProvider.selectedDate),
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
              icon: Icon(Icons.calendar_today, size: screenWidth * 0.06, color: Colors.white),
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: patientProvider.selectedDate,
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2101),
                  // Custom theme for date picker
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: const Color(0xFF1E3A8A),
                          onPrimary: Colors.white,
                          onSurface: const Color(0xFF1E3A8A),
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
                if (picked != null && picked != patientProvider.selectedDate) {
                  patientProvider.changeDate(picked);
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
                icon: Icon(Icons.clear, size: screenWidth * 0.06, color: Colors.white),
                onPressed: () {
                  patientProvider.changeDate(DateTime.now());
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
                    _buildColumn(context, patientProvider.AppointmentsPatients, PatientStatus.Appointments),
                    _buildColumn(context, patientProvider.waitingPatients, PatientStatus.waiting),
                    _buildColumn(context, patientProvider.inConsultationPatients, PatientStatus.inConsultation),
                    _buildColumn(context, patientProvider.completedPatients, PatientStatus.completed),
                  ],
                )
                    : Column(
                  children: [
                    _buildColumn(context, patientProvider.AppointmentsPatients, PatientStatus.Appointments),
                    SizedBox(height: screenWidth * 0.03),
                    _buildColumn(context, patientProvider.waitingPatients, PatientStatus.waiting),
                    SizedBox(height: screenWidth * 0.03),
                    _buildColumn(context, patientProvider.inConsultationPatients, PatientStatus.inConsultation),
                    SizedBox(height: screenWidth * 0.03),
                    _buildColumn(context, patientProvider.completedPatients, PatientStatus.completed),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildColumn(BuildContext context, List<Patient> patients, PatientStatus status) {
    return WaitingRoomColumn(
      title: columnData[status]!['title'] as String,
      icon: columnData[status]!['icon'] as IconData,
      color: columnData[status]!['color'] as Color,
      patients: patients,
      onPatientMove: (patient) {
        Provider.of<PatientProvider>(context, listen: false)
            .movePatient(patient.id, columnData[status]!['nextStatus'] as PatientStatus);
      },
      onPatientDropped: (patient) {
        Provider.of<PatientProvider>(context, listen: false)
            .movePatient(patient.id, status);
      },
      targetStatus: status,
    );
  }
}

