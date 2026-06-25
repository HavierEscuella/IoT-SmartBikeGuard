import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_bike_guard/core/models/bike_data.dart';

class FirebaseFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<BikeData> streamBikeData(String uid) {
    return _firestore.collection('user_bikes').doc(uid).snapshots().map((
      snapshot,
    ) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        return BikeData(
          ownerName: data['ownerName'] as String? ?? 'Власник',
          ownerPhone: data['ownerPhone'] as String? ?? '',
          bikeName: data['bikeName'] as String? ?? 'Байк',
          bikeType: data['bikeType'] as String? ?? 'Велосипед',
          serialNumber: data['serialNumber'] as String? ?? '',
          sensitivity: (data['sensitivity'] as num? ?? 0.5).toDouble(),
          alertCount: data['alertCount'] as int? ?? 0,
          isOfflineMode: snapshot.metadata.isFromCache,
        );
      } else {
        return BikeData(
          ownerName: 'Новий власник',
          ownerPhone: '',
          bikeName: 'Мій Байк',
          bikeType: 'Електровелосипед',
          serialNumber: '',
          sensitivity: 0.5,
          alertCount: 0,
          isOfflineMode: snapshot.metadata.isFromCache,
        );
      }
    });
  }

  Future<void> saveBikeData(String uid, BikeData data) async {
    await _firestore.collection('user_bikes').doc(uid).set({
      'ownerName': data.ownerName,
      'ownerPhone': data.ownerPhone,
      'bikeName': data.bikeName,
      'bikeType': data.bikeType,
      'serialNumber': data.serialNumber,
      'sensitivity': data.sensitivity,
      'alertCount': data.alertCount,
    }, SetOptions(merge: true));
  }

  Future<void> updateAlertCount(String uid, int newCount) async {
    await _firestore.collection('user_bikes').doc(uid).set({
      'alertCount': newCount,
    }, SetOptions(merge: true));
  }
}
