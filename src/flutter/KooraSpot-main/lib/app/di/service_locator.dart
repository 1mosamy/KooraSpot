import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/auth_interceptor.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/token_storage.dart';
import '../../core/storage/user_storage.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/repositories/forgot_password_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/repositories/forgot_password_repository.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/forgot_password_cubit.dart';
import '../../features/bookings/data/repositories/remote_booking_repository.dart';
import '../../features/bookings/domain/repositories/booking_repository.dart';
import '../../features/bookings/presentation/cubit/booking_cubit.dart';
import '../../features/courts/data/repositories/remote_court_repository.dart';
import '../../features/courts/domain/repositories/court_repository.dart';
import '../../features/owner_fields/data/repositories/remote_owner_fields_repository.dart';
import '../../features/owner_fields/domain/repositories/owner_fields_repository.dart';
import '../../features/owner_fields/presentation/cubit/owner_fields_cubit.dart';
import '../../features/owner_wallet/data/repositories/remote_owner_wallet_repository.dart';
import '../../features/owner_wallet/domain/repositories/owner_wallet_repository.dart';
import '../../features/owner_wallet/presentation/cubit/owner_wallet_cubit.dart';
import '../../features/player_home/presentation/cubit/player_home_cubit.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/saved_courts/data/repositories/favorites_repository.dart';
import '../../features/saved_courts/data/repositories/remote_favorites_repository.dart';
import '../../features/saved_courts/presentation/cubit/saved_courts_cubit.dart';
import '../../features/slots/data/repositories/remote_slot_repository.dart';
import '../../features/slots/domain/repositories/slot_repository.dart';
import '../../features/slots/presentation/cubit/slots_cubit.dart';
import '../../features/splash/presentation/cubit/splash_cubit.dart';
import '../router/app_router.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // ── External ───────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  // ── Storage ────────────────────────────────────────────
  sl.registerLazySingleton<TokenStorage>(() => TokenStorage());
  sl.registerLazySingleton<UserStorage>(() => UserStorage(sl()));

  // ── Network ────────────────────────────────────────────
  sl.registerLazySingleton<DioClient>(() {
    final client = DioClient();
    client.addInterceptor(
      AuthInterceptor(
        tokenStorage: sl<TokenStorage>(),
        onUnauthorized: () {
          // Navigate to login on 401
          AppRouter.router.go('/login');
        },
      ),
    );
    return client;
  });

  // ── Repositories ───────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      dio: sl<DioClient>().dio,
      tokenStorage: sl(),
      userStorage: sl(),
    ),
  );

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(dio: sl<DioClient>().dio),
  );

  // Real API repositories
  sl.registerLazySingleton<CourtRepository>(
    () => RemoteCourtRepository(
      dio: sl<DioClient>().dio,
    ),
  );
  sl.registerLazySingleton<BookingRepository>(
    () => RemoteBookingRepository(dio: sl<DioClient>().dio),
  );
  sl.registerLazySingleton<OwnerFieldsRepository>(
    () => RemoteOwnerFieldsRepository(dio: sl<DioClient>().dio),
  );
  sl.registerLazySingleton<SlotRepository>(
    () => RemoteSlotRepository(dio: sl<DioClient>().dio),
  );
  sl.registerLazySingleton<ForgotPasswordRepository>(
    () => ForgotPasswordRepositoryImpl(dio: sl<DioClient>().dio),
  );
  sl.registerLazySingleton<FavoritesRepository>(
    () => RemoteFavoritesRepository(dio: sl<DioClient>().dio),
  );
  sl.registerLazySingleton<OwnerWalletRepository>(
    () => RemoteOwnerWalletRepository(dio: sl<DioClient>().dio),
  );

  // ── Cubits ─────────────────────────────────────────────
  // Register ProfileCubit as a LazySingleton so it can be shared and reset by AuthCubit
  sl.registerLazySingleton<ProfileCubit>(
    () => ProfileCubit(
      profileRepository: sl(),
      userStorage: sl(),
    ),
  );

  sl.registerFactory<SplashCubit>(
    () => SplashCubit(
      authRepository: sl(),
      profileCubit: sl(),
    ),
  );

  sl.registerFactory<AuthCubit>(
    () => AuthCubit(
      authRepository: sl(),
      profileCubit: sl(),
    ),
  );

  sl.registerFactory<PlayerHomeCubit>(
    () => PlayerHomeCubit(courtRepository: sl(), userStorage: sl()),
  );

  sl.registerFactory<BookingCubit>(
    () => BookingCubit(
      bookingRepository: sl(),
    ),
  );

  sl.registerFactory<SavedCourtsCubit>(
    () => SavedCourtsCubit(favoritesRepository: sl()),
  );

  sl.registerFactory<ForgotPasswordCubit>(
    () => ForgotPasswordCubit(repository: sl()),
  );

  sl.registerFactory<OwnerFieldsCubit>(
    () => OwnerFieldsCubit(repository: sl()),
  );

  sl.registerFactory<SlotsCubit>(
    () => SlotsCubit(slotRepository: sl()),
  );

  sl.registerFactory<OwnerWalletCubit>(
    () => OwnerWalletCubit(
      walletRepository: sl(),
      fieldsRepository: sl(),
      bookingRepository: sl(),
    ),
  );
}
