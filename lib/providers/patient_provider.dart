import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/patient_model.dart';

class PatientProviderGlobal extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Patient> _patients = [];
  List<Patient> _filteredPatients = [];
  bool _isLoading = false;
  String _searchQuery = '';

  // Getters
  List<Patient> get patients => _patients;
  List<Patient> get filteredPatients => _searchQuery.isEmpty
      ? _patients
      : _filteredPatients;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  // Set search query and filter patients
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

  // Fetch patients from Firestore
  Future<void> fetchPatients() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('patients')
          .where('id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .orderBy('createdAt', descending: true)
          .get();

      _patients = snapshot.docs
          .map((doc) => Patient.fromDocument(doc))
          .toList();

      // Update filtered patients if there's a search query
      if (_searchQuery.isNotEmpty) {
        setSearchQuery(_searchQuery);
      }
    } catch (e) {
      print('Error fetching patients: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new patient
  Future<bool> addPatient(Map<String, dynamic> patientData) async {
    try {
      // Add timestamp
      patientData['createdAt'] = FieldValue.serverTimestamp();

      // Add user ID
      patientData['id'] = FirebaseAuth.instance.currentUser!.uid;

      // Add to Firestore
      DocumentReference docRef = await _firestore.collection('patients').add(patientData);

      // Notify listeners to update UI
      notifyListeners();

      // Fetch updated patients
      await fetchPatients();
      return true;
    } catch (e) {
      print('Error adding patient: $e');
      return false;
    }
  }

  // Update an existing patient
  Future<bool> updatePatient(String patientId, Map<String, dynamic> patientData) async {
    try {
      await _firestore.collection('patients').doc(patientId).update(patientData);
      await fetchPatients();
      return true;
    } catch (e) {
      print('Error updating patient: $e');
      return false;
    }
  }

  // Delete a patient
  Future<bool> deletePatient(String patientId) async {
    try {
      await _firestore.collection('patients').doc(patientId).delete();
      await fetchPatients();
      return true;
    } catch (e) {
      print('Error deleting patient: $e');
      return false;
    }
  }

  // Get dropdown options
  Future<List<String>> getDropdownOptions(String document) async {
    try {
      DocumentSnapshot snapshot = await _firestore
          .collection("dropdown_options")
          .doc(document)
          .get();

      if (!snapshot.exists) {
        return [];
      }

      final Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      return data.values.whereType<String>().toList();
    } catch (e) {
      print("Error fetching $document options: $e");
      return [];
    }
  }

  // ===== NEW ANTECEDENTS METHODS =====

  // Fetch patient data including antecedents
  Future<Map<String, dynamic>> fetchPatientData(String patientId) async {
    try {
      final patientDoc = await _firestore
          .collection('patients')
          .doc(patientId)
          .get();

      if (patientDoc.exists) {
        return patientDoc.data() ?? {};
      } else {
        return {};
      }
    } catch (e) {
      print('Error fetching patient data: $e');
      return {};
    }
  }

  // Fetch patient antecedents
  Future<Map<String, List<String>>> fetchPatientAntecedents(String patientId) async {
    Map<String, List<String>> categoryItems = {
      'Antécédents obstétricaux': [],
      'Antécédents gynécologiques': [],
      'Antécédents menstruels': [],
      'Antécédents familiaux': [],
      'Antécédents médicaux': [],
      'Antécédents chirurgicaux': [],
      'Facteurs de risque': [],
      'Allergique': [],
    };

    try {
      final patientDoc = await _firestore
          .collection('patients')
          .doc(patientId)
          .get();

      if (patientDoc.exists) {
        final antecedents = patientDoc.data()?['antecedents'] as Map<String, dynamic>? ?? {};

        // Populate categoryItems with the patient's antecedents
        for (var category in categoryItems.keys) {
          categoryItems[category] = List<String>.from(antecedents[category] ?? []);
        }
      }
      return categoryItems;
    } catch (e) {
      print('Error fetching patient antecedents: $e');
      return categoryItems;
    }
  }

  // Save patient antecedents
  Future<bool> savePatientAntecedents(String patientId, Map<String, List<String>> categoryItems) async {
    try {
      await _firestore
          .collection('patients')
          .doc(patientId)
          .update({
        'antecedents': categoryItems,
      });
      return true;
    } catch (e) {
      print('Error saving patient antecedents: $e');
      return false;
    }
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

  // Fetch antecedents options from Firestore
  Future<List<String>> getAntecedentsOptions(String document) async {
    try {
      DocumentSnapshot snapshot = await _firestore
          .collection("antecedents")
          .doc(document)
          .get();

      if (!snapshot.exists) {
        print("Document does not exist");
        return [];
      }

      final Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      return data.values
          .whereType<String>()
          .toList();
    } catch (e) {
      print("Error fetching $document options: $e");
      return [];
    }
  }
}