import 'package:dartz/dartz.dart';

import 'package:management_cabinet_medical_mobile/core/error/failures.dart';
import 'package:management_cabinet_medical_mobile/core/usecases/usecase.dart';
import 'package:management_cabinet_medical_mobile/features/patient/domain/entities/patient.dart';
import 'package:management_cabinet_medical_mobile/features/patient/domain/repositories/patient_repository.dart';

class GetPatients implements UseCase<List<PatientEntity>, NoParams> {
  final PatientRepository repository;

  GetPatients(this.repository);

  @override
  Future<Either<Failure, List<PatientEntity>>> call(NoParams params) async {
    return await repository.getPatients();
  }
}
