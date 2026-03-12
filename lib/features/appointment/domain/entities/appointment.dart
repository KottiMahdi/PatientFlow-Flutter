class AppointmentEntity {
  final String documentId;
  final String userId;
  final String patientName;
  final String date;
  final String time;
  final String reason;

  const AppointmentEntity({
    required this.documentId,
    required this.userId,
    required this.patientName,
    required this.date,
    required this.time,
    required this.reason,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppointmentEntity &&
          runtimeType == other.runtimeType &&
          documentId == other.documentId;

  @override
  int get hashCode => documentId.hashCode;
}
