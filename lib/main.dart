import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/auth/register_page.dart';
import 'category_selection_page.dart';
import 'add_notes_page.dart';
import 'home_page.dart';
import 'profile_screen.dart';
import 'manage_accounts_page.dart';
import 'add_edit_account_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
    print('✅ Firebase initialized successfully');

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
  
  await initializeDateFormatting('id_ID', null);
  
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
      // ✅ PENTING: AuthWrapper sebagai home untuk auto-redirect
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfileScreen(),
        '/category-selection': (context) => const CategorySelectionPage(),
        '/add-notes': (context) => const AddNotesPage(),
        '/manage-accounts': (context) => const ManageAccountsPage(),
        '/add-account': (context) => const AddEditAccountPage(),
        '/edit-account': (context) {
          final account = ModalRoute.of(context)!.settings.arguments as dynamic;
          return AddEditAccountPage(account: account);
        },
      },
    );
  }
}

// ✅ AuthWrapper - Handles automatic navigation based on auth state
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
        
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('⏳ Loading authentication state...');
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFF1976D2),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        // Error state
        if (snapshot.hasError) {
          print('❌ Error: ${snapshot.error}');
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Authentication Error',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AuthWrapper(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Retry',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        
        // ✅ User is logged in - go to HomePage
        if (snapshot.hasData && snapshot.data != null) {
          print('✅ User logged in: ${snapshot.data!.email}');
          print('👤 User ID: ${snapshot.data!.uid}');
          return const HomePage();
        }
        
        // ✅ No user logged in - go to LoginPage
        print('⚠️ No user logged in, showing LoginPage');
        return const LoginPage();
      },
    );
  }
}