import 'package:dartz/dartz.dart';
import 'dart:io';

import 'package:management_cabinet_medical_mobile/core/error/failures.dart';
import 'package:management_cabinet_medical_mobile/features/profile/domain/entities/user_profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfile>> getProfile(String uid);
  Future<Either<Failure, void>> updateProfile(UserProfile profile, File? image);
  Future<Either<Failure, List<String>>> getSpecializationOptions();
}
