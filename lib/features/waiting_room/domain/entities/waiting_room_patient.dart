enum WaitingRoomStatus { waiting, inConsultation, completed, appointments }

class WaitingRoomPatient {
  final String id;
  final String name;
  final String time;
  final String date;
  final DateTime createdAt;
  final WaitingRoomStatus status;

  WaitingRoomPatient({
    required this.id,
    required this.name,
    required this.time,
    required this.date,
    required this.createdAt,
    required this.status,
  });

  WaitingRoomPatient copyWith({
    String? id,
    String? name,
    String? time,
    String? date,
    DateTime? createdAt,
    WaitingRoomStatus? status,
  }) {
    return WaitingRoomPatient(
      id: id ?? this.id,
      name: name ?? this.name,
      time: time ?? this.time,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}
