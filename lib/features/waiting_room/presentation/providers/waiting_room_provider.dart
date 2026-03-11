import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:management_cabinet_medical_mobile/features/waiting_room/domain/entities/waiting_room_patient.dart';
import 'package:management_cabinet_medical_mobile/features/waiting_room/domain/usecases/get_waiting_room_patients.dart';
import 'package:management_cabinet_medical_mobile/features/waiting_room/domain/usecases/update_patient_status.dart';
import 'package:management_cabinet_medical_mobile/features/waiting_room/domain/usecases/delete_waiting_room_patient.dart';
import 'package:management_cabinet_medical_mobile/features/waiting_room/domain/usecases/add_waiting_room_patient.dart';

class WaitingRoomProviderGlobal with ChangeNotifier {
  final GetWaitingRoomPatients getWaitingRoomPatients;
  final UpdatePatientStatus updatePatientStatus;
  final DeleteWaitingRoomPatient deleteWaitingRoomPatient;
  final AddWaitingRoomPatient addWaitingRoomPatient;

  bool _isLoading = true;
  List<WaitingRoomPatient> _allPatients = [];
  DateTime _selectedDate = DateTime.now();
  String _formattedDate = '';

  WaitingRoomProviderGlobal({
    required this.getWaitingRoomPatients,
    required this.updatePatientStatus,
    required this.deleteWaitingRoomPatient,
    required this.addWaitingRoomPatient,
  }) {
    _formattedDate = DateFormat('d/M/yyyy').format(_selectedDate);
  }

  // Getters
  bool get isLoading => _isLoading;
  List<WaitingRoomPatient> get allPatients => _allPatients;
  DateTime get selectedDate => _selectedDate;
  String get formattedDate => _formattedDate;

  List<WaitingRoomPatient> get waitingPatients => _allPatients
      .where((p) =>
          p.status == WaitingRoomStatus.waiting && p.date == _formattedDate)
      .toList();

  List<WaitingRoomPatient> get inConsultationPatients => _allPatients
      .where((p) =>
          p.status == WaitingRoomStatus.inConsultation &&
          p.date == _formattedDate)
      .toList();

  List<WaitingRoomPatient> get completedPatients => _allPatients
      .where((p) =>
          p.status == WaitingRoomStatus.completed && p.date == _formattedDate)
      .toList();

  List<WaitingRoomPatient> get appointmentsPatients => _allPatients
      .where((p) =>
          p.status == WaitingRoomStatus.appointments &&
          p.date == _formattedDate)
      .toList();

  int get waitingCount => waitingPatients.length;
  int get inConsultationCount => inConsultationPatients.length;
  int get completedCount => completedPatients.length;

  // Methods
  void init(String userId) {
    getWaitingRoomPatients(userId).listen((patients) {
      _allPatients = patients;
      _isLoading = false;
      notifyListeners();
    });
  }

  void changeDate(DateTime newDate) {
    _selectedDate = newDate;
    _formattedDate = DateFormat('d/M/yyyy').format(_selectedDate);
    notifyListeners();
  }

  Future<void> movePatient(
      String patientId, WaitingRoomStatus newStatus) async {
    final result = await updatePatientStatus(patientId, newStatus);
    result.fold(
      (failure) => debugPrint('Error moving patient: $failure'),
      (_) => null, // Firestore listener handles UI update
    );
  }

  Future<void> deletePatient(String patientId) async {
    final result = await deleteWaitingRoomPatient(patientId);
    result.fold(
      (failure) => debugPrint('Error deleting patient: $failure'),
      (_) => null, // Firestore listener handles UI update
    );
  }

  Future<bool> addPatient({
    required String userId,
    required String name,
    required String time,
    required String date,
    required WaitingRoomStatus status,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await addWaitingRoomPatient(AddPatientParams(
      userId: userId,
      name: name,
      time: time,
      date: date,
      status: status,
    ));

    return result.fold(
      (failure) {
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (_) {
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }
}
