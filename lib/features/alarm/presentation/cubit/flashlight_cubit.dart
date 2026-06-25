import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_bike_flashlight/smart_bike_flashlight.dart';

class FlashlightCubit extends Cubit<bool> {
  FlashlightCubit() : super(false);

  Future<void> toggle(BuildContext context) async {
    final newState = !state;
    try {
      await SmartBikeFlashlight.toggleTorch(newState);
      emit(newState);
    } catch (e) {
      if (context.mounted) {
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Помилка'),
            content: const Text(
              'Ліхтарик не підтримується на цьому пристрої або платформі.\n'
              'Тільки Android.',
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
}
