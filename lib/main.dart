import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logbook_app_087/services/mongo_service.dart'; // Pastikan nama package benar
import 'package:logbook_app_087/features/onboarding/onboarding_view.dart'; // Import halaman awal

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Load Environment Variables
  await dotenv.load(fileName: ".env");

  // 2. Inisialisasi Koneksi Database
  final mongoService = MongoService();
  try {
    await mongoService.connect();
  } catch (e) {
    // ignore: avoid_print
    print("Error Koneksi di Main: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hilangkan pita DEBUG merah
      title: 'Logbook App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // [DISINI KUNCINYA] Kembalikan ke OnboardingView
      home: const OnboardingView(), 
    );
  }
}