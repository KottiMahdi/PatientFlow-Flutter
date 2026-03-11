import 'package:dartz/dartz.dart';
import 'dart:io';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class UpdateProfile implements UseCase<void, UpdateProfileParams> {
  final ProfileRepository repository;

  UpdateProfile(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateProfileParams params) async {
    return await repository.updateProfile(params.profile, params.image);
  }
}

class UpdateProfileParams {
  final UserProfile profile;
  final File? image;

  UpdateProfileParams({required this.profile, this.image});
}
