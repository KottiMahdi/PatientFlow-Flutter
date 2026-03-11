import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/waiting_room_repository.dart';

class DeleteWaitingRoomPatient {
  final WaitingRoomRepository repository;

  DeleteWaitingRoomPatient(this.repository);

  Future<Either<Failure, void>> call(String patientId) async {
    return await repository.deleteWaitingRoomPatient(patientId);
  }
}
