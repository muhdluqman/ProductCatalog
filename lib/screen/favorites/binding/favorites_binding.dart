import 'package:get/get.dart';

import '../../../core/di/injection.dart';
import '../../../domain/repositories/preferences_repository.dart';
import '../controller/favorites_controller.dart';

class FavoritesBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<FavoritesController>(
      FavoritesController(getIt<PreferencesRepository>()),
      permanent: true,
    );
  }
}
