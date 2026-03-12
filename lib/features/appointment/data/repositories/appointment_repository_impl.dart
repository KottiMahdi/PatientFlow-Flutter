import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:management_cabinet_medical_mobile/core/error/failures.dart';
import 'package:management_cabinet_medical_mobile/features/appointment/data/models/appointment_model.dart';
import 'package:management_cabinet_medical_mobile/features/appointment/domain/entities/appointment.dart';
import 'package:management_cabinet_medical_mobile/features/appointment/domain/repositories/appointment_repository.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  AppointmentRepositoryImpl({required this.firestore, required this.auth});

  @override
  Future<Either<Failure, List<AppointmentEntity>>> getAppointments(
      DateTime date) async {
    try {
      final user = auth.currentUser;
      if (user == null) {
        return const Left(ServerFailure('User not authenticated'));
      }

      final snapshot = await firestore
          .collection('appointments')
          .where('id', isEqualTo: user.uid)
          .get();

      final dateString = DateFormat('d/M/yyyy').format(date);

      final List<AppointmentModel> appointments = snapshot.docs
          .map<AppointmentModel>(
              (doc) => AppointmentModel.fromMap(doc.data(), doc.id))
          .where((appointment) => appointment.date == dateString)
          .toList();

      // Sort by time
      appointments.sort((AppointmentModel a, AppointmentModel b) {
        int minutesA = _timeToMinutes(a.time);
        int minutesB = _timeToMinutes(b.time);
        return minutesA.compareTo(minutesB);
      });

      return Right(appointments.cast<AppointmentEntity>());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  int _timeToMinutes(String time) {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1].split(' ')[0]);
      return hour * 60 + minute;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<Either<Failure, bool>> addAppointment(
      AppointmentEntity appointment) async {
    try {
      final user = auth.currentUser;
      if (user == null) {
        return const Left(ServerFailure('User not authenticated'));
      }

      final model = AppointmentModel.fromEntity(appointment);
      final data = model.toMap();
      data['id'] = user.uid;

      // Add to appointments
      await firestore.collection('appointments').add(data);

      // Add to waiting room
      await firestore.collection('waiting_room').add({
        'name': appointment.patientName.trim(),
        'time': appointment.time,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'RDV',
        'date': appointment.date,
        'id': user.uid,
      });

      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateAppointment(AppointmentEntity appointment,
      String oldPatientName, String oldDate) async {
    try {
      final user = auth.currentUser;
      if (user == null) {
        return const Left(ServerFailure('User not authenticated'));
      }

      final model = AppointmentModel.fromEntity(appointment);

      // Update appointment
      await firestore
          .collection('appointments')
          .doc(appointment.documentId)
          .update(model.toMap());

      // Update waiting room entries
      final waitingRoomQuery = await firestore
          .collection('waiting_room')
          .where('name', isEqualTo: oldPatientName.trim())
          .where('date', isEqualTo: oldDate)
          .where('id', isEqualTo: user.uid)
          .get();

      if (waitingRoomQuery.docs.isNotEmpty) {
        final batch = firestore.batch();
        for (var doc in waitingRoomQuery.docs) {
          batch.update(doc.reference, {
            'name': appointment.patientName.trim(),
            'time': appointment.time,
            'date': appointment.date,
          });
        }
        await batch.commit();
      }

      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteAppointment(String appointmentId) async {
    try {
      final user = auth.currentUser;
      if (user == null) {
        return const Left(ServerFailure('User not authenticated'));
      }

      final doc =
          await firestore.collection('appointments').doc(appointmentId).get();
      if (!doc.exists) {
        return const Left(ServerFailure('Appointment not found'));
      }

      final data = doc.data() as Map<String, dynamic>;
      final patientName = data['patientName'] ?? '';
      final date = data['date'] ?? '';

      // Delete appointment
      await firestore.collection('appointments').doc(appointmentId).delete();

      // Delete from waiting room
      final waitingRoomQuery = await firestore
          .collection('waiting_room')
          .where('name', isEqualTo: patientName.trim())
          .where('date', isEqualTo: date)
          .where('id', isEqualTo: user.uid)
          .get();

      final batch = firestore.batch();
      for (var doc in waitingRoomQuery.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
