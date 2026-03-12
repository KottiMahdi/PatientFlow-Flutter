import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:management_cabinet_medical_mobile/features/patient/domain/entities/patient.dart';

class PatientModel extends PatientEntity {
  const PatientModel({
    required super.id,
    required super.name,
    required super.prenom,
    required super.cin,
    required super.age,
    required super.dateNaiss,
    required super.codePostal,
    required super.numeroAssurance,
    super.genre,
    super.etatCivil,
    super.nationalite,
    required super.adresse,
    required super.ville,
    required super.tel,
    required super.telWhatsApp,
    required super.email,
    required super.dernierRdv,
    required super.prochainRdv,
    super.groupSanguin,
    super.assurant,
    super.assurance,
    super.relation,
    super.profession,
    required super.pays,
    required super.adressePar,
    super.createdAt,
    super.antecedents,
  });

  factory PatientModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PatientModel(
      id: doc.id,
      name: data['name'] ?? '',
      prenom: data['prenom'] ?? '',
      cin: data['CIN'] ?? '',
      age: data['age'] ?? '',
      dateNaiss: data['dateNaiss'] ?? '',
      codePostal: data['codePostal'] ?? '',
      numeroAssurance: data['numeroAssurance'] ?? '',
      genre: data['genre'],
      etatCivil: data['etatCivil'],
      nationalite: data['nationalite'],
      adresse: data['adresse'] ?? '',
      ville: data['ville'] ?? '',
      tel: data['tel'] ?? '',
      telWhatsApp: data['telWhatsApp'] ?? '',
      email: data['email'] ?? '',
      dernierRdv: data['Dernier RDV'] ?? '',
      prochainRdv: data['Prochain RDV'] ?? '',
      groupSanguin: data['groupSanguin'],
      assurant: data['assurant'],
      assurance: data['assurance'],
      relation: data['relation'],
      profession: data['profession'],
      pays: data['pays'] ?? '',
      adressePar: data['adressee'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      antecedents: data['antecedents'] != null
          ? (data['antecedents'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, List<String>.from(value)),
            )
          : null,
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'name': name,
      'prenom': prenom,
      'CIN': cin,
      'age': age,
      'dateNaiss': dateNaiss,
      'codePostal': codePostal,
      'numeroAssurance': numeroAssurance,
      'genre': genre,
      'etatCivil': etatCivil,
      'nationalite': nationalite,
      'adresse': adresse,
      'ville': ville,
      'tel': tel,
      'telWhatsApp': telWhatsApp,
      'email': email,
      'Dernier RDV': dernierRdv,
      'Prochain RDV': prochainRdv,
      'groupSanguin': groupSanguin,
      'assurant': assurant,
      'assurance': assurance,
      'relation': relation,
      'profession': profession,
      'pays': pays,
      'adressee': adressePar,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      if (antecedents != null) 'antecedents': antecedents,
    };
  }

  factory PatientModel.fromEntity(PatientEntity entity) {
    return PatientModel(
      id: entity.id,
      name: entity.name,
      prenom: entity.prenom,
      cin: entity.cin,
      age: entity.age,
      dateNaiss: entity.dateNaiss,
      codePostal: entity.codePostal,
      numeroAssurance: entity.numeroAssurance,
      genre: entity.genre,
      etatCivil: entity.etatCivil,
      nationalite: entity.nationalite,
      adresse: entity.adresse,
      ville: entity.ville,
      tel: entity.tel,
      telWhatsApp: entity.telWhatsApp,
      email: entity.email,
      dernierRdv: entity.dernierRdv,
      prochainRdv: entity.prochainRdv,
      groupSanguin: entity.groupSanguin,
      assurant: entity.assurant,
      assurance: entity.assurance,
      relation: entity.relation,
      profession: entity.profession,
      pays: entity.pays,
      adressePar: entity.adressePar,
      createdAt: entity.createdAt,
      antecedents: entity.antecedents,
    );
  }
}
