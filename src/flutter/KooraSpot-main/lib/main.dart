import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/di/service_locator.dart';
import 'app/router/app_router.dart';
import 'app/theme/app_theme.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/forgot_password_cubit.dart';
import 'features/bookings/presentation/cubit/booking_cubit.dart';
import 'features/owner_fields/presentation/cubit/owner_fields_cubit.dart';
import 'features/owner_wallet/presentation/cubit/owner_wallet_cubit.dart';
import 'features/player_home/presentation/cubit/player_home_cubit.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';
import 'features/saved_courts/presentation/cubit/saved_courts_cubit.dart';
import 'features/slots/presentation/cubit/slots_cubit.dart';
import 'features/splash/presentation/cubit/splash_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize dependency injection
  await initServiceLocator();

  runApp(const KooraSpotApp());
}

class KooraSpotApp extends StatelessWidget {
  const KooraSpotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<SplashCubit>()),
        BlocProvider(create: (_) => sl<AuthCubit>()),
        BlocProvider(create: (_) => sl<ForgotPasswordCubit>()),
        BlocProvider(create: (_) => sl<ProfileCubit>()),
        BlocProvider(create: (_) => sl<PlayerHomeCubit>()),
        BlocProvider(create: (_) => sl<BookingCubit>()),
        BlocProvider(create: (_) => sl<SavedCourtsCubit>()),
        BlocProvider(create: (_) => sl<OwnerFieldsCubit>()),
        BlocProvider(create: (_) => sl<SlotsCubit>()),
        BlocProvider(create: (_) => sl<OwnerWalletCubit>()),
      ],
      child: MaterialApp.router(
        title: 'KooraSpot',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
