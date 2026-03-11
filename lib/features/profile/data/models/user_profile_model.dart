import 'package:management_cabinet_medical_mobile/features/profile/domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.uid,
    required super.fullName,
    required super.email,
    required super.phone,
    required super.specialization,
    required super.bio,
    super.profileImageUrl,
  });

  factory UserProfileModel.fromFirestore(
      Map<String, dynamic> data, String uid) {
    return UserProfileModel(
      uid: uid,
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      specialization: data['specialization'] ?? '',
      bio: data['bio'] ?? '',
      profileImageUrl: data['profileImageUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'specialization': specialization,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
    };
  }
}
