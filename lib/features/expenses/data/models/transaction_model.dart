import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class TransactionModel {
  final String id;
  final String concept;
  final DateTime date;
  final double amount;
  final bool isIncome; // true = ingreso
  final String? savingId;

  TransactionModel({
    String? id,
    required this.concept,
    required this.date,
    required this.amount,
    required this.isIncome,
    this.savingId,
  }) : id = id ?? _uuid.v4();

  Map<String, dynamic> toMap() => {
        'id': id,
        'concept': concept,
        'date': date.toIso8601String(),
        'amount': amount,
        'isIncome': isIncome,
        'savingId': savingId,
      };

  factory TransactionModel.fromMap(Map<dynamic, dynamic> m) {
    return TransactionModel(
      id: m['id'] as String,
      concept: m['concept'] as String,
      date: DateTime.parse(m['date'] as String),
      amount: (m['amount'] as num).toDouble(),
      isIncome: m['isIncome'] as bool,
      savingId: m['savingId'] as String?,
    );
  }
}
