import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Enum to represent different patient statuses in the waiting room
enum PatientStatus { waiting, inConsultation, completed, Appointments }

// Patient class to represent individual patient information
class Patient {
  final String id;
  final String name;
  final String time;
  final String date;
  final DateTime createdAt;
  PatientStatus status;

  // Constructor with required fields and default status
  Patient({
    required this.id,
    required this.name,
    required this.time,
    required this.date,
    required this.createdAt,
    this.status = PatientStatus.Appointments,
  });
}

// Provider class to manage patient state and Firestore interactions
class PatientProvider with ChangeNotifier {
  bool isLoading = true;

  // Private list to store all patients
  List<Patient> _allPatients = [];

  // Currently selected date for filtering patients
  DateTime _selectedDate = DateTime.now();

  // Formatted date string for display and filtering
  String _formattedDate = '';

  // Counters for patients in different statuses
  int _waitingCount = 0;
  int _inConsultationCount = 0;
  int _completedCount = 0;
  int _AppointmentsCount = 0;

  // Getters to access private properties
  List<Patient> get allPatients => _allPatients;
  DateTime get selectedDate => _selectedDate;
  String get formattedDate => _formattedDate;

  // Filtered lists of patients based on status and current date
  List<Patient> get waitingPatients => _allPatients
      .where((p) => p.status == PatientStatus.waiting && p.date == _formattedDate)
      .toList();

  List<Patient> get inConsultationPatients => _allPatients
      .where((p) => p.status == PatientStatus.inConsultation && p.date == _formattedDate)
      .toList();

  List<Patient> get completedPatients => _allPatients
      .where((p) => p.status == PatientStatus.completed && p.date == _formattedDate)
      .toList();

  List<Patient> get AppointmentsPatients => _allPatients
      .where((p) => p.status == PatientStatus.Appointments && p.date == _formattedDate)
      .toList();

  // Getters for patient status counts
  int get waitingCount => _waitingCount;
  int get inConsultationCount => _inConsultationCount;
  int get completedCount => _completedCount;
  int get AppointmentsCount => _AppointmentsCount;

  // Constructor that initializes the formatted date and starts fetching patients
  PatientProvider() {
    // Format the current date
    _formattedDate = DateFormat('d/M/yyyy').format(_selectedDate);
    // Begin listening to Firestore for patient updates
    fetchPatients();
  }

  // Method to change the selected date and update patient view
  void changeDate(DateTime newDate) {
    _selectedDate = newDate;
    // Reformat date and update patient counts
    _formattedDate = DateFormat('d/M/yyyy').format(_selectedDate);
    _updateCounts();
    // Notify listeners of state change
    notifyListeners();
  }

  // Fetch patients from Firestore in real-time
  void fetchPatients() {
    FirebaseFirestore.instance
        .collection('waiting_room')
        .where('id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .orderBy('time')
        .snapshots()
        .listen((snapshot) {
      // Convert Firestore documents to Patient objects
      _allPatients = snapshot.docs.map((doc) {
        var data = doc.data();
        return Patient(
          id: doc.id,
          name: data['name'] ?? 'N/A',
          time: data['time'] ?? 'N/A',
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          // Convert status string to enum, default to Appointments if not found
          status: PatientStatus.values.firstWhere(
                (e) => e.toString().split('.').last == data['status'],
            orElse: () => PatientStatus.Appointments,
          ),
          date: data['date'] ?? 'N/A',
        );
      }).toList();

      // Update patient counts and notify listeners
      _updateCounts();

      // Set isLoading to false after first data retrieval
      if (isLoading) {
        isLoading = false;
      }

      notifyListeners();
    });
  }

  // Internal method to update patient status counts for the current date
  void _updateCounts() {
    // Reset all counters
    _waitingCount = 0;
    _inConsultationCount = 0;
    _completedCount = 0;
    _AppointmentsCount = 0;

    // Count patients for the current date
    for (var patient in _allPatients) {
      if (patient.date == _formattedDate) {
        switch (patient.status) {
          case PatientStatus.waiting:
            _waitingCount++;
            break;
          case PatientStatus.inConsultation:
            _inConsultationCount++;
            break;
          case PatientStatus.completed:
            _completedCount++;
            break;
          case PatientStatus.Appointments:
            _AppointmentsCount++;
            break;
        }
      }
    }
  }

  // Method to update a patient's status in Firestore
  void movePatient(String patientId, PatientStatus newStatus) {
    // Update patient status in Firestore
    FirebaseFirestore.instance
        .collection('waiting_room')
        .doc(patientId)
        .update({'status': newStatus.toString().split('.').last});
    // Firestore listener will handle state update automatically
  }
}