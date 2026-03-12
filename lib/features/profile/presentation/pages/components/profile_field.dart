import 'package:flutter/material.dart';
import 'package:management_cabinet_medical_mobile/features/profile/presentation/providers/profile_provider.dart';

class ProfileFieldBuilder {
  static Widget buildProfileField(
    BuildContext context,
    ProfileProviderGlobal provider,
    String title,
    TextEditingController controller,
    IconData icon, {
    bool isMultiline = false,
    bool isRequired = false,
    bool isValid = true,
    String? errorText,
    TextInputType? keyboardType,
    required Color primaryColor,
    bool isEditable = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Field label
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Row(
              children: [
                Icon(icon, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isRequired)
                  Text(
                    ' *',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),

          // Field content area
          Container(
            decoration: BoxDecoration(
              color: provider.isEditing ? Colors.grey[50] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: provider.isEditing
                    ? !isValid
                        ? Colors.red[400]!
                        : primaryColor.withValues(alpha: 0.3)
                    : Colors.grey[200]!,
                width: provider.isEditing ? 1.5 : 1,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: isMultiline ? 12 : 14,
              ),
              child: (provider.isEditing && isEditable)
                  ? TextField(
                      controller: controller,
                      decoration: InputDecoration.collapsed(
                        hintText: 'Enter ${title.toLowerCase()}',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                        ),
                      ),
                      maxLines: isMultiline ? null : 1,
                      minLines: isMultiline ? 3 : 1,
                      keyboardType: keyboardType,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    )
                  : Text(
                      controller.text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
            ),
          ),

          // Error message
          if ((provider.isEditing && isEditable) &&
              !isValid &&
              errorText != null)
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 6),
              child: Row(
                children: [
                  Icon(Icons.error_outline, size: 14, color: Colors.red[400]),
                  const SizedBox(width: 6),
                  Text(
                    errorText,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red[400],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
