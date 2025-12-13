import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/auth/register_page.dart';
import 'home_page.dart';
import 'profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp();
    print('✅ Firebase initialized successfully');

    // IMPORTANT: Disable app verification for testing
    // Remove this in production!
    await FirebaseAuth.instance.setSettings(
      appVerificationDisabledForTesting: true,
      forceRecaptchaFlow: false,
    );
    print('✅ App verification disabled for testing');
    
  } catch (e) {
    print('❌ Firebase initialization error: $e');
  }
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  
  runApp(const TemanFinansialApp());
}

class TemanFinansialApp extends StatelessWidget {
  const TemanFinansialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TemanFinansial',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1976D2),
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        fontFamily: 'Poppins',
        useMaterial3: false,
      ),
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    print('🔍 AuthWrapper: Checking authentication state...');
    
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        print('📊 Connection state: ${snapshot.connectionState}');
        print('📊 Has data: ${snapshot.hasData}');
        print('📊 User: ${snapshot.data}');
        
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('⏳ Loading authentication state...');
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading...', style: TextStyle(fontFamily: 'Poppins')),
                ],
              ),
            ),
          );
        }
        
        // Check for errors
        if (snapshot.hasError) {
          print('❌ Error: ${snapshot.error}');
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Try again
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const AuthWrapper()),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        
        // User logged in
        if (snapshot.hasData && snapshot.data != null) {
          print('✅ User logged in: ${snapshot.data!.email}');
          return const HomePage();
        }
        
        // Not logged in
        print('⚠️ No user logged in, showing LoginPage');
        return const LoginPage();
      },
    );
  }
}