// lib/services/account_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/account_model.dart';

class AccountService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference get _accountsCollection {
    return _firestore.collection('accounts');
  }

  // Get all accounts for current user
  Stream<List<AccountModel>> getUserAccounts() {
    if (_userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('accounts')
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AccountModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get accounts as Future
  Future<List<AccountModel>> getUserAccountsFuture() async {
    if (_userId == null) {
      return [];
    }

    final snapshot = await _firestore
        .collection('accounts')
        .where('userId', isEqualTo: _userId)
        .get();

    return snapshot.docs
        .map((doc) => AccountModel.fromFirestore(doc))
        .toList();
  }

  // Create default accounts for new user
  Future<void> createDefaultAccounts() async {
    if (_userId == null) return;

    final existing = await _firestore
        .collection('accounts')
        .where('userId', isEqualTo: _userId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      print('✅ Accounts already exist for user');
      return;
    }

    final defaultAccounts = [
      {
        'userId': _userId!,
        'id': 'gopay',
        'name': 'GoPay',
        'iconName': 'account_balance_wallet',
        'colorHex': '#4CAF50',
        'balance': 0.0,
        'accountType': 'E-Wallet',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'userId': _userId!,
        'id': 'dana',
        'name': 'Dana',
        'iconName': 'account_balance_wallet',
        'colorHex': '#03A9F4',
        'balance': 0.0,
        'accountType': 'E-Wallet',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'userId': _userId!,
        'id': 'cash',
        'name': 'Cash',
        'iconName': 'money',
        'colorHex': '#FF9800',
        'balance': 0.0,
        'accountType': 'Cash',
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    final batch = _firestore.batch();
    for (final accountData in defaultAccounts) {
      final docRef = _firestore.collection('accounts').doc();
      batch.set(docRef, accountData);
    }

    await batch.commit();
    print('✅ Default accounts created successfully');
  }

  // Create new account
  Future<void> createAccount(AccountModel account) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      print('🔍 Creating account for user: $_userId');
      print('📝 Account name: ${account.name}');
      print('📝 Account type: ${account.accountType}');

      final docRef = _accountsCollection.doc();

      final accountData = {
        'userId': _userId!,
        'id': account.id.isNotEmpty ? account.id : docRef.id,
        'name': account.name,
        'iconName': account.iconName,
        'colorHex': account.colorHex,
        'balance': account.balance,
        'accountType': account.accountType,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await docRef.set(accountData);
      print('✅ Account created successfully');
    } catch (e) {
      print('❌ Error creating account: $e');
      rethrow;
    }
  }

  // Update account
  Future<void> updateAccount(String docId, Map<String, dynamic> updates) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      print('🔍 Updating account docId: $docId');
      
      if (docId.isEmpty) {
        throw Exception('Document ID is empty');
      }

      final doc = await _accountsCollection.doc(docId).get();
      
      if (!doc.exists) {
        throw Exception('Account not found');
      }

      final data = doc.data() as Map<String, dynamic>;
      if (data['userId'] != _userId) {
        throw Exception('Unauthorized: This account does not belong to you');
      }

      final updateData = {
        ...updates,
        'userId': _userId!,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _accountsCollection.doc(docId).update(updateData);
      print('✅ Account updated successfully');
    } catch (e) {
      print('❌ Error updating account: $e');
      rethrow;
    }
  }

  // Delete account
  Future<void> deleteAccount(String docId) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      print('🔍 Deleting account docId: $docId');
      
      if (docId.isEmpty) {
        throw Exception('Document ID is empty');
      }

      final doc = await _accountsCollection.doc(docId).get();
      
      if (!doc.exists) {
        throw Exception('Account not found');
      }

      final data = doc.data() as Map<String, dynamic>;
      if (data['userId'] != _userId) {
        throw Exception('Unauthorized: This account does not belong to you');
      }

      await _accountsCollection.doc(docId).delete();
      print('✅ Account deleted successfully');
    } catch (e) {
      print('❌ Error deleting account: $e');
      rethrow;
    }
  }

  // Update account balance
  Future<void> updateAccountBalance(String docId, double newBalance) async {
    if (_userId == null) return;

    try {
      if (docId.isEmpty) {
        print('❌ Document ID is empty');
        return;
      }

      final doc = await _accountsCollection.doc(docId).get();
      
      if (!doc.exists) {
        print('❌ Account not found: $docId');
        return;
      }

      final data = doc.data() as Map<String, dynamic>;
      if (data['userId'] != _userId) {
        print('❌ Unauthorized access');
        return;
      }

      await _accountsCollection.doc(docId).update({
        'balance': newBalance,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Account balance updated: $docId = $newBalance');
    } catch (e) {
      print('❌ Error updating balance: $e');
    }
  }

  // Increment account balance
  Future<void> incrementAccountBalance(String docId, double amount) async {
    if (_userId == null) return;

    try {
      if (docId.isEmpty) {
        print('❌ Document ID is empty');
        return;
      }

      final doc = await _accountsCollection.doc(docId).get();
      
      if (!doc.exists) {
        print('❌ Account not found: $docId');
        return;
      }

      final data = doc.data() as Map<String, dynamic>;
      if (data['userId'] != _userId) {
        print('❌ Unauthorized access');
        return;
      }

      await _accountsCollection.doc(docId).update({
        'balance': FieldValue.increment(amount),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Account balance incremented: $docId += $amount');
    } catch (e) {
      print('❌ Error incrementing balance: $e');
    }
  }

  // Process transfer
  Future<void> processTransfer(
    String sourceDocId,
    String destinationDocId,
    double amount,
  ) async {
    if (_userId == null) return;

    try {
      if (sourceDocId.isEmpty || destinationDocId.isEmpty) {
        throw Exception('Document IDs cannot be empty');
      }

      final sourceDocs = await _accountsCollection.doc(sourceDocId).get();
      final destDocs = await _accountsCollection.doc(destinationDocId).get();

      if (!sourceDocs.exists || !destDocs.exists) {
        throw Exception('Source or destination account not found');
      }

      final sourceData = sourceDocs.data() as Map<String, dynamic>;
      final destData = destDocs.data() as Map<String, dynamic>;

      if (sourceData['userId'] != _userId || destData['userId'] != _userId) {
        throw Exception('Unauthorized access');
      }

      final batch = _firestore.batch();

      batch.update(_accountsCollection.doc(sourceDocId), {
        'balance': FieldValue.increment(-amount),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      batch.update(_accountsCollection.doc(destinationDocId), {
        'balance': FieldValue.increment(amount),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      print('✅ Transfer processed');
    } catch (e) {
      print('❌ Error processing transfer: $e');
      rethrow;
    }
  }

  // Get total balance
  Future<double> getTotalBalance() async {
    final accounts = await getUserAccountsFuture();
    return accounts.fold<double>(0.0, (sum, account) => sum + account.balance);
  }

  // Get account by docId
  Future<AccountModel?> getAccountById(String docId) async {
    if (_userId == null) return null;

    try {
      if (docId.isEmpty) return null;

      final doc = await _accountsCollection.doc(docId).get();

      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      if (data['userId'] != _userId) return null;

      return AccountModel.fromFirestore(doc);
    } catch (e) {
      print('❌ Error getting account: $e');
      return null;
    }
  }

  // Migration: Add accountType to existing accounts
  Future<void> migrateAccountsToAddAccountType() async {
    if (_userId == null) return;

    try {
      print('🔄 Starting migration...');
      
      final snapshot = await _firestore
          .collection('accounts')
          .where('userId', isEqualTo: _userId)
          .get();

      final batch = _firestore.batch();
      int count = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        
        if (data['accountType'] == null) {
          String accountType = 'Default';
          final name = (data['name'] ?? '').toString().toLowerCase();
          
          if (name.contains('gopay') || name.contains('dana') || 
              name.contains('ovo') || name.contains('shopee')) {
            accountType = 'E-Wallet';
          } else if (name.contains('cash') || name.contains('tunai')) {
            accountType = 'Cash';
          } else if (name.contains('credit')) {
            accountType = 'Credit Card';
          } else if (name.contains('debit')) {
            accountType = 'Debit Card';
          }
          
          batch.update(doc.reference, {
            'accountType': accountType,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          
          count++;
          print('✅ Migrating: ${data['name']} -> $accountType');
        }
      }

      if (count > 0) {
        await batch.commit();
        print('✅ Migration completed: $count accounts updated');
      } else {
        print('✅ No migration needed');
      }
    } catch (e) {
      print('❌ Migration error: $e');
    }
  }
}