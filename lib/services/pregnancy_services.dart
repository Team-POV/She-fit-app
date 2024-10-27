import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:she_fit_app/models/pregnancy_data.dart';

class PregnancyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _currentPregnancyId;

  Future<String> _ensurePregnancyDocument() async {
    if (_currentPregnancyId != null) {
      return _currentPregnancyId!;
    }

    String userId = _auth.currentUser!.uid;
    var pregnancyRef =
        _firestore.collection('users').doc(userId).collection('pregnancy');

    // Try to get the most recent pregnancy document
    var querySnapshot = await pregnancyRef
        .orderBy('lastPeriodDate', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      _currentPregnancyId = querySnapshot.docs.first.id;
      return _currentPregnancyId!;
    }

    // If no pregnancy document exists, create a new one
    var newDoc = await pregnancyRef.add({
      'lastPeriodDate': Timestamp.fromDate(DateTime.now()),
      'dueDate': Timestamp.fromDate(DateTime.now().add(Duration(days: 280))),
      'currentWeek': 1,
      'symptoms': {},
      'appointments': {},
      'medications': [],
      'measurements': {},
      'createdAt': FieldValue.serverTimestamp(),
    });

    _currentPregnancyId = newDoc.id;
    return _currentPregnancyId!;
  }

  Future<void> addPregnancyData(PregnancyData pregnancyData) async {
    String userId = _auth.currentUser!.uid;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('pregnancy')
        .add(pregnancyData.toFirestore());
  }

  Future<void> updateDailyTracking(
      String dateKey, Map<String, dynamic> dayData) async {
    try {
      String userId = _auth.currentUser!.uid;
      String pregnancyId = await _ensurePregnancyDocument();

      // Use set with merge to create or update the document
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('pregnancy')
          .doc(pregnancyId)
          .set({
        'measurements': {dateKey: dayData},
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating daily tracking: $e');
      throw Exception('Failed to update tracking data: $e');
    }
  }

  // Updated stream method to handle document creation
  Stream<PregnancyData?> streamPregnancyData() async* {
    String userId = _auth.currentUser!.uid;

    try {
      // Ensure we have a pregnancy document
      await _ensurePregnancyDocument();

      // Now stream the data
      yield* _firestore
          .collection('users')
          .doc(userId)
          .collection('pregnancy')
          .doc(_currentPregnancyId)
          .snapshots()
          .map((snapshot) {
        if (!snapshot.exists) {
          return null;
        }
        return PregnancyData.fromFirestore(snapshot);
      });
    } catch (e) {
      print('Error streaming pregnancy data: $e');
      yield null;
    }
  }

  Future<void> createNewPregnancy({
    required DateTime lastPeriodDate,
    String? notes,
  }) async {
    try {
      String userId = _auth.currentUser!.uid;

      var newPregnancyRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('pregnancy')
          .add({
        'lastPeriodDate': Timestamp.fromDate(lastPeriodDate),
        'dueDate': Timestamp.fromDate(lastPeriodDate.add(Duration(days: 280))),
        'currentWeek': calculateCurrentWeek(lastPeriodDate),
        'symptoms': {},
        'appointments': {},
        'medications': [],
        'measurements': {},
        'notes': notes,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _currentPregnancyId = newPregnancyRef.id;
    } catch (e) {
      print('Error creating new pregnancy: $e');
      throw Exception('Failed to create new pregnancy: $e');
    }
  }

  Future<void> initializePregnancyIfNeeded() async {
    try {
      await _ensurePregnancyDocument();
    } catch (e) {
      print('Error initializing pregnancy: $e');
      throw Exception('Failed to initialize pregnancy: $e');
    }
  }

  int calculateCurrentWeek(DateTime lastPeriodDate) {
    int days = DateTime.now().difference(lastPeriodDate).inDays;
    return (days / 7).floor() + 1;
  }

  Future<void> updatePregnancyField(String field, dynamic value) async {
    try {
      String pregnancyId = await _ensurePregnancyDocument();
      String userId = _auth.currentUser!.uid;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('pregnancy')
          .doc(pregnancyId)
          .update({
        field: value,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating pregnancy field: $e');
      throw Exception('Failed to update pregnancy field: $e');
    }
  }
}
