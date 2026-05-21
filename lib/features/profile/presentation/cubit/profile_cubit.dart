import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bike_guard/core/cubit/app_cubit.dart';
import 'package:smart_bike_guard/core/models/bike_data.dart';
import 'package:smart_bike_guard/features/profile/data/services/bike_api_service.dart';
import 'package:smart_bike_guard/features/profile/data/services/local_storage_service.dart';
import 'package:smart_bike_guard/features/profile/presentation/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final BikeApiService apiService;
  final LocalStorageService localStorage;
  final AppCubit appCubit;

  ProfileCubit({
    required this.apiService,
    required this.localStorage,
    required this.appCubit,
  }) : super(ProfileInitial());

  Future<void> saveSettings(BikeData updatedData) async {
    emit(ProfileSaving());

    final mapData = {
      'ownerName': updatedData.ownerName,
      'ownerPhone': updatedData.ownerPhone,
      'bikeName': updatedData.bikeName,
      'bikeType': updatedData.bikeType,
      'serialNumber': updatedData.serialNumber,
      'sensitivity': updatedData.sensitivity,
    };

    try {
      await localStorage.saveBikeData(mapData);
    } catch (_) {}

    try {
      await apiService.updateBikeData(mapData);
      appCubit.updateData(updatedData);
      emit(const ProfileSaved());
    } catch (_) {
      appCubit.updateData(updatedData.copyWith(isOfflineMode: true));
      emit(const ProfileSaved(isOffline: true));
    }
  }
}
