import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/user.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/main/home_screen.dart';
import '../../presentation/screens/main/discovery_screen.dart';
import '../../presentation/screens/main/review_screen.dart';
import '../../presentation/screens/main/chat_screen.dart';
import '../../presentation/screens/main/profile_screen.dart';
import '../../presentation/widgets/navigation/main_shell.dart';

/// Provider for the GoRouter instance
final routerProvider = Provider<GoRouter>((ref) {
  return AppRouter(ref).router;
});

/// App router configuration with authentication and navigation structure
class AppRouter {
  final Ref _ref;

  AppRouter(this._ref);

  /// Main router instance
  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(_ref.watch(authStateProvider)),
    redirect: _redirect,
    routes: [
      // Authentication routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main app shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) =>
                _buildPageWithTransition(context, state, const HomeScreen()),
          ),
          GoRoute(
            path: '/discovery',
            name: 'discovery',
            pageBuilder: (context, state) => _buildPageWithTransition(
              context,
              state,
              const DiscoveryScreen(),
            ),
          ),
          GoRoute(
            path: '/review',
            name: 'review',
            pageBuilder: (context, state) =>
                _buildPageWithTransition(context, state, const ReviewScreen()),
          ),
          GoRoute(
            path: '/chat',
            name: 'chat',
            pageBuilder: (context, state) => _buildPageWithTransition(
              context,
              state,
              ChatScreen(wordContext: state.extra as Map<String, dynamic>?),
            ),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) =>
                _buildPageWithTransition(context, state, const ProfileScreen()),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Page not found',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'The page "${state.matchedLocation}" could not be found.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    ),
  );

  /// Redirect logic for authentication
  String? _redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authStateProvider);

    return authState.when(
      data: (user) => _handleAuthRedirect(user, state.matchedLocation),
      loading: () => null, // Keep current location while loading
      error: (_, __) => _handleAuthRedirect(null, state.matchedLocation),
    );
  }

  /// Handle authentication-based redirects
  String? _handleAuthRedirect(User? user, String currentLocation) {
    final isAuthenticated = user != null;
    final isAuthRoute =
        currentLocation.startsWith('/login') ||
        currentLocation.startsWith('/register');

    // If user is authenticated and on auth route, redirect to home
    if (isAuthenticated && isAuthRoute) {
      return '/home';
    }

    // If user is not authenticated and not on auth route, redirect to login
    if (!isAuthenticated && !isAuthRoute) {
      return '/login';
    }

    // No redirect needed
    return null;
  }

  /// Build page with smooth transition animation
  Page<dynamic> _buildPageWithTransition(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0.05, 0),
                  end: Offset.zero,
                ).animate(
                  CurveTween(curve: Curves.easeOutCubic).animate(animation),
                ),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
    );
  }
}

/// Custom GoRouterRefreshStream to handle Riverpod AsyncValue
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(AsyncValue<User?> authState) {
    notifyListeners();
    // Listen to auth state changes by checking the value periodically
    // In a real implementation, you might want to use a more sophisticated approach
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      notifyListeners();
    });
  }

  late final Timer _timer;

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
