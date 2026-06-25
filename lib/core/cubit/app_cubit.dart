import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bike_guard/core/cubit/app_state.dart';
import 'package:smart_bike_guard/core/models/bike_data.dart';
import 'package:smart_bike_guard/features/auth/data/services/firebase_auth_service.dart';
import 'package:smart_bike_guard/features/profile/data/services/firebase_firestore_service.dart';

class AppCubit extends Cubit<AppState> {
  final FirebaseFirestoreService firestoreService;
  final FirebaseAuthService authService;
  StreamSubscription<BikeData>? _bikeDataSubscription;

  AppCubit({required this.firestoreService, required this.authService})
    : super(AppInitial());

  Future<void> loadInitialData() async {
    emit(AppLoading());
    final user = authService.currentUser;
    if (user == null) {
      emit(const AppError('Користувач не авторизований'));
      return;
    }

    _bikeDataSubscription?.cancel();
    _bikeDataSubscription = firestoreService
        .streamBikeData(user.uid)
        .listen(
          (data) {
            emit(AppLoaded(data));
          },
          onError: (Object e) {
            emit(AppError(e.toString()));
          },
        );
  }

  Future<void> incrementAlertCount() async {
    final user = authService.currentUser;
    if (user == null) return;

    if (state is AppLoaded) {
      final currentCount = (state as AppLoaded).data.alertCount;
      try {
        await firestoreService.updateAlertCount(user.uid, currentCount + 1);
      } catch (e) {
        // Ігноруємо помилку (наприклад, якщо БД ще не створена)
      }
    }
  }

  @override
  Future<void> close() {
    _bikeDataSubscription?.cancel();
    return super.close();
  }
}
