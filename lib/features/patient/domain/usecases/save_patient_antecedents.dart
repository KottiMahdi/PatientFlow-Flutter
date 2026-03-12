import 'package:dartz/dartz.dart';

import 'package:management_cabinet_medical_mobile/core/error/failures.dart';
import 'package:management_cabinet_medical_mobile/core/usecases/usecase.dart';
import 'package:management_cabinet_medical_mobile/features/patient/domain/repositories/patient_repository.dart';

class SavePatientAntecedentsParams {
  final String patientId;
  final Map<String, List<String>> categoryItems;

  SavePatientAntecedentsParams(
      {required this.patientId, required this.categoryItems});
}

class SavePatientAntecedents
    implements UseCase<bool, SavePatientAntecedentsParams> {
  final PatientRepository repository;

  SavePatientAntecedents(this.repository);

  @override
  Future<Either<Failure, bool>> call(
      SavePatientAntecedentsParams params) async {
    return await repository.savePatientAntecedents(
        params.patientId, params.categoryItems);
  }
}
