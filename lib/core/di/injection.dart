import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/dio_client.dart';
import '../../data/datasources/local_storage.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/repositories/preferences_repository_impl.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/repositories/preferences_repository.dart';
import '../../domain/repositories/product_repository.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  getIt.registerLazySingleton<Dio>(DioClient.create);

  final prefs = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<LocalStorage>(() => LocalStorage(prefs));

  getIt.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(getIt<Dio>()),
  );

  getIt.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(getIt<ProductRemoteDataSource>()),
  );

  getIt.registerLazySingleton<PreferencesRepository>(
    () => PreferencesRepositoryImpl(getIt<LocalStorage>()),
  );
}
