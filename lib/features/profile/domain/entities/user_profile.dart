class UserProfile {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String specialization;
  final String bio;
  final String? profileImageUrl;

  const UserProfile({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.specialization,
    required this.bio,
    this.profileImageUrl,
  });

  UserProfile copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? phone,
    String? specialization,
    String? bio,
    String? profileImageUrl,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      specialization: specialization ?? this.specialization,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
