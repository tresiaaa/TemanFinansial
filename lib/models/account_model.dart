// lib/models/account_model.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountModel {
  final String? docId;
  final String userId;
  final String id;
  final String name;
  final String iconName;
  final String colorHex;
  final double balance;
  final String accountType;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AccountModel({
    this.docId,
    required this.userId,
    required this.id,
    required this.name,
    required this.iconName,
    required this.colorHex,
    required this.balance,
    this.accountType = 'Default',
    this.createdAt,
    this.updatedAt,
  });

  IconData get icon {
    switch (iconName) {
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'account_balance':
        return Icons.account_balance;
      case 'money':
        return Icons.attach_money;
      case 'credit_card':
        return Icons.credit_card;
      case 'savings':
        return Icons.savings;
      case 'paid':
        return Icons.paid;
      case 'currency_exchange':
        return Icons.currency_exchange;
      case 'wallet':
        return Icons.wallet;
      case 'payment':
        return Icons.payment;
      case 'account_circle':
        return Icons.account_circle;
      default:
        return Icons.account_balance_wallet;
    }
  }

  Color get color {
    String hex = colorHex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  factory AccountModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return AccountModel(
      docId: doc.id,
      userId: data['userId'] ?? '',
      id: data['id'] ?? doc.id,
      name: data['name'] ?? '',
      iconName: data['iconName'] ?? data['icon'] ?? 'account_balance_wallet',
      colorHex: data['colorHex'] ?? data['color'] ?? '#4CAF50',
      balance: (data['balance'] ?? 0).toDouble(),
      accountType: data['accountType'] ?? 'Default',
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'id': id,
      'name': name,
      'iconName': iconName,
      'colorHex': colorHex,
      'balance': balance,
      'accountType': accountType,
      'createdAt': createdAt != null 
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toSelectionMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'balance': balance,
      'accountType': accountType,
    };
  }

  AccountModel copyWith({
    String? docId,
    String? userId,
    String? id,
    String? name,
    String? iconName,
    String? colorHex,
    double? balance,
    String? accountType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AccountModel(
      docId: docId ?? this.docId,
      userId: userId ?? this.userId,
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
      balance: balance ?? this.balance,
      accountType: accountType ?? this.accountType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}