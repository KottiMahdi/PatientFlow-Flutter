import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class SignUp implements UseCase<void, SignUpParams> {
  final AuthRepository repository;

  SignUp(this.repository);

  @override
  Future<Either<Failure, void>> call(SignUpParams params) async {
    return await repository.signUp(
      fullName: params.fullName,
      email: params.email,
      phone: params.phone,
      password: params.password,
      specialization: params.specialization,
    );
  }
}

class SignUpParams {
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String specialization;

  SignUpParams({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.specialization,
  });
}
