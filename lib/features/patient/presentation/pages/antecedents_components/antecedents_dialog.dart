import 'package:flutter/material.dart';

class AntecedentsDialog {
  // Show a dialog to add an item to a category
  static Future<void> showAddItemDialog({
    required BuildContext context,
    required String category,
    required Color Function(String) getCategoryColor,
    required Color Function(String) getCategoryDarkColor,
    required IconData Function(String) getCategoryIcon,
    required Future<List<String>> Function(String) getAntecedentsOptions,
    required String Function(String) getDocumentKey,
    required Map<String, List<String>> categoryItems,
    required Function() savePatientAntecedents,
    required Function() onItemAdded,
  }) async {
    String? selectedItem; // Variable to hold the selected dropdown value

    // Fetch dropdown options from Firestore when the dialog is opened
    final documentKey = getDocumentKey(category);
    final dropdownOptions = await getAntecedentsOptions(documentKey);
    if (!context.mounted) {
      return;
    }

    // Display the dialog
    await showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        elevation: 24,
        title: Column(
          children: [
            Icon(
              getCategoryIcon(category),
              size: 36,
              color: getCategoryColor(category),
            ),
            const SizedBox(height: 10),
            Text(
              "Ajouter à $category",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2A79B0),
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: getCategoryColor(category),
            width: 2,
          ),
        ),
        content: StatefulBuilder(builder: (context, setState) {
          return SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Veuillez sélectionner un élément à ajouter",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down_circle, color: getCategoryColor(category)),
                  hint: const Text("Sélectionner un élément"),
                  items: dropdownOptions.map((option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedItem = value;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: getCategoryColor(category), width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: getCategoryColor(category).withValues(alpha: 0.5), width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: getCategoryColor(category), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              "Annuler",
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedItem != null) {
                // Update the categoryItems map
                categoryItems[category]!.add(selectedItem!);
                // Save antecedents to Firestore
                savePatientAntecedents();
                // Call the callback to refresh the parent widget
                onItemAdded();
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: getCategoryDarkColor(category),
              foregroundColor: Colors.white,
              elevation: 3,
              shadowColor: getCategoryColor(category).withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, size: 18),
                SizedBox(width: 8),
                Text(
                  "Ajouter",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
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
