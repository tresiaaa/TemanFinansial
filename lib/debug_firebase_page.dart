import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class DebugFirebasePage extends StatefulWidget {
  const DebugFirebasePage({super.key});

  @override
  State<DebugFirebasePage> createState() => _DebugFirebasePageState();
}

class _DebugFirebasePageState extends State<DebugFirebasePage> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String _debugLog = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _runDebugChecks();
  }

  void _addLog(String message) {
    setState(() {
      _debugLog += '$message\n';
    });
    print(message);
  }

  Future<void> _runDebugChecks() async {
    setState(() {
      _isLoading = true;
      _debugLog = '🔍 Starting Firebase Debug...\n\n';
    });

    // 1. Check Firebase Auth
    _addLog('=== FIREBASE AUTH ===');
    final user = _auth.currentUser;
    if (user != null) {
      _addLog('✅ User logged in');
      _addLog('   User ID: ${user.uid}');
      _addLog('   Email: ${user.email}');
    } else {
      _addLog('❌ No user logged in');
    }
    _addLog('');

    // 2. Check Firestore Connection
    _addLog('=== FIRESTORE CONNECTION ===');
    final isConnected = await _firestoreService.testFirestoreConnection();
    if (isConnected) {
      _addLog('✅ Firestore connection successful');
    } else {
      _addLog('❌ Firestore connection failed');
    }
    _addLog('');

    // 3. Check Total Transactions
    _addLog('=== ALL TRANSACTIONS ===');
    final allTransactions = await _firestoreService.getAllTransactions();
    _addLog('Total transactions: ${allTransactions.length}');
    
    if (allTransactions.isNotEmpty) {
      _addLog('\nTransactions:');
      for (var transaction in allTransactions.take(5)) {
        _addLog('  • ${transaction.category}: ${transaction.amount} (${transaction.type})');
      }
      if (allTransactions.length > 5) {
        _addLog('  ... and ${allTransactions.length - 5} more');
      }
    } else {
      _addLog('⚠️ No transactions found in database');
    }
    _addLog('');

    // 4. Check Current Month Totals
    _addLog('=== CURRENT MONTH TOTALS ===');
    final now = DateTime.now();
    final totalExpense = await _firestoreService.getTotalExpenseByMonth(now.year, now.month);
    final totalIncome = await _firestoreService.getTotalIncomeByMonth(now.year, now.month);
    
    _addLog('Month: ${now.month}/${now.year}');
    _addLog('Total Expense: $totalExpense');
    _addLog('Total Income: $totalIncome');
    _addLog('Balance: ${totalIncome - totalExpense}');
    _addLog('');

    // 5. Check Firestore Structure
    _addLog('=== FIRESTORE STRUCTURE ===');
    if (user != null) {
      _addLog('Collection path: users/${user.uid}/transactions');
      _addLog('This app uses SUBCOLLECTION structure');
    }
    _addLog('');

    // 6. Troubleshooting
    _addLog('=== TROUBLESHOOTING ===');
    if (user == null) {
      _addLog('❌ You need to login first');
    } else if (allTransactions.isEmpty) {
      _addLog('⚠️ Database is empty. Try adding a transaction.');
      _addLog('   Path should be: users/${user.uid}/transactions');
    } else if (totalExpense == 0 && totalIncome == 0) {
      _addLog('⚠️ No transactions for current month.');
      _addLog('   Try selecting a different month.');
    } else {
      _addLog('✅ Everything looks good!');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Debug'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _runDebugChecks,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: SelectableText(
                      _debugLog,
                      style: const TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Quick Actions
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  ElevatedButton.icon(
                    onPressed: () {
                      _firestoreService.debugCurrentUser();
                      _runDebugChecks();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Debug Info'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  ElevatedButton.icon(
                    onPressed: () async {
                      final user = _auth.currentUser;
                      if (user != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('User ID: ${user.uid}'),
                            duration: const Duration(seconds: 3),
                            action: SnackBarAction(
                              label: 'Copy',
                              onPressed: () {
                                // Copy to clipboard would go here
                              },
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.person),
                    label: const Text('Show User Info'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Troubleshooting Tips
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'Troubleshooting Tips',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '1. Make sure you are logged in\n'
                          '2. Check your Firestore rules allow read/write\n'
                          '3. Try adding a test transaction\n'
                          '4. Check if the month has any transactions\n'
                          '5. Verify your Firebase configuration',
                          style: TextStyle(fontSize: 14, height: 1.8),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}