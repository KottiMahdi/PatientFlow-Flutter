import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/patient_model.dart';
import '../../providers/patient_provider.dart';

class EditPatientPage extends StatefulWidget {
  final DocumentSnapshot patientData;

  EditPatientPage({required this.patientData});

  @override
  _EditPatientPageState createState() => _EditPatientPageState();
}

class _EditPatientPageState extends State<EditPatientPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the form fields
  late TextEditingController nameController;
  late TextEditingController prenomController;
  late TextEditingController cinController;
  late TextEditingController ageController;
  late TextEditingController codePostalController;
  late TextEditingController numeroAssuranceController;
  late TextEditingController dateOfBirthController;
  late TextEditingController adresseController;
  late TextEditingController villeController;
  late TextEditingController telController;
  late TextEditingController telWhatsAppController;
  late TextEditingController emailController;
  late TextEditingController dernierRdvController;
  late TextEditingController prochainRdvController;
  late TextEditingController paysController;
  late TextEditingController adresseParController;

  //A reference to the patients collection in Firestore where the data will be stored.
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

  @override
  void initState() {
    super.initState();
    // Initialize controllers with data from the provided patient snapshot
    initializeTextControllers();
    // Initialize dropdown selections from the provided patient snapshot
    initializeDropdownSelections();
    // Preload dropdown options if necessary
    preloadDropdownOptions();
  }

  // Initialize controllers with existing data
  void initializeTextControllers(){
    nameController = TextEditingController(text: widget.patientData["name"]);
    prenomController =
        TextEditingController(text: widget.patientData["prenom"]);
    cinController = TextEditingController(text: widget.patientData["CIN"]);
    ageController = TextEditingController(text: widget.patientData["age"]);
    codePostalController =
        TextEditingController(text: widget.patientData["codePostal"]);
    numeroAssuranceController =
        TextEditingController(text: widget.patientData["numeroAssurance"]);
    dateOfBirthController =
        TextEditingController(text: widget.patientData["dateNaiss"]);
    adresseController =
        TextEditingController(text: widget.patientData["adresse"]);
    villeController = TextEditingController(text: widget.patientData["ville"]);
    telController = TextEditingController(text: widget.patientData["tel"]);
    telWhatsAppController =
        TextEditingController(text: widget.patientData["telWhatsApp"]);
    emailController = TextEditingController(text: widget.patientData["email"]);
    dernierRdvController =
        TextEditingController(text: widget.patientData["Dernier RDV"]);
    prochainRdvController =
        TextEditingController(text: widget.patientData["Prochain RDV"]);
    paysController = TextEditingController(text: widget.patientData["pays"]);
    adresseParController =
        TextEditingController(text: widget.patientData["adressee"]);
  }
  // Initialize dropdown selected values with patient data
  void initializeDropdownSelections(){
    selectedEtatCivil = widget.patientData["etatCivil"];
    selectedNationalite = widget.patientData["nationalite"];
    selectedAssurant = widget.patientData["assurant"];
    selectedAssurance = widget.patientData["assurance"];
    selectedRelation = widget.patientData["relation"];
    selectedProfession = widget.patientData["profession"];
    selectedGroupSanguin = widget.patientData["groupSanguin"];
    selectedGenre = widget.patientData["genre"];
  }
  // Preload dropdown options and cache them for later use
  void preloadDropdownOptions(){
    dropdownCache['etatCivil'] = getDropdownOptions('etatCivil');
    dropdownCache['nationalite'] = getDropdownOptions('nationalite');
    dropdownCache['assurant'] = getDropdownOptions('assurant');
    dropdownCache['assurance'] = getDropdownOptions('assurance');
    dropdownCache['relation'] = getDropdownOptions('relation');
    dropdownCache['profession'] = getDropdownOptions('profession');
    dropdownCache['groupSanguin'] = getDropdownOptions('groupSanguin');
    dropdownCache['genre'] = getDropdownOptions('genre');
  }
  updatePatient() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Create Patient object with the original timestamp
        Patient patient = Patient(
          id: widget.patientData.id, // Use the existing ID for updates
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
          createdAt: DateTime.timestamp(), // Preserve the original creation date
        );

        // Create a map without updating the createdAt field
        Map<String, dynamic> updateData = patient.toMap();
        // Remove the createdAt field to prevent it from being updated
        updateData.remove('createdAt');

        // Use provider to update patient
        final success = await Provider.of<PatientProviderGlobal>(context, listen: false)
            .updatePatient(widget.patientData.id, updateData);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Patient updated successfully!")),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error updating patient")),
          );
        }
      } catch (e) {
        print("Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating patient: $e")),
        );
      }
    }
  }
