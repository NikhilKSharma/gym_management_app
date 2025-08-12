import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gymanager/src/config/app_router.dart';
import 'package:gymanager/src/config/app_colors.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // --- START: Session Logic ---
  const storage = FlutterSecureStorage();
  final token = await storage.read(key: 'jwt_token');
  final initialLocation = token != null ? '/home' : '/login';
  // --- END: Session Logic ---

  // Create the router with the correct initial location
  final router = AppRouter.createRouter(initialLocation: initialLocation);

  runApp(MyApp(router: router));
}

class MyApp extends StatelessWidget {
  final GoRouter router; // Accept the router as a parameter

  const MyApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Gymanager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          // ... your existing theme data ...
          ),
      routerConfig: router, // Use the router passed into the widget
    );
  }
}
