part of 'splash_cubit.dart';

sealed class SplashState extends Equatable {
  const SplashState();
  @override
  List<Object?> get props => [];
}

class SplashInitial extends SplashState {
  const SplashInitial();
}

class SplashChecking extends SplashState {
  const SplashChecking();
}

class SplashAuthenticated extends SplashState {
  final String role;
  const SplashAuthenticated({required this.role});
  @override
  List<Object?> get props => [role];
}

class SplashUnauthenticated extends SplashState {
  const SplashUnauthenticated();
}
