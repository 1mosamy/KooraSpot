import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/bookings/presentation/cubit/booking_cubit.dart';

import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/verify_otp_screen.dart';
import '../../features/auth/presentation/screens/verify_register_otp_screen.dart';
import '../../features/bookings/presentation/screens/player_booking_history_screen.dart';
import '../../features/courts/presentation/screens/stadium_details_screen.dart';
import '../../features/owner_dashboard/presentation/screens/owner_dashboard_screen.dart';
import '../../features/owner_fields/presentation/screens/add_court_modal.dart';
import '../../features/owner_fields/presentation/screens/edit_field_screen.dart';
import '../../features/owner_fields/presentation/screens/my_fields_screen.dart';
import '../../features/owner_wallet/presentation/screens/owner_earnings_screen.dart';
import '../../features/player_home/presentation/screens/player_home_screen.dart';
import '../../features/profile/presentation/screens/owner_edit_profile_screen.dart';
import '../../features/profile/presentation/screens/owner_profile_screen.dart';
import '../../features/profile/presentation/screens/player_edit_profile_screen.dart';
import '../../features/profile/presentation/screens/player_profile_screen.dart';
import '../../features/saved_courts/presentation/screens/saved_courts_screen.dart';
import '../../features/slots/presentation/screens/manage_slots_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import 'route_names.dart';

/// GoRouter configuration with role-based shell routes.
class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _playerShellKey = GlobalKey<NavigatorState>();
  static final _ownerShellKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.splashPath,
    debugLogDiagnostics: true,
    routes: [
      // ── Splash ─────────────────────────────────────────
      GoRoute(
        path: RouteNames.splashPath,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // ── Auth ───────────────────────────────────────────
      GoRoute(
        path: RouteNames.loginPath,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.registerPath,
        name: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPasswordPath,
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.verifyOtpPath,
        name: RouteNames.verifyOtp,
        builder: (context, state) => const VerifyOtpScreen(),
      ),
      GoRoute(
        path: RouteNames.resetPasswordPath,
        name: RouteNames.resetPassword,
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.verifyRegisterOtpPath,
        name: RouteNames.verifyRegisterOtp,
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return VerifyRegisterOtpScreen(email: email);
        },
      ),

      // ── Player Shell ───────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return PlayerShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _playerShellKey,
            routes: [
              GoRoute(
                path: '/player/home',
                name: RouteNames.playerHome,
                builder: (context, state) => const PlayerHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/player/bookings',
                name: RouteNames.playerBookings,
                builder: (context, state) =>
                    const PlayerBookingHistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/player/saved',
                name: RouteNames.playerSaved,
                builder: (context, state) => const SavedCourtsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/player/profile',
                name: RouteNames.playerProfile,
                builder: (context, state) => const PlayerProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // ── Player standalone routes ───────────────────────
      GoRoute(
        path: RouteNames.playerEditProfilePath,
        name: RouteNames.playerEditProfile,
        builder: (context, state) => const PlayerEditProfileScreen(),
      ),
      GoRoute(
        path: RouteNames.stadiumDetailsPath,
        name: RouteNames.stadiumDetails,
        builder: (context, state) {
          final stadiumId = state.pathParameters['stadiumId'] ?? '';
          return StadiumDetailsScreen(stadiumId: stadiumId);
        },
      ),

      // ── Owner Shell ────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return OwnerShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _ownerShellKey,
            routes: [
              GoRoute(
                path: '/owner/dashboard',
                name: RouteNames.ownerDashboard,
                builder: (context, state) => const OwnerDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/owner/fields',
                name: RouteNames.ownerFields,
                builder: (context, state) => const MyFieldsScreen(),
              ),
            ],
          ),
          // ── Earnings tab (4th) ──────────────────────────
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/owner/earnings',
                name: RouteNames.ownerEarnings,
                builder: (context, state) => const OwnerEarningsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/owner/profile',
                name: RouteNames.ownerProfile,
                builder: (context, state) => const OwnerProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // ── Owner standalone routes ────────────────────────
      GoRoute(
        path: RouteNames.ownerEditProfilePath,
        name: RouteNames.ownerEditProfile,
        builder: (context, state) => const OwnerEditProfileScreen(),
      ),
      GoRoute(
        path: RouteNames.ownerAddFieldPath,
        name: RouteNames.ownerAddField,
        builder: (context, state) => const AddCourtModal(),
      ),
      GoRoute(
        path: RouteNames.ownerEditFieldPath,
        name: RouteNames.ownerEditField,
        builder: (context, state) {
          final fieldId = state.pathParameters['fieldId'] ?? '';
          return EditFieldScreen(fieldId: fieldId);
        },
      ),
      GoRoute(
        path: RouteNames.ownerManageSlotsPath,
        name: RouteNames.ownerManageSlots,
        builder: (context, state) {
          final fieldId = state.pathParameters['fieldId'] ?? '';
          return ManageSlotsScreen(fieldId: fieldId);
        },
      ),
    ],
  );
}

/// Player shell with bottom nav.
class PlayerShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const PlayerShellScreen({super.key, required this.navigationShell});

  void _onTabTap(BuildContext context, int index) {
    // Force-refresh bookings when switching to Bookings tab
    if (index == 1) {
      context.read<BookingCubit>().loadMyBookings(forceRefresh: true);
    }
    navigationShell.goBranch(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade100),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: navigationShell.currentIndex == 0,
                  onTap: () => _onTabTap(context, 0),
                ),
                _NavItem(
                  icon: Icons.calendar_month_rounded,
                  label: 'Bookings',
                  isSelected: navigationShell.currentIndex == 1,
                  onTap: () => _onTabTap(context, 1),
                ),
                _NavItem(
                  icon: Icons.favorite_rounded,
                  label: 'Saved',
                  isSelected: navigationShell.currentIndex == 2,
                  onTap: () => _onTabTap(context, 2),
                ),
                _NavItem(
                  icon: Icons.account_circle_rounded,
                  label: 'Profile',
                  isSelected: navigationShell.currentIndex == 3,
                  onTap: () => _onTabTap(context, 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Owner shell with bottom nav (4 tabs: Dashboard, Courts, Earnings, Profile).
class OwnerShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const OwnerShellScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade100),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  isSelected: navigationShell.currentIndex == 0,
                  onTap: () => navigationShell.goBranch(0),
                ),
                _NavItem(
                  icon: Icons.stadium_rounded,
                  label: 'Courts',
                  isSelected: navigationShell.currentIndex == 1,
                  onTap: () => navigationShell.goBranch(1),
                ),
                _NavItem(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Earnings',
                  isSelected: navigationShell.currentIndex == 2,
                  onTap: () => navigationShell.goBranch(2),
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  isSelected: navigationShell.currentIndex == 3,
                  onTap: () => navigationShell.goBranch(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : Colors.grey.shade400;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
