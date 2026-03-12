class PatientEntity {
  final String id;
  final String name;
  final String prenom;
  final String cin;
  final String age;
  final String dateNaiss;
  final String codePostal;
  final String numeroAssurance;
  final String? genre;
  final String? etatCivil;
  final String? nationalite;
  final String adresse;
  final String ville;
  final String tel;
  final String telWhatsApp;
  final String email;
  final String dernierRdv;
  final String prochainRdv;
  final String? groupSanguin;
  final String? assurant;
  final String? assurance;
  final String? relation;
  final String? profession;
  final String pays;
  final String adressePar;
  final DateTime? createdAt;
  final Map<String, List<String>>? antecedents;

  const PatientEntity({
    required this.id,
    required this.name,
    required this.prenom,
    required this.cin,
    required this.age,
    required this.dateNaiss,
    required this.codePostal,
    required this.numeroAssurance,
    this.genre,
    this.etatCivil,
    this.nationalite,
    required this.adresse,
    required this.ville,
    required this.tel,
    required this.telWhatsApp,
    required this.email,
    required this.dernierRdv,
    required this.prochainRdv,
    this.groupSanguin,
    this.assurant,
    this.assurance,
    this.relation,
    this.profession,
    required this.pays,
    required this.adressePar,
    this.createdAt,
    this.antecedents,
  });

  factory PatientEntity.empty() {
    return const PatientEntity(
      id: '',
      name: '',
      prenom: '',
      cin: '',
      age: '',
      dateNaiss: '',
      codePostal: '',
      numeroAssurance: '',
      adresse: '',
      ville: '',
      tel: '',
      telWhatsApp: '',
      email: '',
      dernierRdv: '',
      prochainRdv: '',
      pays: '',
      adressePar: '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatientEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
