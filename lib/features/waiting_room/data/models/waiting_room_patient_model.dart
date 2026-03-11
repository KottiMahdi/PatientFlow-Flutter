import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:management_cabinet_medical_mobile/features/waiting_room/domain/entities/waiting_room_patient.dart';

class WaitingRoomPatientModel extends WaitingRoomPatient {
  WaitingRoomPatientModel({
    required super.id,
    required super.name,
    required super.time,
    required super.date,
    required super.createdAt,
    required super.status,
  });

  factory WaitingRoomPatientModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WaitingRoomPatientModel(
      id: doc.id,
      name: data['name'] ?? '',
      time: data['time'] ?? '',
      date: data['date'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: _parseStatus(data['status']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'time': time,
      'date': date,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status.toString().split('.').last,
    };
  }

  static WaitingRoomStatus _parseStatus(String? status) {
    return WaitingRoomStatus.values.firstWhere(
      (e) => e.toString().split('.').last == status,
      orElse: () => WaitingRoomStatus.appointments,
    );
  }
}
