saving_model.dart


import 'package:cloud_firestore/cloud_firestore.dart';

class SavingGoalRecord {
  final String id;
  final String note; // Tambahkan note
  final double amount;
  final String type;
  final DateTime date;

  SavingGoalRecord({
    required this.id,
    required this.note,
    required this.amount,
    required this.type,
    required this.date,
  });

  factory SavingGoalRecord.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SavingGoalRecord(
      id: doc.id,
      note: data['note'] ?? 'Setoran',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      type: data['type'] ?? 'Uang tunai',
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'note': note,
      'amount': amount,
      'type': type,
      'date': Timestamp.fromDate(date),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

// --- SavingGoal Model (Tujuan Tabungan) ---
class SavingGoalModel {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime startDate;
  final DateTime endDate;
  // records tidak disimpan di sini, tapi diambil dari sub-collection

  SavingGoalModel({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.startDate,
    required this.endDate,
  });

  factory SavingGoalModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SavingGoalModel(
      id: doc.id,
      name: data['name'] ?? '',
      targetAmount: (data['targetAmount'] as num?)?.toDouble() ?? 0.0,
      currentAmount: (data['currentAmount'] as num?)?.toDouble() ?? 0.0, // Ini akan diupdate
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}