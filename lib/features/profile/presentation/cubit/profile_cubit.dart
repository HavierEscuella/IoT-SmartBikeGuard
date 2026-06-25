import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bike_guard/core/models/bike_data.dart';
import 'package:smart_bike_guard/features/auth/data/services/firebase_auth_service.dart';
import 'package:smart_bike_guard/features/profile/data/services/firebase_firestore_service.dart';
import 'package:smart_bike_guard/features/profile/presentation/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final FirebaseFirestoreService firestoreService;
  final FirebaseAuthService authService;

  ProfileCubit({required this.firestoreService, required this.authService})
    : super(ProfileInitial());

  Future<void> saveSettings(BikeData updatedData) async {
    emit(ProfileSaving());

    final user = authService.currentUser;
    if (user == null) {
      emit(const ProfileSaved(isOffline: true));
      return;
    }

    try {
      await firestoreService.saveBikeData(user.uid, updatedData);
      emit(const ProfileSaved());
    } catch (_) {
      emit(const ProfileSaved(isOffline: true));
    }
  }
}
