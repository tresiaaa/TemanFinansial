import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String userId;
  final double amount;
  final String category;
  final String type; // 'expense', 'income', or 'transfer'
  final DateTime date;
  final String? note;
  final int iconCodePoint;
  final int colorValue;
  
  // Transfer specific fields
  final String? sourceAccount;
  final String? sourceAccountId;
  final String? destinationAccount;
  final String? destinationAccountId;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
    this.note,
    required this.iconCodePoint,
    required this.colorValue,
    this.sourceAccount,
    this.sourceAccountId,
    this.destinationAccount,
    this.destinationAccountId,
  });

  // ✅ Getter untuk IconData dan Color
  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);

  // ✅ Helper method untuk get icon dari category
  static IconData getCategoryIcon(String category, String type) {
    if (type == 'transfer') {
      return Icons.swap_horiz;
    } else if (type == 'income') {
      switch (category.toLowerCase()) {
        case 'salary':
          return Icons.credit_card;
        case 'investment':
          return Icons.trending_up;
        case 'part-time':
          return Icons.access_time;
        case 'bonus':
          return Icons.monetization_on;
        default:
          return Icons.more_horiz;
      }
    } else {
      // Expense icons
      switch (category.toLowerCase()) {
        case 'shopping':
          return Icons.shopping_cart;
        case 'food':
          return Icons.restaurant;
        case 'phone':
          return Icons.phone_android;
        case 'education':
          return Icons.school;
        case 'beauty':
          return Icons.content_cut;
        case 'sport':
          return Icons.directions_run;
        case 'social':
          return Icons.group;
        case 'clothing':
          return Icons.checkroom;
        case 'car':
          return Icons.directions_car;
        case 'alcohol':
          return Icons.local_bar;
        case 'cigarettes':
          return Icons.smoking_rooms;
        case 'transport':
          return Icons.directions_bus;
        case 'electronics':
          return Icons.power_settings_new;
        case 'repairs':
          return Icons.home_repair_service;
        case 'travel':
          return Icons.flight;
        case 'pets':
          return Icons.pets;
        case 'health':
          return Icons.local_hospital;
        case 'housing':
          return Icons.home_work;
        case 'gifts':
          return Icons.card_giftcard;
        case 'donations':
          return Icons.volunteer_activism;
        case 'lottery':
          return Icons.confirmation_number;
        case 'snacks':
          return Icons.fastfood;
        case 'kids':
          return Icons.child_care;
        case 'vegetables':
          return Icons.eco;
        case 'fruits':
          return Icons.apple;
        case 'entertainment':
          return Icons.theater_comedy;
        case 'home':
          return Icons.cottage;
        default:
          return Icons.attach_money;
      }
    }
  }

  // ✅ Helper method untuk get color dari type
  static Color getCategoryColor(String type) {
    switch (type) {
      case 'income':
        return const Color(0xFF81C784);
      case 'transfer':
        return const Color(0xFF0277BD);
      case 'expense':
      default:
        return const Color(0xFFE57373);
    }
  }

  // ✅ Convert to Map untuk Firestore
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'userId': userId,
      'amount': amount,
      'category': category,
      'type': type,
      'date': Timestamp.fromDate(date),
      'note': note,
      'iconCodePoint': iconCodePoint,
      'colorValue': colorValue,
      'createdAt': FieldValue.serverTimestamp(),
    };
    
    // Add transfer-specific fields if applicable
    if (type == 'transfer') {
      map.addAll({
        'sourceAccount': sourceAccount,
        'sourceAccountId': sourceAccountId,
        'destinationAccount': destinationAccount,
        'destinationAccountId': destinationAccountId,
      });
    }
    
    return map;
  }

  // ✅ Create from Firestore DocumentSnapshot
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    try {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      
      // Parse date dari Timestamp
      DateTime date;
      if (data['date'] is Timestamp) {
        date = (data['date'] as Timestamp).toDate();
      } else if (data['date'] is String) {
        date = DateTime.parse(data['date']);
      } else {
        date = DateTime.now();
        print('⚠️ Warning: Invalid date format, using current time');
      }

      // Parse amount
      final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
      
      // Parse type
      String type = data['type'] as String? ?? 'expense';
      
      // Parse category - untuk transfer, gabungkan sourceAccount dan destinationAccount
      String category;
      if (type == 'transfer') {
        category = '${data['sourceAccount'] ?? ''} → ${data['destinationAccount'] ?? ''}';
      } else {
        category = data['category'] as String? ?? 'Unknown';
      }

      final model = TransactionModel(
        id: doc.id,
        userId: data['userId'] as String? ?? '',
        amount: amount,
        category: category,
        type: type,
        date: date,
        note: data['note'] as String?,
        iconCodePoint: data['iconCodePoint'] as int? ?? Icons.help.codePoint,
        colorValue: data['colorValue'] as int? ?? 0xFFB0BEC5,
        sourceAccount: data['sourceAccount'] as String?,
        sourceAccountId: data['sourceAccountId'] as String?,
        destinationAccount: data['destinationAccount'] as String?,
        destinationAccountId: data['destinationAccountId'] as String?,
      );

      return model;
    } catch (e) {
      print('❌ Error parsing TransactionModel from doc ${doc.id}: $e');
      print('📄 Document data: ${doc.data()}');
      rethrow;
    }
  }

  // ✅ Create from Map (for compatibility)
  factory TransactionModel.fromMap(Map<String, dynamic> map, String id) {
    try {
      // Parse date dari Timestamp
      DateTime date;
      if (map['date'] is Timestamp) {
        date = (map['date'] as Timestamp).toDate();
      } else if (map['date'] is String) {
        date = DateTime.parse(map['date']);
      } else {
        date = DateTime.now();
      }

      // Parse amount
      final amount = (map['amount'] as num?)?.toDouble() ?? 0.0;
      
      // Parse type
      String type = map['type'] as String? ?? 'expense';
      
      // Parse category
      String category;
      if (type == 'transfer') {
        category = '${map['sourceAccount'] ?? ''} → ${map['destinationAccount'] ?? ''}';
      } else {
        category = map['category'] as String? ?? 'Unknown';
      }

      return TransactionModel(
        id: id,
        userId: map['userId'] as String? ?? '',
        amount: amount,
        category: category,
        type: type,
        date: date,
        note: map['note'] as String?,
        iconCodePoint: map['iconCodePoint'] as int? ?? Icons.help.codePoint,
        colorValue: map['colorValue'] as int? ?? 0xFFB0BEC5,
        sourceAccount: map['sourceAccount'] as String?,
        sourceAccountId: map['sourceAccountId'] as String?,
        destinationAccount: map['destinationAccount'] as String?,
        destinationAccountId: map['destinationAccountId'] as String?,
      );
    } catch (e) {
      print('❌ Error parsing TransactionModel from map: $e');
      print('📄 Map data: $map');
      rethrow;
    }
  }

  // ✅ Copy with method untuk update
  TransactionModel copyWith({
    String? id,
    String? userId,
    double? amount,
    String? category,
    String? type,
    DateTime? date,
    String? note,
    int? iconCodePoint,
    int? colorValue,
    String? sourceAccount,
    String? sourceAccountId,
    String? destinationAccount,
    String? destinationAccountId,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      type: type ?? this.type,
      date: date ?? this.date,
      note: note ?? this.note,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
      sourceAccount: sourceAccount ?? this.sourceAccount,
      sourceAccountId: sourceAccountId ?? this.sourceAccountId,
      destinationAccount: destinationAccount ?? this.destinationAccount,
      destinationAccountId: destinationAccountId ?? this.destinationAccountId,
    );
  }

  // ✅ toString untuk debugging
  @override
  String toString() {
    return 'TransactionModel(id: $id, userId: $userId, amount: $amount, category: $category, type: $type, date: $date)';
  }

  // ✅ Equality operator untuk comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}