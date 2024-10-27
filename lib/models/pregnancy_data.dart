import 'package:cloud_firestore/cloud_firestore.dart';

class PregnancyData {
  final String id;
  final DateTime dueDate;
  final DateTime lastPeriodDate;
  final int currentWeek;
  final Map<String, List<String>> symptoms;
  final double? weight;
  final Map<String, String> appointments;
  final String? notes;
  final List<String> medications;
  final Map<String, dynamic> measurements;

  PregnancyData({
    required this.id,
    required this.dueDate,
    required this.lastPeriodDate,
    required this.currentWeek,
    required this.symptoms,
    this.weight,
    required this.appointments,
    this.notes,
    required this.medications,
    required this.measurements,
  });

  factory PregnancyData.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PregnancyData(
      id: doc.id,
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      lastPeriodDate: (data['lastPeriodDate'] as Timestamp).toDate(),
      currentWeek: data['currentWeek'] ?? 0,
      symptoms: Map<String, List<String>>.from(data['symptoms'] ?? {}),
      weight: data['weight']?.toDouble(),
      appointments: Map<String, String>.from(data['appointments'] ?? {}),
      notes: data['notes'],
      medications: List<String>.from(data['medications'] ?? []),
      measurements: data['measurements'] ?? {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'dueDate': Timestamp.fromDate(dueDate),
      'lastPeriodDate': Timestamp.fromDate(lastPeriodDate),
      'currentWeek': currentWeek,
      'symptoms': symptoms,
      'weight': weight,
      'appointments': appointments,
      'notes': notes,
      'medications': medications,
      'measurements': measurements,
    };
  }
}
