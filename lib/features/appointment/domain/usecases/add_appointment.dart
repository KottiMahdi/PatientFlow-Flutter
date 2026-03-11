import 'package:dartz/dartz.dart';
import 'package:management_cabinet_medical_mobile/core/error/failures.dart';
import 'package:management_cabinet_medical_mobile/core/usecases/usecase.dart';
import 'package:management_cabinet_medical_mobile/features/appointment/domain/entities/appointment.dart';
import 'package:management_cabinet_medical_mobile/features/appointment/domain/repositories/appointment_repository.dart';

class AddAppointment implements UseCase<bool, AppointmentEntity> {
  final AppointmentRepository repository;

  AddAppointment(this.repository);

  @override
  Future<Either<Failure, bool>> call(AppointmentEntity params) async {
    return await repository.addAppointment(params);
  }
}
