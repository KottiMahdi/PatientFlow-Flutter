import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/waiting_room_patient.dart';
import '../repositories/waiting_room_repository.dart';

class UpdatePatientStatus {
  final WaitingRoomRepository repository;

  UpdatePatientStatus(this.repository);

  Future<Either<Failure, void>> call(
      String patientId, WaitingRoomStatus newStatus) async {
    return await repository.updatePatientStatus(patientId, newStatus);
  }
}
