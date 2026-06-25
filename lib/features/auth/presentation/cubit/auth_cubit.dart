import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_bike_guard/features/auth/data/services/firebase_auth_service.dart';

class AuthCubit extends Cubit<bool> {
  final FirebaseAuthService authService;
  late final StreamSubscription<User?> _authSubscription;

  AuthCubit({required this.authService}) : super(false) {
    _authSubscription = authService.authStateChanges.listen((user) {
      emit(user != null);
    });
  }

  Future<void> login() async {
    await authService.signInAnonymously();
  }

  Future<void> logout() async {
    await authService.signOut();
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
