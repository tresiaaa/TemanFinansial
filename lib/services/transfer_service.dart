import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransferService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  // Get all wallets for current user
  Future<List<Map<String, dynamic>>> getWallets() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('wallets')
          .orderBy('createdAt')
          .get();

      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc.data()['name'] ?? '',
          'type': doc.data()['type'] ?? '',
          'balance': doc.data()['balance'] ?? 0.0,
          'icon': doc.data()['icon'] ?? '',
        };
      }).toList();
    } catch (e) {
      print('Error getting wallets: $e');
      return [];
    }
  }

  // Initialize default wallets if they don't exist
  Future<void> initializeDefaultWallets() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('wallets')
          .get();

      if (snapshot.docs.isEmpty) {
        final batch = _firestore.batch();
        
        // Default wallets
        final defaultWallets = [
          {
            'name': 'Cash',
            'type': 'cash',
            'balance': 0.0,
            'icon': 'wallet',
            'createdAt': FieldValue.serverTimestamp(),
          },
          {
            'name': 'GoPay',
            'type': 'digital',
            'balance': 0.0,
            'icon': 'gopay',
            'createdAt': FieldValue.serverTimestamp(),
          },
          {
            'name': 'OVO',
            'type': 'digital',
            'balance': 0.0,
            'icon': 'ovo',
            'createdAt': FieldValue.serverTimestamp(),
          },
        ];

        for (var wallet in defaultWallets) {
          final docRef = _firestore
              .collection('users')
              .doc(_userId)
              .collection('wallets')
              .doc();
          batch.set(docRef, wallet);
        }

        await batch.commit();
      }
    } catch (e) {
      print('Error initializing wallets: $e');
    }
  }

  // Create transfer transaction
  Future<bool> createTransfer({
    required String sourceWalletId,
    required String destinationWalletId,
    required double amount,
    String? note,
  }) async {
    try {
      final batch = _firestore.batch();
      
      // Get source wallet
      final sourceDoc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('wallets')
          .doc(sourceWalletId)
          .get();
      
      if (!sourceDoc.exists) {
        throw Exception('Source wallet not found');
      }
      
      final sourceBalance = (sourceDoc.data()?['balance'] ?? 0.0) as double;
      
      if (sourceBalance < amount) {
        throw Exception('Insufficient balance');
      }
      
      // Update source wallet balance
      final sourceRef = _firestore
          .collection('users')
          .doc(_userId)
          .collection('wallets')
          .doc(sourceWalletId);
      
      batch.update(sourceRef, {
        'balance': FieldValue.increment(-amount),
      });
      
      // Update destination wallet balance
      final destRef = _firestore
          .collection('users')
          .doc(_userId)
          .collection('wallets')
          .doc(destinationWalletId);
      
      batch.update(destRef, {
        'balance': FieldValue.increment(amount),
      });
      
      // Create transfer transaction record
      final transferRef = _firestore
          .collection('users')
          .doc(_userId)
          .collection('transactions')
          .doc();
      
      batch.set(transferRef, {
        'type': 'transfer',
        'sourceWalletId': sourceWalletId,
        'destinationWalletId': destinationWalletId,
        'amount': amount,
        'note': note ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'date': DateTime.now().toIso8601String(),
      });
      
      await batch.commit();
      return true;
    } catch (e) {
      print('Error creating transfer: $e');
      return false;
    }
  }

  // Get wallet by ID
  Future<Map<String, dynamic>?> getWalletById(String walletId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('wallets')
          .doc(walletId)
          .get();
      
      if (doc.exists) {
        return {
          'id': doc.id,
          ...doc.data()!,
        };
      }
      return null;
    } catch (e) {
      print('Error getting wallet: $e');
      return null;
    }
  }
}