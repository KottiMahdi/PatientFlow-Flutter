import 'package:dartz/dartz.dart';
import 'package:management_cabinet_medical_mobile/core/error/failures.dart';
import 'package:management_cabinet_medical_mobile/features/appointment/domain/entities/appointment.dart';

abstract class AppointmentRepository {
  Future<Either<Failure, List<AppointmentEntity>>> getAppointments(
      DateTime date);
  Future<Either<Failure, bool>> addAppointment(AppointmentEntity appointment);
  Future<Either<Failure, bool>> updateAppointment(
      AppointmentEntity appointment, String oldPatientName, String oldDate);
  Future<Either<Failure, bool>> deleteAppointment(String appointmentId);
}
