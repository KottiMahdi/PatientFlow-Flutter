import 'package:dartz/dartz.dart';

import 'package:management_cabinet_medical_mobile/core/error/failures.dart';
import 'package:management_cabinet_medical_mobile/features/patient/domain/entities/patient.dart';

abstract class PatientRepository {
  Future<Either<Failure, List<PatientEntity>>> getPatients();
  Future<Either<Failure, bool>> addPatient(PatientEntity patient);
  Future<Either<Failure, bool>> updatePatient(PatientEntity patient);
  Future<Either<Failure, bool>> deletePatient(String patientId);
  Future<Either<Failure, List<String>>> getDropdownOptions(String document);
  Future<Either<Failure, Map<String, List<String>>>> fetchPatientAntecedents(
      String patientId);
  Future<Either<Failure, bool>> savePatientAntecedents(
      String patientId, Map<String, List<String>> categoryItems);
  Future<Either<Failure, List<String>>> getAntecedentsOptions(String document);
}
