import 'package:management_cabinet_medical_mobile/features/waiting_room/domain/entities/waiting_room_patient.dart';
import 'package:management_cabinet_medical_mobile/features/waiting_room/domain/repositories/waiting_room_repository.dart';

class GetWaitingRoomPatients {
  final WaitingRoomRepository repository;

  GetWaitingRoomPatients(this.repository);

  Stream<List<WaitingRoomPatient>> call(String userId) {
    return repository.getWaitingRoomPatients(userId);
  }
}
