import 'package:dartz/dartz.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:management_cabinet_medical_mobile/core/error/failures.dart';
import 'package:management_cabinet_medical_mobile/features/profile/domain/entities/user_profile.dart';
import 'package:management_cabinet_medical_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:management_cabinet_medical_mobile/features/profile/data/models/user_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  ProfileRepositoryImpl({
    required this.firestore,
    required this.storage,
  });

  @override
  Future<Either<Failure, UserProfile>> getProfile(String uid) async {
    try {
      final doc = await firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return Right(UserProfileModel.fromFirestore(doc.data()!, doc.id));
      } else {
        return const Left(ServerFailure());
      }
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile(
      UserProfile profile, File? image) async {
    try {
      final model = UserProfileModel(
        uid: profile.uid,
        fullName: profile.fullName,
        email: profile.email,
        phone: profile.phone,
        specialization: profile.specialization,
        bio: profile.bio,
        profileImageUrl: profile.profileImageUrl,
      );

      Map<String, dynamic> updateData = model.toFirestore();
      updateData['updatedAt'] = FieldValue.serverTimestamp();

      if (image != null) {
        final storageRef =
            storage.ref().child('profile_images').child('${profile.uid}.jpg');

        final uploadTask = storageRef.putFile(
          image,
          SettableMetadata(contentType: 'image/jpeg'),
        );

        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();
        updateData['profileImageUrl'] = downloadUrl;
      }

      await firestore.collection('users').doc(profile.uid).update(updateData);
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<String>>> getSpecializationOptions() async {
    try {
      final doc = await firestore
          .collection("dropdown_options")
          .doc("specialization")
          .get();

      if (!doc.exists) {
        return const Right(["Not specified"]);
      }

      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      List<String> options = data.values.whereType<String>().toList();

      if (options.isEmpty) {
        options.add("Not specified");
      }

      return Right(options);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }
}
