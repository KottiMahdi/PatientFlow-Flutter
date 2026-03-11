import 'package:dartz/dartz.dart';

import 'package:management_cabinet_medical_mobile/core/error/failures.dart';
import 'package:management_cabinet_medical_mobile/core/usecases/usecase.dart';
import 'package:management_cabinet_medical_mobile/features/patient/domain/repositories/patient_repository.dart';

class FetchPatientAntecedents
    implements UseCase<Map<String, List<String>>, String> {
  final PatientRepository repository;

  FetchPatientAntecedents(this.repository);

  @override
  Future<Either<Failure, Map<String, List<String>>>> call(
      String patientId) async {
    return await repository.fetchPatientAntecedents(patientId);
  }
}
