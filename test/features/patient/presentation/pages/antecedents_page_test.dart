import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:management_cabinet_medical_mobile/features/patient/presentation/pages/antecedents_page.dart';
import 'package:management_cabinet_medical_mobile/features/patient/domain/entities/patient.dart';
import 'package:management_cabinet_medical_mobile/features/patient/presentation/providers/patient_provider.dart';
import 'package:management_cabinet_medical_mobile/features/patient/domain/repositories/patient_repository.dart';
import 'package:management_cabinet_medical_mobile/features/patient/domain/usecases/get_patients.dart';
import 'package:management_cabinet_medical_mobile/features/patient/domain/usecases/add_patient.dart';
import 'package:management_cabinet_medical_mobile/features/patient/domain/usecases/update_patient.dart';
import 'package:management_cabinet_medical_mobile/features/patient/domain/usecases/delete_patient.dart';
import 'package:management_cabinet_medical_mobile/features/patient/domain/usecases/get_dropdown_options.dart';
import 'package:management_cabinet_medical_mobile/features/patient/domain/usecases/fetch_patient_antecedents.dart';
import 'package:management_cabinet_medical_mobile/features/patient/domain/usecases/save_patient_antecedents.dart';
import 'package:management_cabinet_medical_mobile/features/patient/domain/usecases/get_antecedents_options.dart';
import 'package:dartz/dartz.dart';
import 'package:management_cabinet_medical_mobile/core/error/failures.dart';

class DummyPatientRepository implements PatientRepository {
  @override
  Future<Either<Failure, List<PatientEntity>>> getPatients() async => const Right([]);

  @override
  Future<Either<Failure, bool>> addPatient(PatientEntity patient) async =>
      const Right(true);

  @override
  Future<Either<Failure, bool>> updatePatient(PatientEntity patient) async =>
      const Right(true);

  @override
  Future<Either<Failure, bool>> deletePatient(String patientId) async =>
      const Right(true);

  @override
  Future<Either<Failure, List<String>>> getDropdownOptions(
          String document) async =>
      const Right([]);

  @override
  Future<Either<Failure, Map<String, List<String>>>> fetchPatientAntecedents(
          String patientId) async =>
      const Right({
        'Antécédents médicaux': ['diabète']
      });

  @override
  Future<Either<Failure, bool>> savePatientAntecedents(
          String patientId, Map<String, List<String>> categoryItems) async =>
      const Right(true);

  @override
  Future<Either<Failure, List<String>>> getAntecedentsOptions(
          String document) async =>
      const Right([]);
}

void main() {
  testWidgets('AntecedentsPage shows patient name after load', (tester) async {
    final repo = DummyPatientRepository();
    final provider = PatientProviderGlobal(
      getPatientsUseCase: GetPatients(repo),
      addPatientUseCase: AddPatient(repo),
      updatePatientUseCase: UpdatePatient(repo),
      deletePatientUseCase: DeletePatient(repo),
      getDropdownOptionsUseCase: GetDropdownOptions(repo),
      fetchPatientAntecedentsUseCase: FetchPatientAntecedents(repo),
      savePatientAntecedentsUseCase: SavePatientAntecedents(repo),
      getAntecedentsOptionsUseCase: GetAntecedentsOptions(repo),
    );

    const patient = PatientEntity(
      id: 'p1',
      name: 'John',
      prenom: 'Doe',
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

    await tester.pumpWidget(
      ChangeNotifierProvider<PatientProviderGlobal>.value(
        value: provider,
        child: const MaterialApp(home: AntecedentsPage(patient: patient)),
      ),
    );

    // wait for async fetchData
    await tester.pumpAndSettle();

    expect(find.text('John Doe'), findsOneWidget);
  });
}
