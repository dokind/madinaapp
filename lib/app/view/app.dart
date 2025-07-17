import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:madinaapp/authentication/authentication.dart';
import 'package:madinaapp/products/products.dart';
import 'package:madinaapp/cart/cart.dart';
import 'package:madinaapp/l10n/l10n.dart';
import 'package:madinaapp/repositories/repositories.dart';
import 'package:madinaapp/router/router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthenticationRepository()),
        RepositoryProvider(create: (context) => ProductsRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthenticationBloc(
              authenticationRepository:
                  context.read<AuthenticationRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => ProductsBloc(
              productsRepository: context.read<ProductsRepository>(),
            )..add(const ProductsLoaded()),
          ),
          BlocProvider(
            create: (context) => CartBloc(),
          ),
        ],
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.router(
      navigatorKey: _navigatorKey,
      authStateStream: context.read<AuthenticationBloc>().stream.map(
            (state) => state.user,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        switch (state.status) {
          case AuthenticationStatus.authenticated:
            if (state.user != null) {
              final homeRoute = AppRouter.getHomeRouteForUser(state.user!);
              _router.go(homeRoute);
            }
            break;
          case AuthenticationStatus.unauthenticated:
            _router.go('/login');
            break;
          case AuthenticationStatus.initial:
          case AuthenticationStatus.loading:
            break;
        }
      },
      child: MaterialApp.router(
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          appBarTheme: AppBarTheme(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          useMaterial3: true,
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }
}
