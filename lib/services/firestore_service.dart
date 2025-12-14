import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Collection reference untuk transaksi user
  CollectionReference _transactionsCollection() {
    if (currentUserId == null) {
      throw Exception('User not logged in');
    }
    return _db.collection('users').doc(currentUserId).collection('transactions');
  }

  // ==================== CREATE ====================
  
  /// Tambah transaksi baru
  Future<String> addTransaction(TransactionModel transaction) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not logged in');
      }

      // Pastikan userId di-set
      transaction = transaction.copyWith(userId: currentUserId);

      DocumentReference docRef = await _transactionsCollection().add(transaction.toMap());
      
      return docRef.id;
    } catch (e) {
      print('Error adding transaction: $e');
      rethrow;
    }
  }

  // ==================== READ ====================

  /// Get semua transaksi user (Real-time Stream)
  Stream<List<TransactionModel>> getTransactions() {
    try {
      return _transactionsCollection()
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => TransactionModel.fromFirestore(doc))
              .toList());
    } catch (e) {
      print('Error getting transactions: $e');
      return Stream.value([]);
    }
  }

  /// Get transaksi per bulan (Real-time Stream)
  Stream<List<TransactionModel>> getTransactionsByMonth(int year, int month) {
    try {
      DateTime startDate = DateTime(year, month, 1);
      DateTime endDate = DateTime(year, month + 1, 0, 23, 59, 59);

      return _transactionsCollection()
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => TransactionModel.fromFirestore(doc))
              .toList());
    } catch (e) {
      print('Error getting transactions by month: $e');
      return Stream.value([]);
    }
  }

  /// Get single transaksi by ID
  Future<TransactionModel?> getTransactionById(String id) async {
    try {
      DocumentSnapshot doc = await _transactionsCollection().doc(id).get();
      
      if (doc.exists) {
        return TransactionModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting transaction by id: $e');
      return null;
    }
  }

  // ==================== UPDATE ====================

  /// Update transaksi
  Future<void> updateTransaction(String id, TransactionModel transaction) async {
    try {
      await _transactionsCollection().doc(id).update(transaction.toMap());
    } catch (e) {
      print('Error updating transaction: $e');
      rethrow;
    }
  }

  // ==================== DELETE ====================

  /// Hapus transaksi
  Future<void> deleteTransaction(String id) async {
    try {
      await _transactionsCollection().doc(id).delete();
    } catch (e) {
      print('Error deleting transaction: $e');
      rethrow;
    }
  }

  // ==================== CALCULATIONS ====================

  /// Hitung total expense per bulan
  Future<double> getTotalExpenseByMonth(int year, int month) async {
    try {
      DateTime startDate = DateTime(year, month, 1);
      DateTime endDate = DateTime(year, month + 1, 0, 23, 59, 59);

      QuerySnapshot snapshot = await _transactionsCollection()
          .where('type', isEqualTo: 'expense')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      double total = 0;
      for (var doc in snapshot.docs) {
        total += ((doc.data() as Map<String, dynamic>)['amount'] ?? 0).toDouble();
      }
      return total;
    } catch (e) {
      print('Error getting total expense: $e');
      return 0;
    }
  }

  /// Hitung total income per bulan
  Future<double> getTotalIncomeByMonth(int year, int month) async {
    try {
      DateTime startDate = DateTime(year, month, 1);
      DateTime endDate = DateTime(year, month + 1, 0, 23, 59, 59);

      QuerySnapshot snapshot = await _transactionsCollection()
          .where('type', isEqualTo: 'income')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      double total = 0;
      for (var doc in snapshot.docs) {
        total += ((doc.data() as Map<String, dynamic>)['amount'] ?? 0).toDouble();
      }
      return total;
    } catch (e) {
      print('Error getting total income: $e');
      return 0;
    }
  }

  /// Get balance per bulan
  Future<double> getBalanceByMonth(int year, int month) async {
    double income = await getTotalIncomeByMonth(year, month);
    double expense = await getTotalExpenseByMonth(year, month);
    return income - expense;
  }

  // ==================== STATISTICS ====================

  /// Get transaksi per kategori (untuk chart)
  Future<Map<String, double>> getExpenseByCategory(int year, int month) async {
    try {
      DateTime startDate = DateTime(year, month, 1);
      DateTime endDate = DateTime(year, month + 1, 0, 23, 59, 59);

      QuerySnapshot snapshot = await _transactionsCollection()
          .where('type', isEqualTo: 'expense')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      Map<String, double> categoryTotals = {};

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String category = data['category'] ?? 'Other';
        double amount = (data['amount'] ?? 0).toDouble();

        categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
      }

      return categoryTotals;
    } catch (e) {
      print('Error getting expense by category: $e');
      return {};
    }
  }

  /// Get total semua transaksi (untuk overall statistics)
  Future<Map<String, double>> getTotalAllTime() async {
    try {
      QuerySnapshot expenseSnapshot = await _transactionsCollection()
          .where('type', isEqualTo: 'expense')
          .get();

      QuerySnapshot incomeSnapshot = await _transactionsCollection()
          .where('type', isEqualTo: 'income')
          .get();

      double totalExpense = 0;
      for (var doc in expenseSnapshot.docs) {
        totalExpense += ((doc.data() as Map<String, dynamic>)['amount'] ?? 0).toDouble();
      }

      double totalIncome = 0;
      for (var doc in incomeSnapshot.docs) {
        totalIncome += ((doc.data() as Map<String, dynamic>)['amount'] ?? 0).toDouble();
      }

      return {
        'expense': totalExpense,
        'income': totalIncome,
        'balance': totalIncome - totalExpense,
      };
    } catch (e) {
      print('Error getting total all time: $e');
      return {'expense': 0, 'income': 0, 'balance': 0};
    }
  }
}