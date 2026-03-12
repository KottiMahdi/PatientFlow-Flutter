import 'package:flutter/material.dart';
import 'package:management_cabinet_medical_mobile/features/appointment/domain/entities/appointment.dart';
import 'package:management_cabinet_medical_mobile/features/appointment/domain/usecases/get_appointments.dart';
import 'package:management_cabinet_medical_mobile/features/appointment/domain/usecases/add_appointment.dart';
import 'package:management_cabinet_medical_mobile/features/appointment/domain/usecases/update_appointment.dart';
import 'package:management_cabinet_medical_mobile/features/appointment/domain/usecases/delete_appointment.dart';

class AppointmentProviderGlobal extends ChangeNotifier {
  final GetAppointments getAppointmentsUseCase;
  final AddAppointment addAppointmentUseCase;
  final UpdateAppointment updateAppointmentUseCase;
  final DeleteAppointment deleteAppointmentUseCase;

  AppointmentProviderGlobal({
    required this.getAppointmentsUseCase,
    required this.addAppointmentUseCase,
    required this.updateAppointmentUseCase,
    required this.deleteAppointmentUseCase,
  });

  List<AppointmentEntity> _appointmentList = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _isManualDateSelection = false;

  // Getters
  List<AppointmentEntity> get appointmentList => _appointmentList;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  bool get isManualDateSelection => _isManualDateSelection;

  // Set selected date and notify listeners
  void setSelectedDate(DateTime date, {bool isManual = true}) {
    _selectedDate = date;
    _isManualDateSelection = isManual;
    notifyListeners();
    fetchAppointments(); // Refresh data with new date
  }

  // Reset date to today
  void resetToToday() {
    _selectedDate = DateTime.now();
    _isManualDateSelection = false;
    notifyListeners();
    fetchAppointments();
  }

  // Fetch appointments from Firestore
  Future<void> fetchAppointments() async {
    _isLoading = true;
    notifyListeners();

    final result = await getAppointmentsUseCase(_selectedDate);

    result.fold(
      (failure) {
        debugPrint("Error fetching appointments: ${failure.message}");
        _appointmentList = [];
      },
      (appointments) {
        _appointmentList = appointments;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  // Add new appointment
  Future<bool> addAppointment({
    required String patientName,
    required String date,
    required String time,
    required String reason,
    required String userId,
  }) async {
    final appointment = AppointmentEntity(
      documentId: '', // Will be assigned by Firestore
      userId: userId,
      patientName: patientName,
      date: date,
      time: time,
      reason: reason,
    );

    final result = await addAppointmentUseCase(appointment);

    return result.fold(
      (failure) {
        debugPrint("Error adding appointment: ${failure.message}");
        return false;
      },
      (success) async {
        await fetchAppointments();
        return true;
      },
    );
  }

  // Update existing appointment
  Future<bool> updateAppointment({
    required String documentId,
    required String patientName,
    required String date,
    required String time,
    required String reason,
    required String oldPatientName,
    required String oldDate,
    required String userId,
  }) async {
    final appointment = AppointmentEntity(
      documentId: documentId,
      userId: userId,
      patientName: patientName,
      date: date,
      time: time,
      reason: reason,
    );

    final result = await updateAppointmentUseCase(UpdateAppointmentParams(
      appointment: appointment,
      oldPatientName: oldPatientName,
      oldDate: oldDate,
    ));

    return result.fold(
      (failure) {
        debugPrint("Error updating appointment: ${failure.message}");
        return false;
      },
      (success) async {
        await fetchAppointments();
        return true;
      },
    );
  }

  // Delete appointment
  Future<bool> deleteAppointment(String appointmentId) async {
    final result = await deleteAppointmentUseCase(appointmentId);

    return result.fold(
      (failure) {
        debugPrint("Error deleting appointment: ${failure.message}");
        return false;
      },
      (success) async {
        await fetchAppointments();
        return true;
      },
    );
  }

  // For compatibility with old code if needed
  void refreshUI() {
    notifyListeners();
  }
}
