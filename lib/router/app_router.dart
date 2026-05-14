import 'package:flutter/material.dart';

import '../screens/main_shell.dart';

// ---------------------------------------------------------------------------
// Placeholder screens – replaced as real screens are implemented.
// Each placeholder shows its route name so navigation can be verified early.
// ---------------------------------------------------------------------------

class _Placeholder extends StatelessWidget {
  const _Placeholder(this.name);
  final String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Center(
        child: Text(
          name,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Route names
// ---------------------------------------------------------------------------

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String summaryLoading = '/summary/loading';
  static const String summaryResult = '/summary/result';
  static const String summaryError = '/summary/error';
  static const String expert = '/expert'; // pass :type via arguments
  static const String cardCreator = '/card-creator';
  static const String paywall = '/paywall';
  static const String referral = '/referral';
  static const String emailWriter = '/email-writer';
  static const String settings = '/settings';
}

// ---------------------------------------------------------------------------
// Router
// ---------------------------------------------------------------------------

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _fade(const _Placeholder('Splash'), settings);

      case AppRoutes.onboarding:
        return _slide(const _Placeholder('Onboarding'), settings);

      case AppRoutes.home:
        return _fade(const MainShell(), settings);

      case AppRoutes.summaryLoading:
        return _slide(const _Placeholder('Summary Loading'), settings);

      case AppRoutes.summaryResult:
        return _slide(const _Placeholder('Summary Result'), settings);

      case AppRoutes.summaryError:
        return _slide(const _Placeholder('Summary Error'), settings);

      case AppRoutes.expert:
        final type = settings.arguments as String? ?? 'general';
        return _slide(_Placeholder('Expert: $type'), settings);

      case AppRoutes.cardCreator:
        return _slide(const _Placeholder('Card Creator'), settings);

      case AppRoutes.paywall:
        return _slideUp(const _Placeholder('Paywall'), settings);

      case AppRoutes.referral:
        return _slide(const _Placeholder('Referral'), settings);

      case AppRoutes.emailWriter:
        return _slide(const _Placeholder('Email Writer'), settings);

      case AppRoutes.settings:
        return _slide(const _Placeholder('Settings'), settings);

      default:
        return _fade(
          const _Placeholder('404 – Route not found'),
          settings,
        );
    }
  }

  // ---- Transition helpers ----

  static PageRouteBuilder<T> _fade<T>(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, animation, _, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }

  static PageRouteBuilder<T> _slide<T>(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, animation, _, child) {
        final tween = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static PageRouteBuilder<T> _slideUp<T>(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, animation, _, child) {
        final tween = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}
