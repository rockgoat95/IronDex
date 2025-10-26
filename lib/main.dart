import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:irondex/providers/auth_provider.dart';
import 'package:irondex/providers/provider_setup.dart';
import 'package:irondex/screens/auth/auth_screen.dart';
import 'package:irondex/screens/main/main_screen.dart';
import 'package:irondex/screens/splash/splash_screen.dart';
import 'package:irondex/services/service_locator.dart';
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
  ServiceLocator.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final services = ServiceLocator.instance;

    return MultiProvider(
      providers: buildAppProviders(services),
      child: MaterialApp(
        title: 'IronDex',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        home: const SplashScreen(buildNext: AuthGate.builder),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  static Widget builder(BuildContext context) => const AuthGate();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return authProvider.isLoggedIn ? const MainScreen() : const AuthScreen();
  }
}
