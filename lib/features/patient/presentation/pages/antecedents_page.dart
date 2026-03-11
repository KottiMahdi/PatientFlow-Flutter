import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:management_cabinet_medical_mobile/features/patient/domain/entities/patient.dart';
import 'package:management_cabinet_medical_mobile/features/patient/presentation/providers/patient_provider.dart';
import 'package:management_cabinet_medical_mobile/features/patient/presentation/pages/antecedents_components/antecedents_dialog.dart';
import 'package:management_cabinet_medical_mobile/features/patient/presentation/pages/antecedents_components/antecedents_styling.dart';

class AntecedentsPage extends StatefulWidget {
  final String patientId;

  const AntecedentsPage({super.key, required this.patientId});

  @override
  State<AntecedentsPage> createState() => _AntecedentsPageState();
}

class _AntecedentsPageState extends State<AntecedentsPage> {
  PatientEntity patient = PatientEntity.empty();
  bool isLoading = true;

  final List<String> categories = [
    'Antécédents obstétricaux',
    'Antécédents gynécologiques',
    'Antécédents menstruels',
    'Antécédents familiaux',
    'Antécédents médicaux',
    'Antécédents chirurgicaux',
    'Facteurs de risque',
    'Allergique',
  ];

  Map<String, List<String>> categoryItems = {
    'Antécédents obstétricaux': [],
    'Antécédents gynécologiques': [],
    'Antécédents menstruels': [],
    'Antécédents familiaux': [],
    'Antécédents médicaux': [],
    'Antécédents chirurgicaux': [],
    'Facteurs de risque': [],
    'Allergique': [],
  };

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    final provider = Provider.of<PatientProviderGlobal>(context, listen: false);

    // Get patient data from provider (assuming patients are already fetched in PatientsPage)
    final patientData = provider.getPatientById(widget.patientId);

    // Fetch antecedents
    final antecedents =
        await provider.fetchPatientAntecedents(widget.patientId);

    setState(() {
      patient = patientData;
      categoryItems = antecedents;
      isLoading = false;
    });
  }

  // Save antecedents using provider
  Future<void> savePatientAntecedents() async {
    final provider = Provider.of<PatientProviderGlobal>(context, listen: false);
    await provider.savePatientAntecedents(widget.patientId, categoryItems);
  }

  // Get antecedents options through provider
  Future<List<String>> getAntecedentsOptions(String document) async {
    final provider = Provider.of<PatientProviderGlobal>(context, listen: false);
    return provider.getAntecedentsOptions(document);
  }

  // Get document key through provider
  String getDocumentKey(String category) {
    final provider = Provider.of<PatientProviderGlobal>(context, listen: false);
    return provider.getDocumentKey(category);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title:
              const Text('Loading...', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF1E3A8A),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${patient.name} ${patient.prenom}',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white, Colors.white],
            stops: const [0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final items = categoryItems[category]!;
              final categoryColor = getCategoryColor(category);
              final categoryLightColor = getCategoryLightColor(category);
              final categoryDarkColor = getCategoryDarkColor(category);

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: categoryColor.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: categoryColor, width: 2),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                    ),
                    child: ExpansionTile(
                      backgroundColor: Colors.white,
                      collapsedBackgroundColor:
                          categoryLightColor.withValues(alpha: 0.3),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: categoryColor,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          getCategoryIcon(category),
                          color: categoryDarkColor,
                          size: 24,
                        ),
                      ),
                      trailing: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(Icons.add, color: Colors.green.shade700),
                          iconSize: 20,
                          onPressed: () => AntecedentsDialog.showAddItemDialog(
                            context: context,
                            category: category,
                            getCategoryColor: getCategoryColor,
                            getCategoryDarkColor: getCategoryDarkColor,
                            getCategoryIcon: getCategoryIcon,
                            getAntecedentsOptions: getAntecedentsOptions,
                            getDocumentKey: getDocumentKey,
                            categoryItems: categoryItems,
                            savePatientAntecedents: savePatientAntecedents,
                            onItemAdded: () {
                              setState(() {
                                // This will trigger a rebuild of the widget
                              });
                            },
                          ),
                          tooltip: "Ajouter un élément",
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      title: Text(
                        category,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: categoryDarkColor,
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            margin: const EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              color: categoryColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: categoryColor.withValues(alpha: 0.5),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              "${items.length} élément(s)",
                              style: TextStyle(
                                fontSize: 12,
                                color: categoryDarkColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      tilePadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      childrenPadding: const EdgeInsets.only(bottom: 8),
                      initiallyExpanded: true,
                      children: [
                        Container(
                          height: 1,
                          color: categoryColor.withValues(alpha: 0.3),
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        if (items.isNotEmpty)
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(16),
                              ),
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: items.length,
                              separatorBuilder: (context, index) => Divider(
                                height: 1,
                                thickness: 1,
                                indent: 56,
                                endIndent: 16,
                                color: Colors.grey.shade100,
                              ),
                              itemBuilder: (context, index) {
                                final item = items[index];
                                return ListTile(
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(20, 4, 16, 4),
                                  leading: Container(
                                    height: 32,
                                    width: 32,
                                    decoration: BoxDecoration(
                                      color: categoryLightColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "${index + 1}",
                                        style: TextStyle(
                                          color: categoryDarkColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    item,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  trailing: Container(
                                    height: 36,
                                    width: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              Colors.red.withValues(alpha: 0.1),
                                          blurRadius: 3,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      icon: Icon(Icons.delete_outline,
                                          color: Colors.red.shade600),
                                      iconSize: 18,
                                      onPressed: () {
                                        setState(() {
                                          categoryItems[category]!.remove(item);
                                        });
                                        savePatientAntecedents();
                                      },
                                      tooltip: "Supprimer",
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        if (items.isEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 24, horizontal: 16),
                            child: Center(
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: categoryLightColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.info_outline,
                                      color: categoryColor,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Aucun élément ajouté",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Utilisez le bouton + pour ajouter un élément",
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
