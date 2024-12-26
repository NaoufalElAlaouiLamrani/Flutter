import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'pages/auth_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Nécessaire pour les opérations async
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Utilise votre config Firebase
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blagues Dynamiques',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const AuthPage(), // Page d'authentification
    );
  }
}
