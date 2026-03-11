import 'package:dartz/dartz.dart';
import 'package:management_cabinet_medical_mobile/core/error/failures.dart';
import 'package:management_cabinet_medical_mobile/core/usecases/usecase.dart';
import 'package:management_cabinet_medical_mobile/features/appointment/domain/entities/appointment.dart';
import 'package:management_cabinet_medical_mobile/features/appointment/domain/repositories/appointment_repository.dart';

class GetAppointments implements UseCase<List<AppointmentEntity>, DateTime> {
  final AppointmentRepository repository;

  GetAppointments(this.repository);

  @override
  Future<Either<Failure, List<AppointmentEntity>>> call(DateTime params) async {
    return await repository.getAppointments(params);
  }
}
