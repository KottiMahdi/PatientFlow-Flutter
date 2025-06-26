import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/patient_model.dart';
import '../../providers/patient_provider.dart';
import '../../utils/build_Date_Field.dart';
import '../../utils/build_dopdown_field.dart';
import '../../utils/build_text_field.dart';

class AddPatientPage extends StatefulWidget {
  @override
  _AddPatientPageState createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the form fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController cinController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController codePostalController = TextEditingController();
  final TextEditingController numeroAssuranceController =
      TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();

  // Additional controllers
  final TextEditingController adresseController = TextEditingController();
  final TextEditingController villeController = TextEditingController();
  final TextEditingController telController = TextEditingController();
  final TextEditingController telWhatsAppController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dernierRdvController = TextEditingController();
  final TextEditingController prochainRdvController = TextEditingController();
  final TextEditingController paysController = TextEditingController();
  final TextEditingController adresseParController = TextEditingController();

  CollectionReference patients =
      FirebaseFirestore.instance.collection("patients");

  // Dropdown selected values
  String? selectedAssurance;
  String? selectedAssurant;
  String? selectedEtatCivil;
  String? selectedNationalite;
  String? selectedProfession;
  String? selectedRelation;
  String? selectedGroupSanguin;
  String? selectedGenre;

  addPatient() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Safely parse the text inputs into integers
        int? CIN = int.tryParse(cinController.text);
        int? codePostal = int.tryParse(codePostalController.text);
        int? numeroAssurance = int.tryParse(numeroAssuranceController.text);

