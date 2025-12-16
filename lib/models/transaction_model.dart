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
  });

  // ✅ Getter untuk IconData dan Color
  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);

  // ✅ Convert to Map untuk Firestore
  Map<String, dynamic> toMap() {
    return {
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

      final model = TransactionModel(
        id: doc.id,
        userId: data['userId'] as String? ?? '',
        amount: amount,
        category: data['category'] as String? ?? 'Unknown',
        type: data['type'] as String? ?? 'expense',
        date: date,
        note: data['note'] as String?,
        iconCodePoint: data['iconCodePoint'] as int? ?? Icons.help.codePoint,
        colorValue: data['colorValue'] as int? ?? 0xFFB0BEC5,
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

      return TransactionModel(
        id: id,
        userId: map['userId'] as String? ?? '',
        amount: amount,
        category: map['category'] as String? ?? 'Unknown',
        type: map['type'] as String? ?? 'expense',
        date: date,
        note: map['note'] as String?,
        iconCodePoint: map['iconCodePoint'] as int? ?? Icons.help.codePoint,
        colorValue: map['colorValue'] as int? ?? 0xFFB0BEC5,
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