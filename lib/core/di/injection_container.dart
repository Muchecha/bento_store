import 'package:bento_store/core/config/env_config.dart';
import 'package:bento_store/core/services/cache_service_impl.dart';
import 'package:bento_store/core/services/interface/cache_service.dart';
import 'package:bento_store/core/services/interface/secure_storage.dart';
import 'package:bento_store/core/services/network/dio_interceptors.dart';
import 'package:bento_store/core/services/secure_storage_service_impl.dart';
import 'package:bento_store/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:bento_store/features/auth/domain/repositories/auth_repository.dart';
import 'package:bento_store/features/auth/service/cubit/auth_cubit.dart';
import 'package:bento_store/features/product/data/repositories/product_repository_impl.dart';
import 'package:bento_store/features/product/domain/repositories/product_repository.dart';
import 'package:bento_store/features/product/service/cubit/product_cubit.dart';
import 'package:bento_store/features/sale/data/repositories/sale_repository_impl.dart';
import 'package:bento_store/features/sale/domain/repositories/sale_repository.dart';
import 'package:bento_store/features/sale/service/cubit/sale_cubit.dart';
import 'package:bento_store/features/seller/data/repositories/seller_repository_impl.dart';
import 'package:bento_store/features/seller/domain/repositories/seller_repository.dart';
import 'package:bento_store/features/seller/service/cubit/seller_cubit.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt getIt = GetIt.instance;

Future<void> init() async {
  final dio = Dio(
    BaseOptions(
      baseUrl: EnvConfig.apiUrl,
      connectTimeout: Duration(milliseconds: EnvConfig.apiTimeout),
      receiveTimeout: Duration(milliseconds: EnvConfig.apiTimeout),
      sendTimeout: Duration(milliseconds: EnvConfig.apiTimeout),
    ),
  );
  getIt.registerLazySingleton(() => dio);
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);
  getIt.registerLazySingleton(() => const FlutterSecureStorage());

  ///Service
  getIt.registerLazySingleton<SecureStorage>(() => SecureStorageServiceImpl(getIt()));
  getIt.registerLazySingleton<CacheService>(() => CacheServiceImpl(getIt()));

  ///Repositories
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(getIt(), getIt()));
  getIt.registerLazySingleton<SellerRepository>(() => SellerRepositoryImpl(getIt(), getIt()));
  getIt.registerLazySingleton<ProductRepository>(() => ProductRepositoryImpl(getIt(), getIt()));
  getIt.registerLazySingleton<SaleRepository>(() => SaleRepositoryImpl(getIt()));

  /// Dio com interceptadores
  getIt<Dio>().interceptors.add(ErrorInterceptor());
  getIt<Dio>().interceptors.add(RetryInterceptor(dio: getIt()));
  getIt<Dio>().interceptors.add(AuthInterceptor(getIt()));

  /// Cubits
  getIt.registerFactory(() => AuthCubit(repository: getIt()));
  getIt.registerFactory(() => SellerCubit(repository: getIt()));
  getIt.registerFactory(() => ProductCubit(repository: getIt()));
  getIt.registerFactory(() => SaleCubit(repository: getIt()));
}
