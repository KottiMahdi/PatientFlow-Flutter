import 'package:dartz/dartz.dart';

import 'package:management_cabinet_medical_mobile/core/error/failures.dart';
import 'package:management_cabinet_medical_mobile/core/usecases/usecase.dart';
import 'package:management_cabinet_medical_mobile/features/patient/domain/repositories/patient_repository.dart';

class GetAntecedentsOptions implements UseCase<List<String>, String> {
  final PatientRepository repository;

  GetAntecedentsOptions(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(String document) async {
    return await repository.getAntecedentsOptions(document);
  }
}
