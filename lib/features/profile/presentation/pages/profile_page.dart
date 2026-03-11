import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';
import 'components/drop_down_specialization.dart';
import 'components/logout_dialog_utils.dart';
import 'components/profile_field.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Load data when widget initializes
    final provider = Provider.of<ProfileProviderGlobal>(context, listen: false);
    provider.loadUserData(context);
  }

// Function to show delete account confirmation dialog
  void showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Account',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          content: const Text(
            'Are you sure you want to permanently delete your account? This action cannot be undone.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[800]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Get the provider and call the delete account method
                final provider =
                    Provider.of<ProfileProviderGlobal>(context, listen: false);
                provider.deleteAccount(context);
                // Sign out from Google account and disconnect to clear the account selection
                GoogleSignIn googleSignIn = GoogleSignIn();
                googleSignIn.disconnect();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('login', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProviderGlobal>(
      builder: (context, provider, _) {
        final theme = Theme.of(context);
        final primaryColor = theme.primaryColor;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            elevation: 0,
            backgroundColor: const Color(0xFF1E3A8A),
            title: const Text(
              'Profile',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            leading: provider.isEditing
                ? IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => provider.toggleEditMode(context),
                    tooltip: 'Cancel',
                  )
                : null,
            actions: [
              provider.isEditing
                  ? provider.isSaving
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(primaryColor),
                            ),
                          ),
                        )
                      : TextButton.icon(
                          onPressed: () {
                            if (provider.isFormValid && provider.hasChanges) {
                              provider.saveChanges(context);
                            }
                          },
                          icon: const Icon(Icons.check),
                          label: const Text('Save'),
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1E3A8A)),
                        )
                  : IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () => provider.toggleEditMode(context),
                      tooltip: 'Edit Profile',
                    ),
            ],
          ),
          body: provider.isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: primaryColor),
                      const SizedBox(height: 16),
                      Text(
                        'Loading profile...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white, Colors.grey[100]!],
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Top profile section
                        Container(
                          margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                          padding: const EdgeInsets.symmetric(
                              vertical: 24, horizontal: 99),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.08),
                                spreadRadius: 0,
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Modern styled name display
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  provider.nameController.text,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.5,
                                    color: Color(
                                        0xFF1E3A8A), // Using your brand blue color
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Display specialization with modern styling
                              if (provider.selectedSpecialization != null &&
                                  provider.selectedSpecialization!.isNotEmpty)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                        0xFFEEF2FF), // Light blue background
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    provider.selectedSpecialization!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(
                                          0xFF1E3A8A), // Matching blue for text
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Profile details card
                        Container(
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.1),
                                spreadRadius: 0,
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Section title
                                Row(
                                  children: [
                                    Icon(Icons.person_outline,
                                        color: primaryColor),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Personal Information',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Profile fields
                                ProfileFieldBuilder.buildProfileField(
                                  context,
                                  provider,
                                  'Full Name',
                                  provider.nameController,
                                  Icons.person,
                                  isRequired: true,
                                  isValid:
                                      provider.nameController.text.isNotEmpty,
                                  errorText: 'Name is required',
                                  primaryColor: primaryColor,
                                ),
                                ProfileFieldBuilder.buildProfileField(
                                  context,
                                  provider,
                                  'Email Address',
                                  provider.emailController,
                                  Icons.email,
                                  isRequired: true,
                                  isValid: provider.validateEmail(
                                      provider.emailController.text),
                                  errorText: 'Enter a valid email address',
                                  keyboardType: TextInputType.emailAddress,
                                  primaryColor: primaryColor,
                                  isEditable: false,
                                ),
                                ProfileFieldBuilder.buildProfileField(
                                  context,
                                  provider,
                                  'Phone Number',
                                  provider.phoneController,
                                  Icons.phone,
                                  isRequired: true,
                                  isValid: provider.validatePhone(
                                      provider.phoneController.text),
                                  errorText: 'Enter a valid phone number',
                                  keyboardType: TextInputType.phone,
                                  primaryColor: primaryColor,
                                ),

                                ProfileDropDownBuilder.buildProfileDropDown(
                                  context,
                                  provider,
                                  "Specialization",
                                  provider.selectedSpecialization,
                                  (value) =>
                                      provider.updateSpecialization(value),
                                  Icons.medical_services,
                                  provider.getDropdownOptions(
                                      'specialization'), // Ensure correct document ID
                                  isRequired: true,
                                  primaryColor: Theme.of(context).primaryColor,
                                ),

                                ProfileFieldBuilder.buildProfileField(
                                  context,
                                  provider,
                                  'Professional Bio',
                                  provider.bioController,
                                  Icons.info_outline,
                                  isMultiline: true,
                                  primaryColor: primaryColor,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Account Management Section
                        Container(
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.1),
                                spreadRadius: 0,
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section title
                              Row(
                                children: [
                                  Icon(Icons.security_outlined,
                                      color: primaryColor),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Account Management',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Logout button
                              Container(
                                width: double.infinity,
                                height: 56,
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                      LogoutDialogUtils.showLogoutDialog(
                                          context),
                                  icon: const Icon(Icons.logout),
                                  label: const Text(
                                    'Log Out',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[200],
                                    foregroundColor: Colors.red[700],
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                              // Delete Account button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                      showDeleteAccountDialog(context),
                                  icon: const Icon(Icons.delete_forever),
                                  label: const Text(
                                    'Delete Account',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red[400],
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
