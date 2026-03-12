import 'package:management_cabinet_medical_mobile/features/appointment/domain/entities/appointment.dart';

class AppointmentModel extends AppointmentEntity {
  const AppointmentModel({
    required super.documentId,
    required super.userId,
    required super.patientName,
    required super.date,
    required super.time,
    required super.reason,
  });

  factory AppointmentModel.fromMap(Map<String, dynamic> map, String docId) {
    return AppointmentModel(
      documentId: docId,
      userId: map['id'] ?? '',
      patientName: map['patientName'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      reason: map['reason'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': userId,
      'patientName': patientName,
      'date': date,
      'time': time,
      'reason': reason,
    };
  }

  factory AppointmentModel.fromEntity(AppointmentEntity entity) {
    return AppointmentModel(
      documentId: entity.documentId,
      userId: entity.userId,
      patientName: entity.patientName,
      date: entity.date,
      time: entity.time,
      reason: entity.reason,
    );
  }
}
