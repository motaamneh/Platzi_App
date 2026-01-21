import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/route_constants.dart';
import 'features/authentication/data/repositories/auth_repository.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/authentication/presentation/pages/auth_page.dart';
import 'features/products/data/repositories/product_repository.dart';
import 'features/products/presentation/bloc/product_bloc.dart';
import 'features/products/presentation/pages/home_page.dart';
import 'features/products/presentation/pages/product_detail_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/splash/presentation/pages/splash_page.dart';
import 'features/theme/theme_cubit.dart';
import 'managers/logger_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    LoggerManager().info('Firebase initialized successfully');
  } catch (e) {
    LoggerManager().error('Firebase initialization failed', e);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => AuthRepository(),
        ),
        RepositoryProvider(
          create: (context) => ProductRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ThemeCubit(),
          ),
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          BlocProvider<ProductBloc>(
            create: (context) => ProductBloc(
              productRepository: context.read<ProductRepository>(),
            ),
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp(
              title: 'Product Manager',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              initialRoute: RouteConstants.splash,
              onGenerateRoute: _generateRoute,
            );
          },
        ),
      ),
    );
  }

  static Route<dynamic> _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteConstants.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashPage(),
        );

      case RouteConstants.auth:
        return MaterialPageRoute(
          builder: (_) => const AuthPage(),
        );

      case RouteConstants.home:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
        );

      case RouteConstants.productDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ProductDetailPage(
            productId: args?['productId'] ?? 0,
          ),
        );

      case RouteConstants.profile:
        return MaterialPageRoute(
          builder: (_) => const ProfilePage(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
