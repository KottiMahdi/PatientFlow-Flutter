import 'package:flutter/foundation.dart';
import '../../domain/entities/auth_user.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_up.dart';
import '../../domain/usecases/forgot_password.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/delete_account.dart';

class AuthProviderGlobal with ChangeNotifier {
  final SignInWithEmail signInWithEmail;
  final SignInWithGoogle signInWithGoogle;
  final SignUp signUp;
  final ForgotPassword forgotPassword;
  final SignOut signOut;
  final DeleteAccount deleteAccount;

  bool _isLoading = false;
  String _error = '';

  bool get isLoading => _isLoading;
  String get error => _error;
  AuthUser? get user => signInWithEmail.repository.currentUser;

  AuthProviderGlobal({
    required this.signInWithEmail,
    required this.signInWithGoogle,
    required this.signUp,
    required this.forgotPassword,
    required this.signOut,
    required this.deleteAccount,
  });

  Future<bool> deleteUserAccount() async {
    _setLoading(true);
    _error = '';

    final result = await deleteAccount(NoParams());

    return result.fold(
      (failure) {
        _error = failure.message;
        _setLoading(false);
        return false;
      },
      (_) {
        _setLoading(false);
        return true;
      },
    );
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _error = '';

    final result =
        await signInWithEmail(SignInParams(email: email, password: password));

    return result.fold(
      (failure) {
        _error = failure.message;
        _setLoading(false);
        return false;
      },
      (_) {
        _setLoading(false);
        return true;
      },
    );
  }

  Future<bool> loginWithGoogle() async {
    _setLoading(true);
    _error = '';

    final result = await signInWithGoogle(NoParams());

    return result.fold(
      (failure) {
        _error = failure.message;
        _setLoading(false);
        return false;
      },
      (_) {
        _setLoading(false);
        return true;
      },
    );
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String specialization,
  }) async {
    _setLoading(true);
    _error = '';

    final result = await signUp(SignUpParams(
      fullName: fullName,
      email: email,
      phone: phone,
      password: password,
      specialization: specialization,
    ));

    return result.fold(
      (failure) {
        _error = failure.message;
        _setLoading(false);
        return false;
      },
      (_) {
        _setLoading(false);
        return true;
      },
    );
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _error = '';

    final result = await forgotPassword(email);

    return result.fold(
      (failure) {
        _error = failure.message;
        _setLoading(false);
        return false;
      },
      (_) {
        _setLoading(false);
        return true;
      },
    );
  }

  Future<void> logout() async {
    await signOut(NoParams());
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
