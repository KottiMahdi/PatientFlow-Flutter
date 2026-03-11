import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/waiting_room_patient.dart';
import '../repositories/waiting_room_repository.dart';

class AddWaitingRoomPatient implements UseCase<void, AddPatientParams> {
  final WaitingRoomRepository repository;

  AddWaitingRoomPatient(this.repository);

  @override
  Future<Either<Failure, void>> call(AddPatientParams params) async {
    return await repository.addWaitingRoomPatient(
      userId: params.userId,
      name: params.name,
      time: params.time,
      date: params.date,
      status: params.status,
    );
  }
}

class AddPatientParams {
  final String userId;
  final String name;
  final String time;
  final String date;
  final WaitingRoomStatus status;

  AddPatientParams({
    required this.userId,
    required this.name,
    required this.time,
    required this.date,
    required this.status,
  });
}
