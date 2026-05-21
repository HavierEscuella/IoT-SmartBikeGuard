import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bike_guard/core/cubit/app_state.dart';
import 'package:smart_bike_guard/core/models/bike_data.dart';
import 'package:smart_bike_guard/features/profile/data/services/bike_api_service.dart';
import 'package:smart_bike_guard/features/profile/data/services/local_storage_service.dart';

class AppCubit extends Cubit<AppState> {
  final BikeApiService apiService;
  final LocalStorageService localStorage;

  AppCubit({required this.apiService, required this.localStorage})
    : super(AppInitial());

  Future<void> loadInitialData() async {
    emit(AppLoading());

    int alertCount = 0;
    try {
      alertCount = await localStorage.getAlertCount();
    } catch (_) {}

    try {
      final cached = await localStorage.getBikeData();
      if (cached != null) {
        apiService
            .fetchBikeData()
            .then(localStorage.saveBikeData)
            .catchError((_) {});

        final cachedData = BikeData(
          ownerName: cached['ownerName'] as String,
          ownerPhone: cached['ownerPhone'] as String,
          bikeName: cached['bikeName'] as String,
          bikeType: cached['bikeType'] as String,
          serialNumber: cached['serialNumber'] as String,
          sensitivity: cached['sensitivity'] as double,
          alertCount: alertCount,
          isOfflineMode: true,
        );

        emit(AppLoaded(cachedData));
        return;
      }
    } catch (_) {}

    try {
      final serverData = await apiService.fetchBikeData();
      await localStorage.saveBikeData(serverData);

      final data = BikeData(
        ownerName: serverData['ownerName'] as String? ?? 'Власник',
        ownerPhone: serverData['ownerPhone'] as String? ?? '',
        bikeName: serverData['bikeName'] as String? ?? 'Байк',
        bikeType: serverData['bikeType'] as String? ?? 'Велосипед',
        serialNumber: serverData['serialNumber'] as String? ?? '',
        sensitivity: (serverData['sensitivity'] as num? ?? 0.5).toDouble(),
        alertCount: alertCount,
        isOfflineMode: false,
      );

      emit(AppLoaded(data));
    } catch (e) {
      emit(AppError(e.toString()));
    }
  }

  void updateData(BikeData newData) {
    emit(AppLoaded(newData));
  }
}
