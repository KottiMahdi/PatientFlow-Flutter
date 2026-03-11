import 'package:flutter/material.dart';
import '../../../features/profile/presentation/providers/profile_provider.dart';

class ProfileDropDownBuilder {
  static Widget buildProfileDropDown(
    BuildContext context,
    ProfileProviderGlobal provider,
    String title,
    String? currentValue,
    Function(String?) onChanged,
    IconData icon,
    Future<List<String>> optionsFuture, {
    bool isRequired = false,
    bool isValid = true,
    String? errorText,
    required Color primaryColor,
    bool isEditable = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Unified label row
          _buildLabelRow(context, icon, title, isRequired),

          // Styled dropdown container
          Container(
            decoration:
                _buildContainerDecoration(provider, primaryColor, isValid),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: _buildDropdownContent(
                context,
                provider,
                currentValue,
                onChanged,
                title,
                optionsFuture,
                isEditable,
              ),
            ),
          ),

          // Error message (if needed)
          if ((provider.isEditing && isEditable) &&
              !isValid &&
              errorText != null)
            _buildErrorText(errorText),
        ],
      ),
    );
  }

  static Widget _buildLabelRow(
      BuildContext context, IconData icon, String title, bool isRequired) {
    return Padding(
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
    );
  }

  static BoxDecoration _buildContainerDecoration(
    ProfileProviderGlobal provider,
    Color primaryColor,
    bool isValid,
  ) {
    return BoxDecoration(
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
    );
  }

  static Widget _buildDropdownContent(
    BuildContext context,
    ProfileProviderGlobal provider,
    String? currentValue,
    Function(String?) onChanged,
    String title,
    Future<List<String>> optionsFuture,
    bool isEditable,
  ) {
    if (provider.isEditing && isEditable) {
      return FutureBuilder<List<String>>(
        future: optionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          List<String> options = snapshot.data ?? [];
          if (options.isEmpty) {
            options = ["Not specified"];
          }

          // Ensure current value exists in options list
          if (currentValue != null && !options.contains(currentValue)) {
            // Add the current value to options if it doesn't exist
            options.add(currentValue);
          }

          return _buildDropdownButton(
            context,
            currentValue,
            onChanged,
            title,
            options,
          );
        },
      );
    }
    return _buildDisplayText(currentValue);
  }

  static Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  static Widget _buildErrorState(String error) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        'Error: $error',
        style: TextStyle(color: Colors.red[400], fontSize: 14),
      ),
    );
  }

  static Widget _buildDropdownButton(
    BuildContext context,
    String? currentValue,
    Function(String?) onChanged,
    String title,
    List<String> options,
  ) {
    // Ensure no duplicate values in the dropdown items
    final uniqueOptions = options.toSet().toList();

    return DropdownButton<String>(
      value: currentValue,
      hint: Text(
        'Select ${title.toLowerCase()}',
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 16,
        ),
      ),
      isExpanded: true,
      underline: Container(),
      icon: Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
      items: uniqueOptions
          .map((value) => DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  static Widget _buildDisplayText(String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Text(
        value?.isNotEmpty == true ? value! : 'Not specified',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  static Widget _buildErrorText(String errorText) {
    return Padding(
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
    );
  }
}
