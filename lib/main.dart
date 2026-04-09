import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GoogleSignIn.instance.initialize(
    serverClientId:
        "198038988856-qvtn6ndkam35r406p9rmgqbtrj1d3fki.apps.googleusercontent.com",
  );
  runApp(const CrowdTrackApp());
}

class CrowdTrackApp extends StatelessWidget {
  const CrowdTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CrowdTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF4F4F0),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1c1917), // stone-900 equivalent
          primary: const Color(0xFF1c1917),
          surface: Colors.white,
        ),
        fontFamily: GoogleFonts.inter().fontFamily,
        textTheme: TextTheme(
          displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          displayMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          displaySmall: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          headlineMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          headlineSmall: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF1c1917)),
            ),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return const DashboardScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
