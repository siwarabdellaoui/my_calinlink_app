import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Imports des screens
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/verify_email_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/reset_password_screen.dart';
import '../../features/auth/screens/google_account_picker_screen.dart';
import '../../features/auth/screens/apple_signin_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/surveillance/screens/surveillance_screen.dart';
import '../../features/camera/screens/camera_screen.dart';
import '../../features/control/screens/control_screen.dart';
import '../../features/alerts/screens/alerts_screen.dart';
import '../../features/stats/screens/stats_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/settings/screens/add_device_screen.dart';
import '../../features/settings/screens/night_mode_screen.dart';
import '../../features/sharing/screens/sharing_screen.dart';
import '../layout/main_shell.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const verifyEmail = '/verify-email';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const google = '/google';
  static const apple = '/apple';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const surveillance = '/home/surveillance';
  static const camera = '/home/camera';
  static const control = '/home/control';
  static const alerts = '/home/alerts';
  static const stats = '/home/stats';
  static const settings = '/home/settings';
  static const profile = '/home/settings/profile';
  static const addDevice = '/home/settings/add-device';
  static const nightMode = '/home/settings/night-mode';
  static const sharing = '/home/settings/sharing';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (c, s) => const SplashScreen()),
      GoRoute(path: AppRoutes.login, builder: (c, s) => const LoginScreen()),
      GoRoute(
          path: AppRoutes.register, builder: (c, s) => const RegisterScreen()),
      GoRoute(
        path: AppRoutes.verifyEmail,
        builder: (c, s) {
          final email = s.extra as String?;
          return VerifyEmailScreen(email: email ?? '');
        },
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (c, s) {
          final resetToken = s.extra as String?;
          return ResetPasswordScreen(resetToken: resetToken ?? '');
        },
      ),
      GoRoute(
          path: AppRoutes.forgotPassword,
          builder: (c, s) => const ForgotPasswordScreen()),
      GoRoute(
          path: AppRoutes.google,
          builder: (c, s) => const GoogleAccountPickerScreen()),
      GoRoute(
          path: AppRoutes.apple, builder: (c, s) => const AppleSignInScreen()),
      ShellRoute(
        builder: (c, s, child) => MainShell(child: child),
        routes: [
          GoRoute(path: AppRoutes.home, builder: (c, s) => const HomeScreen()),
          GoRoute(
              path: AppRoutes.surveillance,
              builder: (c, s) => const SurveillanceScreen()),
          GoRoute(
              path: AppRoutes.camera, builder: (c, s) => const CameraScreen()),
          GoRoute(
              path: AppRoutes.control,
              builder: (c, s) => const ControlScreen()),
          GoRoute(
              path: AppRoutes.alerts, builder: (c, s) => const AlertsScreen()),
          GoRoute(
              path: AppRoutes.stats, builder: (c, s) => const StatsScreen()),
          GoRoute(
              path: AppRoutes.settings,
              builder: (c, s) => const SettingsScreen()),
          GoRoute(
              path: AppRoutes.profile,
              builder: (c, s) => const ProfileScreen()),
          GoRoute(
              path: AppRoutes.nightMode,
              builder: (c, s) => const NightModeScreen()),
          GoRoute(
              path: AppRoutes.addDevice,
              builder: (c, s) => const AddDeviceScreen()),
          GoRoute(
              path: AppRoutes.sharing,
              builder: (c, s) => const SharingScreen()),
        ],
      ),
    ],
  );
});
