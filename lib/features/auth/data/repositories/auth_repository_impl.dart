import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn;

  @override
  AuthUser? get currentUser {
    final user = firebaseAuth.currentUser;
    if (user == null) return null;
    return AuthUser(
      uid: user.uid,
      email: user.email,
      emailVerified: user.emailVerified,
    );
  }

  AuthRepositoryImpl({
    required this.firebaseAuth,
    required this.firestore,
    required this.googleSignIn,
  });

  @override
  Future<Either<Failure, void>> signInWithEmail(
      String email, String password) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null && !credential.user!.emailVerified) {
        return const Left(AuthFailure(message: 'Please verify your email first'));
      }

      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(message: _getErrorMessage(e)));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return const Left(AuthFailure(message: 'Google Sign In was canceled'));
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final userDoc = await firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          await _addUserToFirestore(user, 'google', 'Not specified yet');
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String specialization,
  }) async {
    try {
      await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = firebaseAuth.currentUser;
      if (user != null) {
        await _addUserToFirestore(
            user, 'Email Address/Password', specialization,
            fullName: fullName, phone: phone);
        await user.sendEmailVerification();
      }

      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(message: _getErrorMessage(e)));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(message: _getErrorMessage(e)));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await googleSignIn.signOut();
      await firebaseAuth.signOut();
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  Future<void> _addUserToFirestore(
      User user, String provider, String specialization,
      {String? fullName, String? phone}) async {
    await firestore.collection('users').doc(user.uid).set({
      'fullName': fullName ?? user.displayName ?? 'Medical User',
      'email': user.email ?? '',
      'phone': phone ?? user.phoneNumber ?? 'Not provided yet',
      'specialization': specialization,
      'bio': 'Not provided yet',
      'createdAt': FieldValue.serverTimestamp(),
      'authProvider': provider,
    });
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is badly formatted.';
      default:
        return e.message ?? 'An unexpected authentication error occurred.';
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user != null) {
        await firestore.collection('users').doc(user.uid).delete();
        await user.delete();
        return const Right(null);
      }
      return const Left(ServerFailure('No user currently signed in'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
