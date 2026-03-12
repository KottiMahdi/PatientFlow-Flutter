import 'dart:io';
import 'package:flutter/material.dart';
import 'package:management_cabinet_medical_mobile/features/profile/domain/entities/user_profile.dart';
import 'package:management_cabinet_medical_mobile/features/profile/domain/usecases/get_profile.dart';
import 'package:management_cabinet_medical_mobile/features/profile/domain/usecases/update_profile.dart';
import 'package:management_cabinet_medical_mobile/features/profile/domain/usecases/get_specialization_options.dart';
import 'package:management_cabinet_medical_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:management_cabinet_medical_mobile/core/usecases/usecase.dart';

class ProfileState {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController bioController;
  final String? selectedSpecialization;
  final bool isEditing;
  final bool isSaving;
  final bool hasChanges;
  final bool isLoading;
  final File? profileImage;
  final Map<String, dynamic> originalValues;

  ProfileState({
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.bioController,
    this.selectedSpecialization,
    this.isEditing = false,
    this.isSaving = false,
    this.hasChanges = false,
    this.isLoading = true,
    this.profileImage,
    this.originalValues = const {},
  });

  ProfileState copyWith({
    bool? isEditing,
    bool? isSaving,
    bool? hasChanges,
    bool? isLoading,
    File? profileImage,
    Map<String, dynamic>? originalValues,
    String? selectedSpecialization,
  }) {
    return ProfileState(
      nameController: nameController,
      emailController: emailController,
      phoneController: phoneController,
      bioController: bioController,
      isEditing: isEditing ?? this.isEditing,
      isSaving: isSaving ?? this.isSaving,
      hasChanges: hasChanges ?? this.hasChanges,
      isLoading: isLoading ?? this.isLoading,
      profileImage: profileImage ?? this.profileImage,
      originalValues: originalValues ?? this.originalValues,
      selectedSpecialization:
          selectedSpecialization ?? this.selectedSpecialization,
    );
  }
}

class ProfileProviderGlobal extends ChangeNotifier {
  final GetProfile getProfileUseCase;
  final UpdateProfile updateProfileUseCase;
  final GetSpecializationOptions getSpecializationOptionsUseCase;
  final AuthProviderGlobal authProvider;

  ProfileState _state;

  ProfileProviderGlobal({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.getSpecializationOptionsUseCase,
    required this.authProvider,
  }) : _state = ProfileState(
          nameController: TextEditingController(),
          emailController: TextEditingController(),
          phoneController: TextEditingController(),
          bioController: TextEditingController(),
        ) {
    _init();
  }

  // Getters
  ProfileState get state => _state;
  TextEditingController get nameController => _state.nameController;
  TextEditingController get emailController => _state.emailController;
  TextEditingController get phoneController => _state.phoneController;
  TextEditingController get bioController => _state.bioController;
  String? get selectedSpecialization => _state.selectedSpecialization;
  bool get isEditing => _state.isEditing;
  bool get isSaving => _state.isSaving;
  bool get hasChanges => _state.hasChanges;
  bool get isLoading => _state.isLoading;
  File? get profileImage => _state.profileImage;
  Map<String, dynamic> get originalValues => _state.originalValues;

  void _init() {
    nameController.addListener(_checkForChanges);
    emailController.addListener(_checkForChanges);
    phoneController.addListener(_checkForChanges);
    bioController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    if (!_state.isEditing) return;

    bool changed = nameController.text != _state.originalValues['name'] ||
        emailController.text != _state.originalValues['email'] ||
        phoneController.text != _state.originalValues['phone'] ||
        selectedSpecialization != _state.originalValues['specialization'] ||
        bioController.text != _state.originalValues['bio'] ||
        _state.profileImage != null;

    if (changed != _state.hasChanges) {
      _state = _state.copyWith(hasChanges: changed);
      notifyListeners();
    }
  }

  void updateSpecialization(String? newSpecialization) {
    _state = _state.copyWith(selectedSpecialization: newSpecialization);
    _checkForChanges();
    notifyListeners();
  }

  Future<void> loadUserData(BuildContext context) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    final userId = authProvider.user?.uid;
    if (userId == null) {
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
      return;
    }

