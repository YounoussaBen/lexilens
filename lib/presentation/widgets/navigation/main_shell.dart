import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Main shell widget that provides bottom navigation for authenticated routes
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: child, bottomNavigationBar: _BottomNavigationBar());
  }
}

/// Bottom navigation bar with enhanced styling
class _BottomNavigationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: NavigationBar(
          selectedIndex: _calculateSelectedIndex(location),
          onDestinationSelected: (index) => _onItemTapped(context, index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          height: 70,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          indicatorColor: Colors.transparent,
          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.home_outlined,
                size: 26,
                color: _calculateSelectedIndex(location) == 0
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[600],
              ),
              selectedIcon: Icon(
                Icons.home,
                size: 26,
                color: Theme.of(context).colorScheme.primary,
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.center_focus_strong_outlined,
                size: 26,
                color: _calculateSelectedIndex(location) == 1
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[600],
              ),
              selectedIcon: Icon(
                Icons.center_focus_strong,
                size: 26,
                color: Theme.of(context).colorScheme.primary,
              ),
              label: 'Discover',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.psychology_outlined,
                size: 26,
                color: _calculateSelectedIndex(location) == 2
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[600],
              ),
              selectedIcon: Icon(
                Icons.psychology,
                size: 26,
                color: Theme.of(context).colorScheme.primary,
              ),
              label: 'Chat',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.more_vert,
                size: 26,
                color: _calculateSelectedIndex(location) == 3
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[600],
              ),
              selectedIcon: Icon(
                Icons.more_vert,
                size: 26,
                color: Theme.of(context).colorScheme.primary,
              ),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }

  /// Calculate selected index based on current location
  int _calculateSelectedIndex(String location) {
    switch (location) {
      case '/home':
        return 0;
      case '/discovery':
        return 1;
      case '/chat':
        return 2;
      case '/profile':
        return 3;
      default:
        return 0;
    }
  }

  /// Handle navigation bar item tap
  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/discovery');
        break;
      case 2:
        context.go('/chat');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }
}
