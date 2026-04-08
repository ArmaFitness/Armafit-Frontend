import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/weight_provider.dart';
import 'providers/workout_plan_provider.dart';
import 'providers/workout_session_provider.dart';
import 'providers/coach_athlete_provider.dart';
import 'providers/message_provider.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authProvider = AuthProvider();
  await authProvider.init();
  runApp(ArmaFitApp(authProvider: authProvider));
}

class ArmaFitApp extends StatelessWidget {
  final AuthProvider authProvider;
  const ArmaFitApp({super.key, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => WeightProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutPlanProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutSessionProvider()),
        ChangeNotifierProvider(create: (_) => CoachAthleteProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
      ],
      child: MaterialApp.router(
        title: 'ArmaFit',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFE65100),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFE65100),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        routerConfig: _buildRouter(),
      ),
    );
  }

  GoRouter _buildRouter() {
    return GoRouter(
      refreshListenable: authProvider,
      redirect: (context, state) {
        if (!authProvider.initialized) return null;
        final isAuth = authProvider.isAuthenticated;
        final loc = state.matchedLocation;
        final onAuthScreen =
            loc == '/login' || loc == '/register';
        if (!isAuth && !onAuthScreen) return '/login';
        if (isAuth && onAuthScreen) return '/';
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (_, __) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (_, __) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/',
          builder: (_, __) => const HomeScreen(),
        ),
      ],
    );
  }
}
