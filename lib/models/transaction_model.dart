import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TransactionModel {
  String? id;
  String userId; // ID user yang punya transaksi ini
  String type; // 'expense', 'income', 'transfer'
  String category;
  double amount;
  String? note;
  DateTime date;
  String? fromAccount; // Untuk transfer
  String? toAccount; // Untuk transfer
  int iconCodePoint;
  int colorValue;

  TransactionModel({
    this.id,
    required this.userId,
    required this.type,
    required this.category,
    required this.amount,
    this.note,
    required this.date,
    this.fromAccount,
    this.toAccount,
    required this.iconCodePoint,
    required this.colorValue,
  });

  // Getter untuk Icon dan Color
  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);

  // Convert ke Map untuk Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type,
      'category': category,
      'amount': amount,
      'note': note,
      'date': Timestamp.fromDate(date),
      'fromAccount': fromAccount,
      'toAccount': toAccount,
      'iconCodePoint': iconCodePoint,
      'colorValue': colorValue,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Convert dari Firestore Document
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return TransactionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: data['type'] ?? 'expense',
      category: data['category'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      note: data['note'],
      date: (data['date'] as Timestamp).toDate(),
      fromAccount: data['fromAccount'],
      toAccount: data['toAccount'],
      iconCodePoint: data['iconCodePoint'] ?? 0xe047,
      colorValue: data['colorValue'] ?? 0xFFB3E5FC,
    );
  }

  // Copy with method (untuk update)
  TransactionModel copyWith({
    String? id,
    String? userId,
    String? type,
    String? category,
    double? amount,
    String? note,
    DateTime? date,
    String? fromAccount,
    String? toAccount,
    int? iconCodePoint,
    int? colorValue,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      date: date ?? this.date,
      fromAccount: fromAccount ?? this.fromAccount,
      toAccount: toAccount ?? this.toAccount,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
    );
  }
}