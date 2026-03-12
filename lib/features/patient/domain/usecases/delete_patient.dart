import 'package:dartz/dartz.dart';

import 'package:management_cabinet_medical_mobile/core/error/failures.dart';
import 'package:management_cabinet_medical_mobile/core/usecases/usecase.dart';
import 'package:management_cabinet_medical_mobile/features/patient/domain/repositories/patient_repository.dart';

class DeletePatient implements UseCase<bool, String> {
  final PatientRepository repository;

  DeletePatient(this.repository);

  @override
  Future<Either<Failure, bool>> call(String patientId) async {
    return await repository.deletePatient(patientId);
  }
}
