import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';

class ProfileImageWidget extends StatelessWidget {
  final double size;
  final bool isEditing;
  final VoidCallback onTap;

  const ProfileImageWidget({
    super.key,
    required this.size,
    required this.isEditing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileProviderGlobal>(context);
    final primaryColor = Theme.of(context).primaryColor;

    return Stack(
      children: [
        // Profile image container
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.2),
              width: 3,
            ),
          ),
          child: ClipOval(
            child: _buildProfileImage(provider, primaryColor),
          ),
        ),

        // Edit button overlay
        if (isEditing)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileImage(
      ProfileProviderGlobal provider, Color primaryColor) {
    // If we have a local file selected, use that
    if (provider.profileImage != null) {
      return Image.file(
        provider.profileImage!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(primaryColor);
        },
      );
    }

    // If we have a URL from Firestore, use that
    else if (provider.originalValues['profileImageUrl'] != null) {
      return Image.network(
        provider.originalValues['profileImageUrl'],
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(primaryColor);
        },
      );
    }

    // Otherwise show placeholder
    else {
      return _buildPlaceholder(primaryColor);
    }
  }

  Widget _buildPlaceholder(Color primaryColor) {
    return Icon(
      Icons.person,
      color: primaryColor.withValues(alpha: 0.8),
      size: size / 2,
    );
  }
}
