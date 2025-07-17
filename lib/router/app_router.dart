import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:madinaapp/authentication/authentication.dart';
import 'package:madinaapp/home/home.dart';
import 'package:madinaapp/models/models.dart';

class AppRoutes {
  static const String login = '/login';
  static const String clientHome = '/client-home';
  static const String shopOwnerHome = '/shop-owner-home';
  static const String logisticHome = '/logistic-home';
}

class AppRouter {
  static GoRouter router({
    required GlobalKey<NavigatorState> navigatorKey,
    required Stream<User?> authStateStream,
  }) {
    return GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: AppRoutes.login,
      redirect: (context, state) {
        // This will be handled by the GoRouter listener
        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: AppRoutes.clientHome,
          builder: (context, state) => const ClientHomePage(),
        ),
        GoRoute(
          path: AppRoutes.shopOwnerHome,
          builder: (context, state) => const ShopOwnerHomePage(),
        ),
        GoRoute(
          path: AppRoutes.logisticHome,
          builder: (context, state) => const LogisticHomePage(),
        ),
      ],
    );
  }

  static String getHomeRouteForUser(User user) {
    switch (user.role) {
      case UserRole.client:
        return AppRoutes.clientHome;
      case UserRole.shopOwner:
        return AppRoutes.shopOwnerHome;
      case UserRole.logistic:
        return AppRoutes.logisticHome;
    }
  }
}
