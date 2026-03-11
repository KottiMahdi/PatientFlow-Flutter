import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:management_cabinet_medical_mobile/core/error/failures.dart';
import 'package:management_cabinet_medical_mobile/features/patient/domain/entities/patient.dart';
import 'package:management_cabinet_medical_mobile/features/patient/domain/repositories/patient_repository.dart';
import 'package:management_cabinet_medical_mobile/features/patient/data/models/patient_model.dart';

class PatientRepositoryImpl implements PatientRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  PatientRepositoryImpl({required this.firestore, required this.auth});

  @override
  Future<Either<Failure, List<PatientEntity>>> getPatients() async {
    try {
      final user = auth.currentUser;
      if (user == null) {
        return const Left(ServerFailure('User not authenticated'));
      }

      final snapshot = await firestore
          .collection('patients')
          .where('id', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      final patients =
          snapshot.docs.map((doc) => PatientModel.fromSnapshot(doc)).toList();

      return Right(patients);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> addPatient(PatientEntity patient) async {
    try {
      final user = auth.currentUser;
      if (user == null) {
        return const Left(ServerFailure('User not authenticated'));
      }

      final model = PatientModel.fromEntity(patient);
      final data = model.toDocument();
      data['id'] = user.uid;
      data['createdAt'] = FieldValue.serverTimestamp();

      await firestore.collection('patients').add(data);
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updatePatient(PatientEntity patient) async {
    try {
      final model = PatientModel.fromEntity(patient);
      await firestore
          .collection('patients')
          .doc(patient.id)
          .update(model.toDocument());
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deletePatient(String patientId) async {
    try {
      await firestore.collection('patients').doc(patientId).delete();
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getDropdownOptions(
      String document) async {
    try {
      final snapshot =
          await firestore.collection("dropdown_options").doc(document).get();

      if (!snapshot.exists) {
        return const Right([]);
      }

      final data = snapshot.data() as Map<String, dynamic>;
      return Right(data.values.whereType<String>().toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, List<String>>>> fetchPatientAntecedents(
      String patientId) async {
    try {
      final doc = await firestore.collection('patients').doc(patientId).get();
      if (!doc.exists) {
        return const Left(ServerFailure('Patient not found'));
      }

      final data = doc.data()?['antecedents'] as Map<String, dynamic>? ?? {};
      final Map<String, List<String>> result = data.map(
        (key, value) => MapEntry(key, List<String>.from(value)),
      );

      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> savePatientAntecedents(
      String patientId, Map<String, List<String>> categoryItems) async {
    try {
      await firestore.collection('patients').doc(patientId).update({
        'antecedents': categoryItems,
      });
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAntecedentsOptions(
      String document) async {
    try {
      final snapshot =
          await firestore.collection("antecedents").doc(document).get();
      if (!snapshot.exists) return const Right([]);

      final data = snapshot.data() as Map<String, dynamic>;
      return Right(data.values.whereType<String>().toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
