import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:she_fit_app/models/cycle_data.dart';

class CycleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addCycleData(CycleData cycleData) async {
    String userId = _auth.currentUser!.uid;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('cycles')
        .add(cycleData.toFirestore());
  }

  Future<List<CycleData>> getUserCycles() async {
    String userId = _auth.currentUser!.uid;
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('cycles')
        .orderBy('cycleStartDate', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => CycleData.fromFirestore(doc))
        .toList();
  }

  Stream<List<CycleData>> streamUserCycles() {
    String userId = _auth.currentUser!.uid;
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('cycles')
        .orderBy('cycleStartDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CycleData.fromFirestore(doc))
            .toList());
  }
}