// Function to fetch dropdown options from Firestore for a specific document
// - Retrieves a document from the "dropdown_options" collection
// - Extracts all string values from the document and returns them as a list
  Future<List<String>> getDropdownOptions(String document) {
    return Provider.of<PatientProviderGlobal>(context, listen: false)
        .getDropdownOptions(document);
  }

  // Cache for dropdown data
  Map<String, Future<List<String>>> dropdownCache = {};
  @override
  void dispose() {
    // Dispose all controllers
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Edit Patient", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
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

                // Input fields
                _buildTextField("First Name", nameController, Icons.person,
                    TextInputType.text),
                _buildTextField("Last Name", prenomController, Icons.person,
                    TextInputType.text),
                _buildTextField("CIN", cinController, Icons.perm_identity,
                    TextInputType.number),
                _buildTextField(
                    "Age", ageController, Icons.cake, TextInputType.text),
                _buildDateField("Date of Birth", dateOfBirthController),
                _buildTextField("Code Postale", codePostalController,
                    Icons.location_on, TextInputType.number),
                _buildTextField("Insurance Number", numeroAssuranceController,
                    Icons.policy, TextInputType.number),

                Divider(height: 32.0, thickness: 1),

                // Additional fields
                _buildDropdownField(
                    "Genre",
                    "genre",
                    selectedGenre,
                    Icons.transgender,
                    (value) => setState(() => selectedGenre = value)),
                _buildDropdownField(
                    "Etat Civil",
                    "etatCivil",
                    selectedEtatCivil,
                    Icons.person,
                    (value) => setState(() => selectedEtatCivil = value)),
                _buildDropdownField(
                    "Nationalité",
                    "nationalite",
                    selectedNationalite,
                    Icons.flag,
                    (value) => setState(() => selectedNationalite = value)),
                _buildTextField("Adresse", adresseController, Icons.home,
                    TextInputType.streetAddress),
                _buildTextField("Ville", villeController, Icons.location_city,
                    TextInputType.text),
                _buildTextField(
                    "Tel", telController, Icons.phone, TextInputType.text),
                _buildTextField("Tel WhatsApp", telWhatsAppController,
                    Icons.phone_android, TextInputType.text),
                _buildTextField("Email", emailController, Icons.email,
                    TextInputType.emailAddress),
                _buildDateField("Dernier RDV", dernierRdvController),
                _buildDateField("Prochain RDV", prochainRdvController),
                _buildDropdownField(
                    "Group Sanguin",
                    "groupSanguin",
                    selectedGroupSanguin,
                    Icons.water_drop,
                    (value) => setState(() => selectedGroupSanguin = value)),
                _buildDropdownField(
                    "Assurant",
                    "assurant",
                    selectedAssurant,
                    Icons.account_box,
                    (value) => setState(() => selectedAssurant = value)),
                _buildDropdownField(
                    "Assurance",
                    "assurance",
                    selectedAssurance,
                    Icons.shield,
                    (value) => setState(() => selectedAssurance = value)),
                _buildDropdownField(
                    "Relation",
                    "relation",
                    selectedRelation,
                    Icons.group,
                    (value) => setState(() => selectedRelation = value)),
                _buildDropdownField(
                    "Profession",
                    "profession",
                    selectedProfession,
                    Icons.work,
                    (value) => setState(() => selectedProfession = value)),
                _buildTextField(
                    "Pays", paysController, Icons.public, TextInputType.text),
                _buildTextField("Adresse par", adresseParController,
                    Icons.location_on, TextInputType.text),
              ],
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
                  updatePatient();
                }
              },
              label: Text("Update"),
              icon: Icon(Icons.save),
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  // Reuse helper functions (_buildTextField and _buildDateField)
  Widget _buildTextField(String label, TextEditingController controller,
      IconData icon, TextInputType inputType) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "$label is required";
          }
          return null;
        },
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF1E3A8A)),
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2030),
        );
        if (pickedDate != null) {
          setState(() {
            controller.text =
                "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
          });
        }
      },
      child: AbsorbPointer(
        child: _buildTextField(
            label, controller, Icons.calendar_today, TextInputType.datetime),
      ),
    );
  }

  Widget _buildDropdownField(String label, String document, String? value,
      IconData icon, Function(String?) onChanged) {
    // Fetch options from cache if available, otherwise load them using `getDropdownOptions`
    dropdownCache.putIfAbsent(document, () => getDropdownOptions(document));

    return FutureBuilder<List<String>>(
      // The FutureBuilder uses this cached Future to directly display
      // the options without re-fetching.
      future: dropdownCache[document],
      builder: (context, snapshot) {
        // Show a loading spinner while waiting for data
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
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
            value: value,

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
                      style: TextStyle(
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
            icon: Icon(Icons.arrow_drop_down,
                color: const Color(0xFF1E3A8A)), // Updated dropdown icon,
            iconSize: 30, // Size of the dropdown icon
            elevation: 8, // Shadow depth for the dropdown
            style: TextStyle(
                color: Colors.black), // Text style inside the dropdown
          ),
        );
      },
    );
  }
}
