import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/waiting_room_patient.dart';

abstract class WaitingRoomRepository {
  Stream<List<WaitingRoomPatient>> getWaitingRoomPatients(String userId);
  Future<Either<Failure, void>> updatePatientStatus(
      String patientId, WaitingRoomStatus newStatus);
  Future<Either<Failure, void>> deleteWaitingRoomPatient(String patientId);
  Future<Either<Failure, void>> addWaitingRoomPatient({
    required String userId,
    required String name,
    required String time,
    required String date,
    required WaitingRoomStatus status,
  });
}