        // Check if any of the parsed values are null (invalid input)
        if (CIN == null || codePostal == null || numeroAssurance == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    "Please enter valid numeric values for CIN, Code Postal, and Numero Assurance")),
          );
          return;
        }

        // Create a Patient object using the model
        Patient patient = Patient(
          id: '', // This will be assigned by Firestore
          name: nameController.text,
          prenom: prenomController.text,
          cin: cinController.text,
          age: ageController.text,
          dateNaiss: dateOfBirthController.text,
          codePostal: codePostalController.text,
          numeroAssurance: numeroAssuranceController.text,
          genre: selectedGenre,
          etatCivil: selectedEtatCivil,
          nationalite: selectedNationalite,
          adresse: adresseController.text,
          ville: villeController.text,
          tel: telController.text,
          telWhatsApp: telWhatsAppController.text,
          email: emailController.text,
          dernierRdv: dernierRdvController.text,
          prochainRdv: prochainRdvController.text,
          groupSanguin: selectedGroupSanguin,
          assurant: selectedAssurant,
          assurance: selectedAssurance,
          relation: selectedRelation,
          profession: selectedProfession,
          pays: paysController.text,
          adressePar: adresseParController.text,
          createdAt: DateTime.now(),
        );

        // Use the provider to add the patient
        final success =
            await Provider.of<PatientProviderGlobal>(context, listen: false)
                .addPatient(patient.toMap());

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Patient added successfully!"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error adding patient"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print("Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error adding patient: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<List<String>> getDropdownOptions(String document) {
    return Provider.of<PatientProviderGlobal>(context, listen: false)
        .getDropdownOptions(document);
  }

  @override
  void dispose() {
    // Dispose of all controllers to prevent memory leaks
    nameController.dispose();
    prenomController.dispose();
    cinController.dispose();
    ageController.dispose();
    codePostalController.dispose();
    numeroAssuranceController.dispose();
    dateOfBirthController.dispose();
    adresseController.dispose();
    villeController.dispose();
    telController.dispose();
    telWhatsAppController.dispose();
    emailController.dispose();
    dernierRdvController.dispose();
    prochainRdvController.dispose();
    paysController.dispose();
    adresseParController.dispose();
    super.dispose();
  }

  // Cache for dropdown data
  Map<String, Future<List<String>>> dropdownCache = {};

  @override
  void initState() {
    super.initState();
    // Preload dropdown options
    dropdownCache['etatCivil'] = getDropdownOptions('etatCivil');
    dropdownCache['nationalite'] = getDropdownOptions('nationalite');
    dropdownCache['assurant'] = getDropdownOptions('assurant');
    dropdownCache['assurance'] = getDropdownOptions('assurance');
    dropdownCache['relation'] = getDropdownOptions('relation');
    dropdownCache['profession'] = getDropdownOptions('profession');
    dropdownCache['groupSanguin'] = getDropdownOptions('groupSanguin');
    dropdownCache['genre'] = getDropdownOptions('genre');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Add Patient",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
        iconTheme: IconThemeData(
            color: Colors.white), // Change the back icon color to white
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 100.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Patient Information",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E3A8A),
                    ),
                  ),
                  SizedBox(height: 16.0),

                  // Input fields in a modern style
                  buildTextField(context, "First Name", nameController,
                      Icons.person, TextInputType.text),
                  buildTextField(context, "Last Name", prenomController,
                      Icons.person, TextInputType.text),
                  buildTextField(context, "CIN", cinController,
                      Icons.perm_identity, TextInputType.number),
                  buildTextField(context, "Age", ageController, Icons.cake,
                      TextInputType.text),
                  buildDateField(context, "Date of Birth",
                      dateOfBirthController, setState),
                  buildTextField(context, "Code Postale", codePostalController,
                      Icons.location_on, TextInputType.number),
                  buildTextField(
                      context,
                      "Insurance Number",
                      numeroAssuranceController,
                      Icons.policy,
                      TextInputType.number),

                  Divider(height: 32.0, thickness: 1),

                  // Additional fields with their respective controllers
                  buildDropdownField(
                      context,
                      "Genre",
                      "genre",
                      selectedGenre,
                      Icons.transgender,
                      (value) => setState(() => selectedGenre = value),
                      dropdownCache,
                      getDropdownOptions),
                  buildDropdownField(
                      context,
                      "Etat Civil",
                      "etatCivil",
                      selectedEtatCivil,
                      Icons.person,
                      (value) => setState(() => selectedEtatCivil = value),
                      dropdownCache,
                      getDropdownOptions),
                  buildDropdownField(
                      context,
                      "Nationalité",
                      "nationalite",
                      selectedNationalite,
                      Icons.flag,
                      (value) => setState(() => selectedNationalite = value),
                      dropdownCache,
                      getDropdownOptions),
                  buildTextField(context, "Adresse", adresseController,
                      Icons.home, TextInputType.streetAddress),
                  buildTextField(context, "Ville", villeController,
                      Icons.location_city, TextInputType.text),
                  buildTextField(context, "Tel", telController, Icons.phone,
                      TextInputType.text),
                  buildTextField(context, "Tel WhatsApp", telWhatsAppController,
                      Icons.phone_android, TextInputType.text),
                  buildTextField(context, "Email", emailController, Icons.email,
                      TextInputType.emailAddress),
                  buildDateField(
                      context, "Dernier RDV", dernierRdvController, setState),
                  buildDateField(
                      context, "Prochain RDV", prochainRdvController, setState),
                  buildDropdownField(
                      context,
                      "Group Sanguin",
                      "groupSanguin",
                      selectedGroupSanguin,
                      Icons.water_drop,
                      (value) => setState(() => selectedGroupSanguin = value),
                      dropdownCache,
                      getDropdownOptions),
                  buildDropdownField(
                      context,
                      "Assurant",
                      "assurant",
                      selectedAssurant,
                      Icons.verified_user,
                      (value) => setState(() => selectedAssurant = value),
                      dropdownCache,
                      getDropdownOptions),
                  buildDropdownField(
                      context,
                      "Assurance",
                      "assurance",
                      selectedAssurance,
                      Icons.shield,
                      (value) => setState(() => selectedAssurance = value),
                      dropdownCache,
                      getDropdownOptions),
                  buildDropdownField(
                      context,
                      "Relation",
                      "relation",
                      selectedRelation,
                      Icons.group,
                      (value) => setState(() => selectedRelation = value),
                      dropdownCache,
                      getDropdownOptions),
                  buildDropdownField(
                      context,
                      "Profession",
                      "profession",
                      selectedProfession,
                      Icons.work,
                      (value) => setState(() => selectedProfession = value),
                      dropdownCache,
                      getDropdownOptions),
                  buildTextField(context, "Pays", paysController, Icons.public,
                      TextInputType.text),
                  buildTextField(context, "Adresse par", adresseParController,
                      Icons.location_on, TextInputType.text),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 31, bottom: 45),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton.extended(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Save the data or perform an action
                  addPatient();
                }
              },
              label: Text("Save"),
              icon: Icon(Icons.save),
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
