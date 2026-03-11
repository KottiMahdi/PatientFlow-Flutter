import 'package:dartz/dartz.dart';

import 'package:management_cabinet_medical_mobile/core/error/failures.dart';
import 'package:management_cabinet_medical_mobile/core/usecases/usecase.dart';
import 'package:management_cabinet_medical_mobile/features/patient/domain/entities/patient.dart';
import 'package:management_cabinet_medical_mobile/features/patient/domain/repositories/patient_repository.dart';

class UpdatePatient implements UseCase<bool, PatientEntity> {
  final PatientRepository repository;

  UpdatePatient(this.repository);

  @override
  Future<Either<Failure, bool>> call(PatientEntity patient) async {
    return await repository.updatePatient(patient);
  }
}
