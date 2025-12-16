import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ FIXED: Get current user ID with better checking
  String? get currentUserId {
    final user = _auth.currentUser;
    if (user == null) {
      print('⚠️ Warning: No user currently logged in');
      return null;
    }
    return user.uid;
  }

  // ✅ FIXED: Collection reference dengan better error handling
  CollectionReference? _transactionsCollection() {
    final userId = currentUserId;
    if (userId == null) {
      print('❌ Cannot access transactions collection - no user logged in');
      return null;
    }
    print('✅ Accessing transactions for user: $userId');
    return _db.collection('users').doc(userId).collection('transactions');
  }

  // ==================== CREATE ====================
  
  /// Tambah transaksi baru
  Future<String> addTransaction(TransactionModel transaction) async {
    try {
      final collection = _transactionsCollection();
      if (collection == null) {
        throw Exception('User not logged in');
      }

      print('💾 Adding transaction for user: $currentUserId');

      // Pastikan userId di-set
      transaction = transaction.copyWith(userId: currentUserId);

      DocumentReference docRef = await collection.add(transaction.toMap());
      
      print('✅ Transaction added with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error adding transaction: $e');
      rethrow;
    }
  }

  // ==================== READ ====================

  /// Get semua transaksi user (Real-time Stream)
  Stream<List<TransactionModel>> getTransactions() {
    try {
      final collection = _transactionsCollection();
      if (collection == null) {
        print('❌ No user logged in for getTransactions');
        return Stream.value([]);
      }

      print('🔍 Getting all transactions for user: $currentUserId');

      return collection
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
            print('📊 Found ${snapshot.docs.length} total transactions');
            return snapshot.docs
                .map((doc) => TransactionModel.fromFirestore(doc))
                .toList();
          });
    } catch (e) {
      print('❌ Error getting transactions: $e');
      return Stream.value([]);
    }
  }

  /// ✅ FIXED: Get transaksi per bulan dengan better user checking
  Stream<List<TransactionModel>> getTransactionsByMonth(int year, int month) {
    try {
      final collection = _transactionsCollection();
      if (collection == null) {
        print('❌ No user logged in for getTransactionsByMonth');
        return Stream.value([]);
      }

      DateTime startDate = DateTime(year, month, 1);
      DateTime endDate = DateTime(year, month + 1, 0, 23, 59, 59);

      print('🔍 Getting transactions for $month/$year');
      print('📅 Date range: $startDate to $endDate');

      return collection
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
            print('📊 Found ${snapshot.docs.length} transactions for $month/$year');
            return snapshot.docs
                .map((doc) => TransactionModel.fromFirestore(doc))
                .toList();
          })
          .handleError((error) {
            print('❌ Stream error in getTransactionsByMonth: $error');
            return <TransactionModel>[];
          });
    } catch (e) {
      print('❌ Error getting transactions by month: $e');
      return Stream.value([]);
    }
  }

  /// Get transaksi per tanggal (Real-time Stream) - untuk calendar
  Stream<List<TransactionModel>> getTransactionsByDate(DateTime date) {
    try {
      final collection = _transactionsCollection();
      if (collection == null) {
        print('❌ No user logged in for getTransactionsByDate');
        return Stream.value([]);
      }

      DateTime startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
      DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      print('🔍 Getting transactions for ${date.day}/${date.month}/${date.year}');

      return collection
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
            print('📊 Found ${snapshot.docs.length} transactions for this date');
            return snapshot.docs
                .map((doc) => TransactionModel.fromFirestore(doc))
                .toList();
          });
    } catch (e) {
      print('❌ Error getting transactions by date: $e');
      return Stream.value([]);
    }
  }

  /// Get single transaksi by ID
  Future<TransactionModel?> getTransactionById(String id) async {
    try {
      final collection = _transactionsCollection();
      if (collection == null) {
        print('❌ No user logged in for getTransactionById');
        return null;
      }

      DocumentSnapshot doc = await collection.doc(id).get();
      
      if (doc.exists) {
        return TransactionModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('❌ Error getting transaction by id: $e');
      return null;
    }
  }

  // ==================== UPDATE ====================

  /// Update transaksi
  Future<void> updateTransaction(String id, TransactionModel transaction) async {
    try {
      final collection = _transactionsCollection();
      if (collection == null) {
        throw Exception('User not logged in');
      }

      print('📝 Updating transaction: $id');
      await collection.doc(id).update(transaction.toMap());
      print('✅ Transaction updated successfully');
    } catch (e) {
      print('❌ Error updating transaction: $e');
      rethrow;
    }
  }

  // ==================== DELETE ====================

  /// Hapus transaksi
  Future<void> deleteTransaction(String id) async {
    try {
      final collection = _transactionsCollection();
      if (collection == null) {
        throw Exception('User not logged in');
      }

      print('🗑️ Deleting transaction: $id');
      await collection.doc(id).delete();
      print('✅ Transaction deleted successfully');
    } catch (e) {
      print('❌ Error deleting transaction: $e');
      rethrow;
    }
  }

  // ==================== CALCULATIONS ====================

  /// ✅ FIXED: Hitung total expense per bulan
  Future<double> getTotalExpenseByMonth(int year, int month) async {
    try {
      final collection = _transactionsCollection();
      if (collection == null) {
        print('❌ No user logged in for getTotalExpenseByMonth');
        return 0;
      }

      DateTime startDate = DateTime(year, month, 1);
      DateTime endDate = DateTime(year, month + 1, 0, 23, 59, 59);

      print('💰 Calculating expense for $month/$year');

      QuerySnapshot snapshot = await collection
          .where('type', isEqualTo: 'expense')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      double total = 0;
      for (var doc in snapshot.docs) {
        final amount = ((doc.data() as Map<String, dynamic>)['amount'] ?? 0).toDouble();
        total += amount;
      }
      
      print('✅ Total expense: $total (${snapshot.docs.length} transactions)');
      return total;
    } catch (e) {
      print('❌ Error getting total expense: $e');
      return 0;
    }
  }

  /// ✅ FIXED: Hitung total income per bulan
  Future<double> getTotalIncomeByMonth(int year, int month) async {
    try {
      final collection = _transactionsCollection();
      if (collection == null) {
        print('❌ No user logged in for getTotalIncomeByMonth');
        return 0;
      }

      DateTime startDate = DateTime(year, month, 1);
      DateTime endDate = DateTime(year, month + 1, 0, 23, 59, 59);

      print('💰 Calculating income for $month/$year');

      QuerySnapshot snapshot = await collection
          .where('type', isEqualTo: 'income')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      double total = 0;
      for (var doc in snapshot.docs) {
        final amount = ((doc.data() as Map<String, dynamic>)['amount'] ?? 0).toDouble();
        total += amount;
      }
      
      print('✅ Total income: $total (${snapshot.docs.length} transactions)');
      return total;
    } catch (e) {
      print('❌ Error getting total income: $e');
      return 0;
    }
  }

  /// Hitung total expense per tanggal - untuk calendar
  Future<double> getTotalExpenseByDate(DateTime date) async {
    try {
      final collection = _transactionsCollection();
      if (collection == null) {
        print('❌ No user logged in for getTotalExpenseByDate');
        return 0;
      }

      DateTime startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
      DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      print('💰 Calculating expense for ${date.day}/${date.month}/${date.year}');

      QuerySnapshot snapshot = await collection
          .where('type', isEqualTo: 'expense')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      double total = 0;
      for (var doc in snapshot.docs) {
        final amount = ((doc.data() as Map<String, dynamic>)['amount'] ?? 0).toDouble();
        total += amount;
      }
      
      print('✅ Total expense for date: $total (${snapshot.docs.length} transactions)');
      return total;
    } catch (e) {
      print('❌ Error getting total expense by date: $e');
      return 0;
    }
  }

  /// Hitung total income per tanggal - untuk calendar
  Future<double> getTotalIncomeByDate(DateTime date) async {
    try {
      final collection = _transactionsCollection();
      if (collection == null) {
        print('❌ No user logged in for getTotalIncomeByDate');
        return 0;
      }

      DateTime startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
      DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      print('💰 Calculating income for ${date.day}/${date.month}/${date.year}');

      QuerySnapshot snapshot = await collection
          .where('type', isEqualTo: 'income')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      double total = 0;
      for (var doc in snapshot.docs) {
        final amount = ((doc.data() as Map<String, dynamic>)['amount'] ?? 0).toDouble();
        total += amount;
      }
      
      print('✅ Total income for date: $total (${snapshot.docs.length} transactions)');
      return total;
    } catch (e) {
      print('❌ Error getting total income by date: $e');
      return 0;
    }
  }

  /// Get daftar tanggal yang memiliki transaksi dalam 1 bulan - untuk calendar
  Future<List<int>> getTransactionDates(int year, int month) async {
    try {
      final collection = _transactionsCollection();
      if (collection == null) {
        print('❌ No user logged in for getTransactionDates');
        return [];
      }

      DateTime startDate = DateTime(year, month, 1);
      DateTime endDate = DateTime(year, month + 1, 0, 23, 59, 59);

      print('📅 Getting transaction dates for $month/$year');

      QuerySnapshot snapshot = await collection
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      Set<int> dates = {};
      for (var doc in snapshot.docs) {
        Timestamp timestamp = (doc.data() as Map<String, dynamic>)['date'];
        DateTime date = timestamp.toDate();
        dates.add(date.day);
      }

      List<int> sortedDates = dates.toList()..sort();
      print('✅ Found transactions on dates: $sortedDates');
      return sortedDates;
    } catch (e) {
      print('❌ Error getting transaction dates: $e');
      return [];
    }
  }

  /// Get balance per bulan
  Future<double> getBalanceByMonth(int year, int month) async {
    double income = await getTotalIncomeByMonth(year, month);
    double expense = await getTotalExpenseByMonth(year, month);
    print('💵 Balance: $income - $expense = ${income - expense}');
    return income - expense;
  }

  // ==================== STATISTICS ====================

  /// Get transaksi per kategori (untuk chart)
  Future<Map<String, double>> getExpenseByCategory(int year, int month) async {
    try {
      final collection = _transactionsCollection();
      if (collection == null) {
        return {};
      }

      DateTime startDate = DateTime(year, month, 1);
      DateTime endDate = DateTime(year, month + 1, 0, 23, 59, 59);

      QuerySnapshot snapshot = await collection
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
      print('❌ Error getting expense by category: $e');
      return {};
    }
  }

  /// Get total semua transaksi (untuk overall statistics)
  Future<Map<String, double>> getTotalAllTime() async {
    try {
      final collection = _transactionsCollection();
      if (collection == null) {
        return {'expense': 0, 'income': 0, 'balance': 0};
      }

      QuerySnapshot expenseSnapshot = await collection
          .where('type', isEqualTo: 'expense')
          .get();

      QuerySnapshot incomeSnapshot = await collection
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
      print('❌ Error getting total all time: $e');
      return {'expense': 0, 'income': 0, 'balance': 0};
    }
  }

  // ==================== DEBUG METHODS ====================

  /// Test Firestore connection
  Future<bool> testFirestoreConnection() async {
    try {
      final collection = _transactionsCollection();
      if (collection == null) {
        print('❌ Cannot test connection - no user logged in');
        return false;
      }
      
      await collection.limit(1).get();
      print('✅ Firestore connection successful');
      return true;
    } catch (e) {
      print('❌ Firestore connection failed: $e');
      return false;
    }
  }

  /// Get all transactions untuk debugging
  Future<List<TransactionModel>> getAllTransactions() async {
    try {
      final collection = _transactionsCollection();
      if (collection == null) {
        print('❌ No user logged in');
        return [];
      }

      QuerySnapshot snapshot = await collection
          .orderBy('date', descending: true)
          .get();

      print('📊 Total transactions in database: ${snapshot.docs.length}');
      
      return snapshot.docs.map((doc) {
        return TransactionModel.fromFirestore(doc);
      }).toList();
    } catch (e) {
      print('❌ Error getting all transactions: $e');
      return [];
    }
  }

  /// Debug current user info
  void debugCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      print('👤 Current user: ${user.uid}');
      print('📧 Email: ${user.email}');
      print('📍 Collection path: users/${user.uid}/transactions');
    } else {
      print('❌ No user logged in');
    }
  }
}