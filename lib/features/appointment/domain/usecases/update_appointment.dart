import 'package:dartz/dartz.dart';
import 'package:management_cabinet_medical_mobile/core/error/failures.dart';
import 'package:management_cabinet_medical_mobile/core/usecases/usecase.dart';
import 'package:management_cabinet_medical_mobile/features/appointment/domain/entities/appointment.dart';
import 'package:management_cabinet_medical_mobile/features/appointment/domain/repositories/appointment_repository.dart';

class UpdateAppointmentParams {
  final AppointmentEntity appointment;
  final String oldPatientName;
  final String oldDate;

  UpdateAppointmentParams({
    required this.appointment,
    required this.oldPatientName,
    required this.oldDate,
  });
}

class UpdateAppointment implements UseCase<bool, UpdateAppointmentParams> {
  final AppointmentRepository repository;

  UpdateAppointment(this.repository);

  @override
  Future<Either<Failure, bool>> call(UpdateAppointmentParams params) async {
    return await repository.updateAppointment(
      params.appointment,
      params.oldPatientName,
      params.oldDate,
    );
  }
}
