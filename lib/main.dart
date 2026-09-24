import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:laza/firebase_options.dart';
import 'package:laza/core/theme/app_theme.dart';
import 'package:laza/presentation/screens/splash_screen.dart';

// Services
import 'package:laza/data/services/auth_service.dart';
import 'package:laza/data/services/firestore_service.dart';
import 'package:laza/data/services/api_service.dart';
import 'package:laza/data/services/wishlist_service.dart';
import 'package:laza/data/services/cart_service.dart';
import 'package:laza/data/services/order_service.dart';
import 'package:laza/data/services/review_service.dart';

// Repositories
import 'package:laza/data/repositories/auth_repository.dart';
import 'package:laza/data/repositories/product_repository.dart';
import 'package:laza/data/repositories/wishlist_repository.dart';
import 'package:laza/data/repositories/cart_repository.dart';
import 'package:laza/data/repositories/order_repository.dart';
import 'package:laza/data/repositories/review_repository.dart';

// BLoCs
import 'package:laza/logic/auth/auth_bloc.dart';
import 'package:laza/logic/auth/auth_event.dart';
import 'package:laza/logic/auth/auth_state.dart';
import 'package:laza/logic/theme/theme_bloc.dart';
import 'package:laza/logic/theme/theme_state.dart';
import 'package:laza/logic/product/product_bloc.dart';
import 'package:laza/logic/wishlist/wishlist_bloc.dart';
import 'package:laza/logic/wishlist/wishlist_event.dart';
import 'package:laza/logic/cart/cart_bloc.dart';
import 'package:laza/logic/cart/cart_event.dart';
import 'package:laza/logic/order/order_bloc.dart';
import 'package:laza/logic/order/order_event.dart';
import 'package:laza/logic/review/review_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // Services
        RepositoryProvider(create: (_) => AuthService()),
        RepositoryProvider(create: (_) => FirestoreService()),
        RepositoryProvider(create: (_) => ApiService()),
        RepositoryProvider(create: (_) => WishlistService()),
        RepositoryProvider(create: (_) => CartService()),
        RepositoryProvider(create: (_) => OrderService()),
        RepositoryProvider(create: (_) => ReviewService()),

        // Repositories
        RepositoryProvider(
          create: (ctx) => AuthRepository(
            authService: ctx.read<AuthService>(),
            firestoreService: ctx.read<FirestoreService>(),
          ),
        ),
        RepositoryProvider(
          create: (ctx) => ProductRepository(api: ctx.read<ApiService>()),
        ),
        RepositoryProvider(
          create: (ctx) =>
              WishlistRepository(service: ctx.read<WishlistService>()),
        ),
        RepositoryProvider(
          create: (ctx) => CartRepository(service: ctx.read<CartService>()),
        ),
        RepositoryProvider(
          create: (ctx) => OrderRepository(service: ctx.read<OrderService>()),
        ),
        RepositoryProvider(
          create: (ctx) =>
              ReviewRepository(service: ctx.read<ReviewService>()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (ctx) => AuthBloc(
              authRepository: ctx.read<AuthRepository>(),
            )..add(const AuthCheckRequested()),
          ),
          BlocProvider(create: (_) => ThemeBloc()),
          BlocProvider(
            create: (ctx) => ProductBloc(
              repository: ctx.read<ProductRepository>(),
            ),
          ),
          BlocProvider(
            create: (ctx) => WishlistBloc(
              repository: ctx.read<WishlistRepository>(),
            ),
          ),
          BlocProvider(
            create: (ctx) => CartBloc(
              repository: ctx.read<CartRepository>(),
            ),
          ),
          BlocProvider(
            create: (ctx) => OrderBloc(
              repository: ctx.read<OrderRepository>(),
            ),
          ),
          BlocProvider(
            create: (ctx) => ReviewBloc(
              repository: ctx.read<ReviewRepository>(),
            ),
          ),
        ],
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            return _AuthWatcher(
              child: MaterialApp(
                title: 'Laza',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeState.isDark
                    ? ThemeMode.dark
                    : ThemeMode.light,
                home: const SplashScreen(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AuthWatcher extends StatefulWidget {
  final Widget child;
  const _AuthWatcher({required this.child});

  @override
  State<_AuthWatcher> createState() => _AuthWatcherState();
}

class _AuthWatcherState extends State<_AuthWatcher> {
  String? _subscribedUid;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          final uid = state.user.uid;
          if (_subscribedUid == uid) return;
          _subscribedUid = uid;

          context.read<WishlistBloc>().add(WishlistSubscribed(uid));
          context.read<CartBloc>().add(CartSubscribed(uid));
          context.read<OrderBloc>().add(OrdersSubscribed(uid));
        } else if (state is Unauthenticated) {
          _subscribedUid = null;
        }
      },
      child: widget.child,
    );
  }
}