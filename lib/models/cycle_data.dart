import 'package:cloud_firestore/cloud_firestore.dart';

class CycleData {
  final String id;
  final DateTime cycleStartDate;
  final DateTime? cycleEndDate;
  final int cycleDuration;
  final String flowIntensity;
  final Map<String, dynamic> symptoms;
  final double? basalTemperature;
  final String? cervicalMucus;
  final String? notes;

  CycleData({
    required this.id,
    required this.cycleStartDate,
    this.cycleEndDate,
    required this.cycleDuration,
    required this.flowIntensity,
    required this.symptoms,
    this.basalTemperature,
    this.cervicalMucus,
    this.notes,
  });

  factory CycleData.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CycleData(
      id: doc.id,
      cycleStartDate: (data['cycleStartDate'] as Timestamp).toDate(),
      cycleEndDate: data['cycleEndDate'] != null 
          ? (data['cycleEndDate'] as Timestamp).toDate() 
          : null,
      cycleDuration: data['cycleDuration'] ?? 28,
      flowIntensity: data['flowIntensity'] ?? 'medium',
      symptoms: data['symptoms'] ?? {},
      basalTemperature: data['basalTemperature']?.toDouble(),
      cervicalMucus: data['cervicalMucus'],
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'cycleStartDate': Timestamp.fromDate(cycleStartDate),
      'cycleEndDate': cycleEndDate != null ? Timestamp.fromDate(cycleEndDate!) : null,
      'cycleDuration': cycleDuration,
      'flowIntensity': flowIntensity,
      'symptoms': symptoms,
      'basalTemperature': basalTemperature,
      'cervicalMucus': cervicalMucus,
      'notes': notes,
    };
  }
}

