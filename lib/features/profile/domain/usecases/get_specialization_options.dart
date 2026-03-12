import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

class GetSpecializationOptions implements UseCase<List<String>, NoParams> {
  final ProfileRepository repository;

  GetSpecializationOptions(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(NoParams params) async {
    return await repository.getSpecializationOptions();
  }
}
