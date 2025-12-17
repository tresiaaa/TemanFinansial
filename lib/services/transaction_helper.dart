import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  // Get all transactions (including transfers) for display
  Stream<List<Map<String, dynamic>>> getTransactionsStream() {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('transactions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> transactions = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        Map<String, dynamic> transaction = {
          'id': doc.id,
          ...data,
        };

        // If it's a transfer, get wallet names
        if (data['type'] == 'transfer') {
          final sourceWallet = await _getWalletName(data['sourceWalletId']);
          final destWallet = await _getWalletName(data['destinationWalletId']);
          
          transaction['sourceWalletName'] = sourceWallet;
          transaction['destinationWalletName'] = destWallet;
        }

        transactions.add(transaction);
      }

      return transactions;
    });
  }

  Future<String> _getWalletName(String walletId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('wallets')
          .doc(walletId)
          .get();
      
      if (doc.exists) {
        return doc.data()?['name'] ?? 'Unknown';
      }
      return 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  // Get transactions for a specific date
  Stream<List<Map<String, dynamic>>> getTransactionsByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('transactions')
        .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
        .where('createdAt', isLessThanOrEqualTo: endOfDay)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> transactions = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        Map<String, dynamic> transaction = {
          'id': doc.id,
          ...data,
        };

        if (data['type'] == 'transfer') {
          final sourceWallet = await _getWalletName(data['sourceWalletId']);
          final destWallet = await _getWalletName(data['destinationWalletId']);
          
          transaction['sourceWalletName'] = sourceWallet;
          transaction['destinationWalletName'] = destWallet;
        }

        transactions.add(transaction);
      }

      return transactions;
    });
  }

  // Format currency
  String formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  // Get display text for transaction
  String getTransactionTitle(Map<String, dynamic> transaction) {
    if (transaction['type'] == 'transfer') {
      return 'Transfer: ${transaction['sourceWalletName']} → ${transaction['destinationWalletName']}';
    } else if (transaction['type'] == 'expense') {
      return transaction['category'] ?? 'Expense';
    } else if (transaction['type'] == 'income') {
      return transaction['category'] ?? 'Income';
    }
    return 'Transaction';
  }

  // Get icon for transaction type
  String getTransactionIcon(Map<String, dynamic> transaction) {
    if (transaction['type'] == 'transfer') {
      return 'swap_horiz';
    } else if (transaction['type'] == 'expense') {
      return 'arrow_downward';
    } else if (transaction['type'] == 'income') {
      return 'arrow_upward';
    }
    return 'payments';
  }

  // Get color for transaction type
  String getTransactionColor(Map<String, dynamic> transaction) {
    if (transaction['type'] == 'transfer') {
      return 'blue';
    } else if (transaction['type'] == 'expense') {
      return 'red';
    } else if (transaction['type'] == 'income') {
      return 'green';
    }
    return 'grey';
  }
}