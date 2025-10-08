import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:irondex/providers/auth_provider.dart';
import 'package:irondex/providers/machine_favorite_provider.dart';
import 'package:irondex/providers/review_like_provider.dart';
import 'package:irondex/screens/auth/auth_screen.dart';
import 'package:irondex/screens/main/main_screen.dart';
import 'package:irondex/services/review_repository.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_API_KEY'];

  if (supabaseUrl == null || supabaseAnonKey == null) {
    throw Exception("Supabase URL or Anon Key is missing in .env file");
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        Provider(create: (_) => ReviewRepository()),
        ChangeNotifierProxyProvider2<
          AuthProvider,
          ReviewRepository,
          MachineFavoriteProvider
        >(
          create: (_) => MachineFavoriteProvider(),
          update: (_, auth, repository, previous) {
            final provider = previous ?? MachineFavoriteProvider();
            provider.updateDependencies(
              authProvider: auth,
              repository: repository,
            );
            return provider;
          },
        ),
        ChangeNotifierProxyProvider2<
          AuthProvider,
          ReviewRepository,
          ReviewLikeProvider
        >(
          create: (_) => ReviewLikeProvider(),
          update: (_, auth, repository, previous) {
            final provider = previous ?? ReviewLikeProvider();
            provider.updateDependencies(
              authProvider: auth,
              repository: repository,
            );
            return provider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'IronDex',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        home: const _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return authProvider.isLoggedIn ? const MainScreen() : const AuthScreen();
  }
}
