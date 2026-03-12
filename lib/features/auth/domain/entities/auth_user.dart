class AuthUser {
  final String uid;
  final String? email;
  final bool emailVerified;

  const AuthUser({
    required this.uid,
    this.email,
    required this.emailVerified,
  });
}
