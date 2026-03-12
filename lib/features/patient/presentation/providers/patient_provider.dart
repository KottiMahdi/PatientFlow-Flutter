import 'package:flutter/material.dart';
import 'package:management_cabinet_medical_mobile/core/usecases/usecase.dart';
import 'package:management_cabinet_medical_mobile/features/patient/domain/entities/patient.dart';
import 'package:management_cabinet_medical_mobile/features/patient/domain/usecases/add_patient.dart';
import 'package:management_cabinet_medical_mobile/features/patient/domain/usecases/delete_patient.dart';
import 'package:management_cabinet_medical_mobile/features/patient/domain/usecases/fetch_patient_antecedents.dart';
import 'package:management_cabinet_medical_mobile/features/patient/domain/usecases/get_dropdown_options.dart';
import 'package:management_cabinet_medical_mobile/features/patient/domain/usecases/get_patients.dart';
import 'package:management_cabinet_medical_mobile/features/patient/domain/usecases/save_patient_antecedents.dart';
import 'package:management_cabinet_medical_mobile/features/patient/domain/usecases/update_patient.dart';
import 'package:management_cabinet_medical_mobile/features/patient/domain/usecases/get_antecedents_options.dart';

class PatientProviderGlobal extends ChangeNotifier {
  final GetPatients getPatientsUseCase;
  final AddPatient addPatientUseCase;
  final UpdatePatient updatePatientUseCase;
  final DeletePatient deletePatientUseCase;
  final GetDropdownOptions getDropdownOptionsUseCase;
  final FetchPatientAntecedents fetchPatientAntecedentsUseCase;
  final SavePatientAntecedents savePatientAntecedentsUseCase;
  final GetAntecedentsOptions getAntecedentsOptionsUseCase;

  PatientProviderGlobal({
    required this.getPatientsUseCase,
    required this.addPatientUseCase,
    required this.updatePatientUseCase,
    required this.deletePatientUseCase,
    required this.getDropdownOptionsUseCase,
    required this.fetchPatientAntecedentsUseCase,
    required this.savePatientAntecedentsUseCase,
    required this.getAntecedentsOptionsUseCase,
  });

  List<PatientEntity> _patients = [];
  List<PatientEntity> _filteredPatients = [];
  bool _isLoading = false;
  String _searchQuery = '';

  // Getters
  List<PatientEntity> get patients => _patients;
  List<PatientEntity> get filteredPatients =>
      _searchQuery.isEmpty ? _patients : _filteredPatients;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredPatients = [];
    } else {
      _filteredPatients = _patients.where((patient) {
        String name = '${patient.name} ${patient.prenom}'.toLowerCase();
        return name.contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  Future<void> fetchPatients() async {
    _isLoading = true;
    notifyListeners();

    final result = await getPatientsUseCase(NoParams());

    result.fold(
      (failure) => debugPrint('Error fetching patients: ${failure.message}'),
      (patients) {
        _patients = patients;
        if (_searchQuery.isNotEmpty) {
          setSearchQuery(_searchQuery);
        }
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addPatient(PatientEntity patient) async {
    final result = await addPatientUseCase(patient);

    return result.fold(
      (failure) {
        debugPrint('Error adding patient: ${failure.message}');
        return false;
      },
      (success) async {
        await fetchPatients();
        return true;
      },
    );
  }

  Future<bool> updatePatient(PatientEntity patient) async {
    final result = await updatePatientUseCase(patient);

    return result.fold(
      (failure) {
        debugPrint('Error updating patient: ${failure.message}');
        return false;
      },
      (success) async {
        await fetchPatients();
        return true;
      },
    );
  }

  Future<bool> deletePatient(String patientId) async {
    final result = await deletePatientUseCase(patientId);

    return result.fold(
      (failure) {
        debugPrint('Error deleting patient: ${failure.message}');
        return false;
      },
      (success) async {
        await fetchPatients();
        return true;
      },
    );
  }

  Future<List<String>> getDropdownOptions(String document) async {
    final result = await getDropdownOptionsUseCase(document);
    return result.fold(
      (failure) {
        debugPrint('Error fetching $document options: ${failure.message}');
        return [];
      },
      (options) => options,
    );
  }

  Future<Map<String, List<String>>> fetchPatientAntecedents(
      String patientId) async {
    final result = await fetchPatientAntecedentsUseCase(patientId);
    return result.fold(
      (failure) {
        debugPrint('Error fetching patient antecedents: ${failure.message}');
        return {};
      },
      (antecedents) => antecedents,
    );
  }

  Future<bool> savePatientAntecedents(
      String patientId, Map<String, List<String>> categoryItems) async {
    final result = await savePatientAntecedentsUseCase(
      SavePatientAntecedentsParams(
          patientId: patientId, categoryItems: categoryItems),
    );
    return result.fold(
      (failure) {
        debugPrint('Error saving patient antecedents: ${failure.message}');
        return false;
      },
      (success) => true,
    );
  }

  // Method to get a specific patient by ID
  PatientEntity getPatientById(String patientId) {
    return _patients.firstWhere(
      (p) => p.id == patientId,
      orElse: () => PatientEntity.empty(),
    );
  }

  // Helper function to get document key for antecedents collection
  String getDocumentKey(String category) {
    switch (category) {
      case 'Antécédents obstétricaux':
        return 'obstetricaux';
      case 'Antécédents gynécologiques':
        return 'gynecologiques';
      case 'Antécédents menstruels':
        return 'menstruels';
      case 'Antécédents familiaux':
        return 'familiaux';
      case 'Antécédents médicaux':
        return 'medicaux';
      case 'Antécédents chirurgicaux':
        return 'chirurgicaux';
      case 'Facteurs de risque':
        return 'facteurs_de_risque';
      case 'Allergique':
        return 'allergique';
      default:
        return '';
    }
  }

  Future<List<String>> getAntecedentsOptions(String document) async {
    final result = await getAntecedentsOptionsUseCase(document);
    return result.fold(
      (failure) {
        debugPrint('Error fetching antecedent options: ${failure.message}');
        return [];
      },
      (options) => options,
    );
  }
}
