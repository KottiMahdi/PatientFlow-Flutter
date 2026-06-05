import 'package:flutter_test/flutter_test.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:management_cabinet_medical_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:management_cabinet_medical_mobile/features/auth/domain/entities/auth_user.dart';
import 'package:management_cabinet_medical_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:management_cabinet_medical_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:management_cabinet_medical_mobile/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:management_cabinet_medical_mobile/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:management_cabinet_medical_mobile/features/auth/domain/usecases/sign_up.dart';
import 'package:management_cabinet_medical_mobile/features/auth/domain/usecases/forgot_password.dart';
import 'package:management_cabinet_medical_mobile/features/auth/domain/usecases/sign_out.dart';
import 'package:management_cabinet_medical_mobile/features/auth/domain/usecases/delete_account.dart';
import 'package:dartz/dartz.dart';
import 'package:management_cabinet_medical_mobile/core/error/failures.dart';

class FakeAuthRepository implements AuthRepository {
  final Future<Either<Failure, void>> Function(String, String)? signInHandler;

  FakeAuthRepository({this.signInHandler});

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
  testWidgets('shows loading when provider.isLoading', (tester) async {
    // Make signIn controllable so provider is in loading state during the test
    final completer = Completer<Either<Failure, void>>();
    final fakeRepo =
        FakeAuthRepository(signInHandler: (_, __) => completer.future);

    final signInEmail = SignInWithEmail(fakeRepo);
    final provider = AuthProviderGlobal(
      signInWithEmail: signInEmail,
      signInWithGoogle: SignInWithGoogle(fakeRepo),
      signUp: SignUp(fakeRepo),
      forgotPassword: ForgotPassword(fakeRepo),
      signOut: SignOut(fakeRepo),
      deleteAccount: DeleteAccount(fakeRepo),
    );

    // Start login and build UI while the future is pending
    Future.microtask(() => provider.login('a@a.com', 'pass'));

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProviderGlobal>.value(
        value: provider,
        child: const MaterialApp(home: MedicalLoginPage()),
      ),
    );

    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsWidgets);

    // complete the sign-in and settle the widget tree
    completer.complete(const Right(null));
    await tester.pumpAndSettle();
  });
}
