import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:management_cabinet_medical_mobile/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:management_cabinet_medical_mobile/features/auth/domain/entities/auth_user.dart';
import 'package:management_cabinet_medical_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:management_cabinet_medical_mobile/core/error/failures.dart';

class FakeAuthRepository implements AuthRepository {
  Future<Either<Failure, void>> Function(String, String)? signInHandler;

  @override
  AuthUser? get currentUser => null;

  @override
  Future<Either<Failure, void>> signInWithEmail(
      String email, String password) async {
    if (signInHandler != null) return await signInHandler!(email, password);
    return const Left(ServerFailure('not implemented'));
  }

  @override
  Future<Either<Failure, void>> signInWithGoogle() async =>
      const Left(ServerFailure('not implemented'));

  @override
  Future<Either<Failure, void>> signUp(
          {required String fullName,
          required String email,
          required String phone,
          required String password,
          required String specialization}) async =>
      const Left(ServerFailure('not implemented'));

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async =>
      const Left(ServerFailure('not implemented'));

  @override
  Future<Either<Failure, void>> signOut() async =>
      const Left(ServerFailure('not implemented'));

  @override
  Future<Either<Failure, void>> deleteAccount() async =>
      const Left(ServerFailure('not implemented'));
}

void main() {
  late SignInWithEmail usecase;
  late FakeAuthRepository fakeRepo;

  setUp(() {
    fakeRepo = FakeAuthRepository();
    usecase = SignInWithEmail(fakeRepo);
  });

  test('returns Right when repository signs in successfully', () async {
    fakeRepo.signInHandler = (_, __) async => const Right(null);

    final result =
        await usecase.call(SignInParams(email: 'a@a.com', password: 'pass'));
    expect(result.isRight(), true);
  });

  test('returns Left when repository fails', () async {
    fakeRepo.signInHandler = (_, __) async => const Left(ServerFailure('error'));

    final result =
        await usecase.call(SignInParams(email: 'a@a.com', password: 'bad'));
    expect(result.isLeft(), true);
  });
}
