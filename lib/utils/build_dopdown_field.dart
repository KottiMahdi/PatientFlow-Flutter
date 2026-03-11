import 'package:flutter/material.dart';



Widget buildDropdownField(
    BuildContext context,
    String label,
    String document,
    String? value,
    IconData icon,
    Function(String?) onChanged,
    Map<String, Future<List<String>>> dropdownCache,
    Future<List<String>> Function(String) getDropdownOptions) {
  // Fetch options from cache if available, otherwise load them
  dropdownCache.putIfAbsent(document, () => getDropdownOptions(document));

  return FutureBuilder<List<String>>(
    future: dropdownCache[document],
    builder: (context, snapshot) {
      // Show a loading spinner while waiting for data
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      // Display an error message if there was an issue loading the data
      if (snapshot.hasError) {
        return Text("Error loading $label options");
      }

      // Build the DropdownButtonFormField if data is successfully fetched
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: DropdownButtonFormField<String>(
          // Currently selected value for the dropdown
          initialValue: value,

          // Function to handle changes in selection
          onChanged: onChanged,

          // Create dropdown menu items from the fetched data
          items: snapshot.data!
              .map(
                (option) => DropdownMenuItem<String>(
              value: option,
              child: Text(
                option,
                // Prevent text overflow with ellipsis
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          )
              .toList(),

          // Styling for the dropdown
          decoration: InputDecoration(
            // Label for the dropdown field
            labelText: label,

            // Icon displayed inside the input field
            prefixIcon: Icon(icon, color: const Color(0xFF1E3A8A)),

            // Background color and padding for the input field
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16.0, // Vertical padding
              horizontal: 12.0, // Horizontal padding
            ),

            // Border styling for the input field
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), // Rounded corners
              borderSide: BorderSide.none, // No visible border
            ),
          ),

          // Dropdown-specific configurations
          isExpanded: true, // Expands dropdown to fit content width
          dropdownColor: Colors.white, // Background color of the dropdown
          icon: const Icon(Icons.arrow_drop_down,
              color: Color(0xFF1E3A8A)), // Updated dropdown icon,
          iconSize: 30, // Size of the dropdown icon
          elevation: 8, // Shadow depth for the dropdown
          style: const TextStyle(
              color: Colors.black), // Text style inside the dropdown
        ),
      );
    },
  );
}