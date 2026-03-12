import 'package:dartz/dartz.dart';

import 'package:management_cabinet_medical_mobile/core/error/failures.dart';
import 'package:management_cabinet_medical_mobile/core/usecases/usecase.dart';
import 'package:management_cabinet_medical_mobile/features/profile/domain/entities/user_profile.dart';
import 'package:management_cabinet_medical_mobile/features/profile/domain/repositories/profile_repository.dart';

class GetProfile implements UseCase<UserProfile, String> {
  final ProfileRepository repository;

  GetProfile(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(String uid) async {
    return await repository.getProfile(uid);
  }
}