    final result = await getProfileUseCase(userId);

    result.fold(
      (failure) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to load profile: ${failure.message}')),
          );
        }
      },
      (profile) {
        nameController.text = profile.fullName;
        emailController.text = profile.email;
        phoneController.text = profile.phone;
        bioController.text = profile.bio;
        _state = _state.copyWith(
          selectedSpecialization: profile.specialization,
          originalValues: {
            'name': profile.fullName,
            'email': profile.email,
            'phone': profile.phone,
            'specialization': profile.specialization,
            'bio': profile.bio,
            'profileImageUrl': profile.profileImageUrl,
          },
        );
      },
    );

    _state = _state.copyWith(isLoading: false);
    notifyListeners();
  }

  void toggleEditMode(BuildContext context) {
    if (_state.isEditing && _state.hasChanges) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard Changes?'),
          content: const Text(
              'You have unsaved changes. Are you sure you want to discard them?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetToOriginal();
                _state = _state.copyWith(isEditing: false, hasChanges: false);
                notifyListeners();
              },
              child: const Text('Discard'),
            ),
          ],
        ),
      );
    } else {
      _state = _state.copyWith(isEditing: !_state.isEditing);
      notifyListeners();
    }
  }

  void _resetToOriginal() {
    nameController.text = _state.originalValues['name'] ?? '';
    emailController.text = _state.originalValues['email'] ?? '';
    phoneController.text = _state.originalValues['phone'] ?? '';
    bioController.text = _state.originalValues['bio'] ?? '';
    _state = _state.copyWith(
      selectedSpecialization: _state.originalValues['specialization'],
      profileImage: null,
    );
  }

  Future<void> saveChanges(BuildContext context) async {
    if (!_state.hasChanges) return;

    _state = _state.copyWith(isSaving: true);
    notifyListeners();

    final userId = authProvider.user?.uid;
    if (userId == null) return;

    final profile = UserProfile(
      uid: userId,
      fullName: nameController.text,
      email: emailController.text,
      phone: phoneController.text,
      specialization: selectedSpecialization ?? '',
      bio: bioController.text,
    );

    final result = await updateProfileUseCase(
      UpdateProfileParams(profile: profile, image: _state.profileImage),
    );

    result.fold(
      (failure) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to update profile: ${failure.message}')),
          );
        }
      },
      (_) {
        _state = _state.copyWith(
          originalValues: {
            'name': nameController.text,
            'email': emailController.text,
            'phone': phoneController.text,
            'specialization': selectedSpecialization,
            'bio': bioController.text,
          },
          hasChanges: false,
          isEditing: false,
          profileImage: null,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        }
      },
    );

    _state = _state.copyWith(isSaving: false);
    notifyListeners();
  }

  void setProfileImage(File image) {
    _state = _state.copyWith(profileImage: image, hasChanges: true);
    notifyListeners();
  }

  Future<List<String>> getDropdownOptions(String document) async {
    // For now we only support 'specialization' via the use case
    if (document == 'specialization') {
      final result = await getSpecializationOptionsUseCase(NoParams());
      return result.fold((_) => ['Not specified'], (options) => options);
    }
    return ['Not specified'];
  }

  Future<void> logout(BuildContext context) async {
    await authProvider.logout();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil("login", (route) => false);
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    _state = _state.copyWith(isSaving: true);
    notifyListeners();

    final success = await authProvider.deleteUserAccount();

    _state = _state.copyWith(isSaving: false);
    notifyListeners();

    if (success) {
      if (context.mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('login', (route) => false);
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error deleting account: ${authProvider.error}')),
        );
      }
    }
  }

  bool validateEmail(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  bool validatePhone(String phone) {
    return phone.length >= 10;
  }

  bool get isFormValid {
    bool isEmailValid = validateEmail(emailController.text);
    bool isPhoneValid = validatePhone(phoneController.text);
    return isEmailValid &&
        isPhoneValid &&
        nameController.text.isNotEmpty &&
        selectedSpecialization != null;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    bioController.dispose();
    super.dispose();
  }
}
