import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:management_cabinet_medical_mobile/core/error/failures.dart';
import 'package:management_cabinet_medical_mobile/features/waiting_room/domain/entities/waiting_room_patient.dart';
import 'package:management_cabinet_medical_mobile/features/waiting_room/domain/repositories/waiting_room_repository.dart';
import 'package:management_cabinet_medical_mobile/features/waiting_room/data/models/waiting_room_patient_model.dart';

class WaitingRoomRepositoryImpl implements WaitingRoomRepository {
  final FirebaseFirestore firestore;

  WaitingRoomRepositoryImpl({required this.firestore});

  @override
  Stream<List<WaitingRoomPatient>> getWaitingRoomPatients(String userId) {
    return firestore
        .collection('waiting_room')
        .where('userId', isEqualTo: userId)
        .orderBy('time')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => WaitingRoomPatientModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Future<Either<Failure, void>> updatePatientStatus(
      String patientId, WaitingRoomStatus newStatus) async {
    try {
      await firestore
          .collection('waiting_room')
          .doc(patientId)
          .update({'status': newStatus.toString().split('.').last});
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteWaitingRoomPatient(
      String patientId) async {
    try {
      await firestore.collection('waiting_room').doc(patientId).delete();
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addWaitingRoomPatient({
    required String userId,
    required String name,
    required String time,
    required String date,
    required WaitingRoomStatus status,
  }) async {
    try {
      await firestore.collection('waiting_room').add({
        'userId': userId,
        'name': name,
        'time': time,
        'date': date,
        'status': status.toString().split('.').last,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure());
    }
  }
}
