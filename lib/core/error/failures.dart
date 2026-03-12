abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server Error']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network Error']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache Error']);
}

class AuthFailure extends Failure {
  const AuthFailure({required String message}) : super(message);
}
