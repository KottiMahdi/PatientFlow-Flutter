import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_user.dart';

abstract class AuthRepository {
  AuthUser? get currentUser;
  Future<Either<Failure, void>> signInWithEmail(String email, String password);
  Future<Either<Failure, void>> signInWithGoogle();
  Future<Either<Failure, void>> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String specialization,
  });
  Future<Either<Failure, void>> forgotPassword(String email);
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, void>> deleteAccount();
}
