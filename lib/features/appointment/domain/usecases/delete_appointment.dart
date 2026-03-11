import 'package:dartz/dartz.dart';
import 'package:management_cabinet_medical_mobile/core/error/failures.dart';
import 'package:management_cabinet_medical_mobile/core/usecases/usecase.dart';
import 'package:management_cabinet_medical_mobile/features/appointment/domain/repositories/appointment_repository.dart';

class DeleteAppointment implements UseCase<bool, String> {
  final AppointmentRepository repository;

  DeleteAppointment(this.repository);

  @override
  Future<Either<Failure, bool>> call(String params) async {
    return await repository.deleteAppointment(params);
  }
}
