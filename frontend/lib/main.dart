import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/homepage.dart'; // 홈 화면 import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  print("Loaded environment variables: ${dotenv.env}");
  print("SUPABASE_URL: ${dotenv.env['SUPABASE_URL']}");
  print("SUPABASE_API_KEY: ${dotenv.env['SUPABASE_API_KEY']}");
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_API_KEY'];

  if (supabaseUrl == null || supabaseAnonKey == null) {
    throw Exception("Supabase URL or Anon Key is missing in .env file");
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  runApp(MachineDex());
}

class MachineDex extends StatelessWidget {
  const MachineDex({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const Home(title: 'MachineDex'), 
    );
  }
}