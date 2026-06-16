import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
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
    clientId:
        "198038988856-qvtn6ndkam35r406p9rmgqbtrj1d3fki.apps.googleusercontent.com",
    serverClientId:
        "198038988856-qvtn6ndkam35r406p9rmgqbtrj1d3fki.apps.googleusercontent.com",
  );
  runApp(const CrowdTrackApp());
}

class CrowdTrackApp extends StatelessWidget {
  const CrowdTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme lightColorScheme;
        if (lightDynamic != null) {
          lightColorScheme = lightDynamic.harmonized();
        } else {
          lightColorScheme = ColorScheme.fromSeed(
            seedColor: const Color(0xFF1c1917), // stone-900 equivalent
            primary: const Color(0xFF1c1917),
            surface: Colors.white,
          );
        }

        ColorScheme darkColorScheme;
        if (darkDynamic != null) {
          darkColorScheme = darkDynamic.harmonized();
        } else {
          darkColorScheme = ColorScheme.fromSeed(
            seedColor: const Color(0xFF1c1917),
            primary: const Color(0xFF1c1917),
            brightness: Brightness.dark,
          );
        }

        return MaterialApp(
          title: 'CrowdTrack',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: lightColorScheme,
            scaffoldBackgroundColor: lightDynamic == null ? const Color(0xFFF4F4F0) : null,
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
          darkTheme: ThemeData(
            colorScheme: darkColorScheme,
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
      },
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
