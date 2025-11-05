import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:ninerapp/dependency_inyection.dart';
import 'package:ninerapp/presentation/screens/main_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");
  String supabaseUrl = dotenv.env['SUPABASE_URL']!;
  String supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;
  Stripe.publishableKey = dotenv.env['STRIPE_PUBLIC_KEY']!;

  // TODO abrir en info de servicio el mapa y la ubicacion donde es el servicio

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw Exception("No se encontró el archivo .env o no están las variables de supabase");
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  setupDependencies();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NiñerApp',
      home: MainScreen()
    );
  }
}
