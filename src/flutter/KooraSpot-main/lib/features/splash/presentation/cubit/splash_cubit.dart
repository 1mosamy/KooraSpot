import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final AuthRepository _authRepository;
  final ProfileCubit? _profileCubit;

  SplashCubit({
    required AuthRepository authRepository,
    ProfileCubit? profileCubit,
  })  : _authRepository = authRepository,
        _profileCubit = profileCubit,
        super(const SplashInitial());

  Future<void> checkAuthStatus() async {
    emit(const SplashChecking());
    await Future.delayed(const Duration(seconds: 2)); // splash animation time

    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        final role = await _authRepository.getSavedRole();
        // Load the cached profile immediately on startup so the home screen has it ready
        _profileCubit?.loadCachedProfile();
        emit(SplashAuthenticated(role: role ?? 'Player'));
      } else {
        emit(const SplashUnauthenticated());
      }
    } catch (_) {
      emit(const SplashUnauthenticated());
    }
  }
}
