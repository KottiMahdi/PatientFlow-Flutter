import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/patient_provider.dart';

void deletePatient(BuildContext context, QueryDocumentSnapshot patientData) {
  // Explicitly cast the data to a map
  final Map<String, dynamic> data = patientData.data() as Map<String, dynamic>;
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
            'Are you sure you want to delete ${data['name']} ${data['prenom']}?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.black87),),
          ),
          ElevatedButton(
            onPressed: () async{
              Navigator.pop(context); // Close the dialog
              // Use provider to delete the patient
              await Provider.of<PatientProviderGlobal>(context, listen: false)
                  .deletePatient(patientData.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white),),
          ),
        ],
      );
    },
  );
}
