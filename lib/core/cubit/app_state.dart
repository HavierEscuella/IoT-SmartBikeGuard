import 'package:equatable/equatable.dart';
import 'package:smart_bike_guard/core/models/bike_data.dart';

abstract class AppState extends Equatable {
  const AppState();

  @override
  List<Object?> get props => [];
}

class AppInitial extends AppState {}

class AppLoading extends AppState {}

class AppLoaded extends AppState {
  final BikeData data;

  const AppLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class AppError extends AppState {
  final String message;

  const AppError(this.message);

  @override
  List<Object?> get props => [message];
}
