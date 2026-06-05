import 'package:flutter_test/flutter_test.dart';
import 'package:management_cabinet_medical_mobile/features/waiting_room/presentation/providers/waiting_room_provider.dart';
import 'package:management_cabinet_medical_mobile/features/waiting_room/domain/usecases/get_waiting_room_patients.dart';
import 'package:management_cabinet_medical_mobile/features/waiting_room/domain/usecases/update_patient_status.dart';
import 'package:management_cabinet_medical_mobile/features/waiting_room/domain/usecases/delete_waiting_room_patient.dart';
import 'package:management_cabinet_medical_mobile/features/waiting_room/domain/usecases/add_waiting_room_patient.dart';
import 'package:dartz/dartz.dart';
import 'package:management_cabinet_medical_mobile/core/error/failures.dart';
import 'package:management_cabinet_medical_mobile/features/waiting_room/domain/entities/waiting_room_patient.dart';
import 'package:management_cabinet_medical_mobile/features/waiting_room/domain/repositories/waiting_room_repository.dart';

class _DummyRepo implements WaitingRoomRepository {
  @override
  Stream<List<WaitingRoomPatient>> getWaitingRoomPatients(String userId) {
    return Stream.value([]);
  }

  @override
  Future<Either<Failure, void>> updatePatientStatus(
          String patientId, WaitingRoomStatus newStatus) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> deleteWaitingRoomPatient(
          String patientId) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> addWaitingRoomPatient(
          {required String userId,
          required String name,
          required String time,
          required String date,
          required WaitingRoomStatus status}) async =>
      const Right(null);
}

class TestUpdatePatientStatus extends UpdatePatientStatus {
  TestUpdatePatientStatus() : super(_DummyRepo());

  @override
  Future<Either<Failure, void>> call(
          String patientId, WaitingRoomStatus newStatus) async =>
      const Right(null);
}

class TestDeleteWaitingRoomPatient extends DeleteWaitingRoomPatient {
  TestDeleteWaitingRoomPatient() : super(_DummyRepo());

  @override
  Future<Either<Failure, void>> call(String patientId) async =>
      const Right(null);
}

class TestAddWaitingRoomPatient extends AddWaitingRoomPatient {
  TestAddWaitingRoomPatient() : super(_DummyRepo());

  @override
  Future<Either<Failure, void>> call(AddPatientParams params) async =>
      const Right(null);
}

class TestGetWaitingRoomPatients extends GetWaitingRoomPatients {
  final Stream<List<WaitingRoomPatient>> Function(String) handler;
  TestGetWaitingRoomPatients(this.handler) : super(_DummyRepo());

  @override
  Stream<List<WaitingRoomPatient>> call(String userId) => handler(userId);
}

class FakePatient extends WaitingRoomPatient {
  FakePatient()
      : super(
          id: '1',
          name: 'A',
          time: '10:00',
          date: DateTime.now().day.toString() +
              '/' +
              DateTime.now().month.toString() +
              '/' +
              DateTime.now().year.toString(),
          createdAt: DateTime.now(),
          status: WaitingRoomStatus.appointments,
        );
}

void main() {
  late TestGetWaitingRoomPatients getter;
  late WaitingRoomProviderGlobal provider;

  setUp(() {
    getter = TestGetWaitingRoomPatients((_) => Stream.value([FakePatient()]));
    provider = WaitingRoomProviderGlobal(
      getWaitingRoomPatients: getter,
      updatePatientStatus: TestUpdatePatientStatus(),
      deleteWaitingRoomPatient: TestDeleteWaitingRoomPatient(),
      addWaitingRoomPatient: TestAddWaitingRoomPatient(),
    );
  });

  test('listens to stream and updates patients', () async {
    provider.init('userId');
    await Future.delayed(const Duration(milliseconds: 10));
    expect(provider.appointmentsPatients.length, 1);
    expect(provider.isLoading, false);
  });
}
