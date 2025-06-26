import 'package:flutter/material.dart';
import '../../../providers/track_patient_provider.dart';
import '../delete_page.dart';

class WaitingRoomColumn extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Patient> patients;
  final Function(Patient) onPatientMove;
  final Function(Patient) onPatientDropped;
  final PatientStatus targetStatus;

  const WaitingRoomColumn({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.patients,
    required this.onPatientMove,
    required this.onPatientDropped,
    required this.targetStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: screenWidth * 0.03,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(screenWidth * 0.04),
                topRight: Radius.circular(screenWidth * 0.04),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Icon(icon, color: Colors.white, size: screenWidth * 0.06),
                      SizedBox(width: screenWidth * 0.03),
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.03,
                        vertical: screenHeight * 0.005,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(screenWidth * 0.1),
                      ),
                      child: Text(
                        '${patients.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          DragTarget<Patient>(
            onAccept: (patient) => onPatientDropped(patient),
            builder: (context, candidateData, rejectedData) {
              if (patients.isEmpty) {
                return Container(
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  child: Column(
                    children: [
                      Icon(Icons.not_interested,
                          size: screenWidth * 0.15,
                          color: Colors.grey.withOpacity(0.5)),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        "No patients available",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Padding(
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                child: Column(
                  children: patients.map((patient) {
                    return LongPressDraggable<Patient>(
                      data: patient,
                      feedback: Material(
                        elevation: 8,
                        borderRadius: BorderRadius.circular(screenWidth * 0.04),
                        child: Container(
                          width: screenWidth * 0.8,
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.04),
                            border: Border.all(
                              color: color.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: color.withOpacity(0.1),
                                radius: screenWidth * 0.06,
                                child: Icon(Icons.person,
                                    color: color, size: screenWidth * 0.06),
                              ),
                              SizedBox(width: screenWidth * 0.04),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(patient.name,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: screenWidth * 0.04)),
                                  Text("Time: ${patient.time}",
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: screenWidth * 0.035)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      childWhenDragging: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.01,
                        ),
                        height: screenHeight * 0.1,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.04),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text("Moving...",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: screenWidth * 0.04)),
                        ),
                      ),
                      child: Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.01,
                        ),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.04),
                          side: BorderSide(
                            color: color.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.02),
                          child: _buildPatientTile(patient, context),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPatientTile(Patient patient, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04, vertical: screenHeight * 0.01),
      leading: Container(
        width: screenWidth * 0.12,
        height: screenWidth * 0.12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.2)],
          ),
        ),
        child: Icon(Icons.person, color: color, size: screenWidth * 0.07),
      ),
      title: Text(patient.name,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: screenWidth * 0.04)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, size: screenWidth * 0.035),
              SizedBox(width: screenWidth * 0.01),
              Text(patient.time,
                  style: TextStyle(fontSize: screenWidth * 0.035)),
            ],
          ),
          Row(
            children: [
              Icon(Icons.calendar_today, size: screenWidth * 0.035),
              SizedBox(width: screenWidth * 0.01),
              Text(patient.date,
                  style: TextStyle(fontSize: screenWidth * 0.035)),
            ],
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(screenWidth * 0.02),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_forward,
                  color: color, size: screenWidth * 0.05),
              onPressed: () => onPatientMove(patient),
            ),
          ),
          SizedBox(width: screenWidth * 0.02),
          Container(
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(screenWidth * 0.02),
            ),
            child: DeletePatientService.buildDeleteButton(
              context: context,
              patientName: patient.name,
              patientId: patient.id,
            ),
          ),
        ],
      ),
    );
  }
}
