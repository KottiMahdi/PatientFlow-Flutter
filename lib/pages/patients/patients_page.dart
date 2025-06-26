import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:management_cabinet_medical_mobile/pages/patients/add_patient_page.dart';
import 'package:management_cabinet_medical_mobile/pages/patients/antecedents_page.dart';
import 'package:provider/provider.dart';
import '../../providers/patient_provider.dart';
import '../../utils/floating_button.dart';
import 'components/show_option_popup.dart';
import 'components/show_patient_details.dart';


// PatientsPage is a StatefulWidget that displays a list of patients
class PatientsPage extends StatefulWidget {
  @override
  _PatientsPageState createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  final TextEditingController searchController = TextEditingController(); // Controller for the search bar
  final FocusNode searchFocusNode = FocusNode(); // Focus node to manage the search bar focus state


  @override
  void initState() {
    super.initState();
    // Fetch patients when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PatientProviderGlobal>(context, listen: false).fetchPatients();
    });

    // Listen to changes in the search text field
    searchController.addListener(() {
      Provider.of<PatientProviderGlobal>(context, listen: false)
          .setSearchQuery(searchController.text);
    });

    // Listen to focus changes
    searchFocusNode.addListener(() {
      setState(() {});
    });
  }



  @override
  void dispose() {
    searchFocusNode.dispose(); // Dispose of the focus node when the widget is disposed
    searchController.dispose(); // Dispose of the text controller when the widget is disposed
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Patients List', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), // App bar title
        backgroundColor: const Color(0xFF1E3A8A), // App bar background color
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Dismiss the keyboard when tapping outside
        child: Column(
          children: [
            // Search Bar Widget
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Display a back button when the search field is focused
                  if (searchFocusNode.hasFocus)
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      color: Colors.black,
                      onPressed: () {
                        searchFocusNode.unfocus(); // Unfocus the search field
                        searchController.clear(); // Clear the search text
                        Provider.of<PatientProviderGlobal>(context, listen: false)
                            .setSearchQuery('');
                      },
                    ),
                  Expanded(
                    child: TextField(
                      controller: searchController, // Attach the text controller
                      focusNode: searchFocusNode, // Attach the focus node
                      decoration: InputDecoration(
                        hintText: 'Search', // Placeholder text
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(Icons.search), // Search icon
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                          icon: Icon(Icons.clear), // Clear icon
                          onPressed: () {
                            searchController.clear(); // Clear the search text
                            Provider.of<PatientProviderGlobal>(context, listen: false)
                                .setSearchQuery('');
                          },
                        )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none, // Remove border line
                        ),
                        filled: true,
                        fillColor: Colors.grey[200], // Background color of the text field
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Patient List Widget
            Expanded(
              child: Consumer<PatientProviderGlobal>(
                builder: (context, patientProvider, child) {
                  if (patientProvider.isLoading) {
                    return Center(
                      child: CircularProgressIndicator(color: Color(0xFF2A79B0)),
                    );
                  }

                  final patientsList = patientProvider.filteredPatients;

                  if (patientsList.isEmpty) {
                    return const Center(
                      child: Text(
                        'No Patients',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  }

                  // Display a list of patients
                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80.0),
                    itemCount: patientsList.length, // Number of patients to display
                    itemBuilder: (context, index) {
                      final patient = patientsList[index]; // Get patient data for this index
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 6.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0), // Rounded corners for cards
                          ),
                          child: ListTile(
                            leading: const Icon(
                                Icons.person,  color: Color(0xFF1E3A8A)), // Icon for the patient
                            title: Text(
                              '${patient.name} ${patient.prenom}', // Patient's name
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold), // Bold text for name
                            ),
                            subtitle: Text(
                                'Assurance: ${patient.assurance != null && patient.assurance!.isNotEmpty
                                    ? patient.assurance
                                    : 'N/A'} | Age: ${patient.age} '), // Patient's insurance and age
                            trailing: IconButton(
                              icon: const Icon(Icons.more_vert, color: const Color(0xFF1E3A8A)),
                              onPressed: () {
                                // Pass the patient data directly instead of fetching it again
                                FirebaseFirestore.instance
                                    .collection('patients')
                                    .where(FieldPath.documentId, isEqualTo: patient.id)
                                    .get()
                                    .then((snapshot) {
                                  if (snapshot.docs.isNotEmpty) {
                                    showPatientDetails(context, snapshot.docs.first);
                                  }
                                });
                              },
                            ),
                            onLongPress: () {
                              // Pass the patient data directly instead of fetching it again
                              FirebaseFirestore.instance
                                  .collection('patients')
                                  .where(FieldPath.documentId, isEqualTo: patient.id)
                                  .get()
                                  .then((snapshot) {
                                if (snapshot.docs.isNotEmpty) {
                                  showOptionsPopup(
                                      context,
                                      snapshot.docs.first,
                                          () => patientProvider?.fetchPatients()
                                  );
                                }
                              });
                            },
                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AntecedentsPage(patientId: patient.id),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // Floating action button to add a new patient
      floatingActionButton:FloatingButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPatientPage()), // Navigate to the AddPatientPage
          );
        },
        label: 'Add Patient',
        icon: Icons.add,
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
    );
  }

}
