// Repo: wrapper simple sobre Hive (map-based)
import 'package:hive/hive.dart';
import '../models/transaction_model.dart';
import '../models/saving_model.dart';

class ExpensesRepository {
  static const String boxTx = 'expenses_transactions';
  static const String boxG = 'expenses_savings';

  Future<void> init() async {
    // HiveService.init() se debe llamar en main antes de usar repos.
    if (!Hive.isBoxOpen(boxTx)) await Hive.openBox(boxTx);
    if (!Hive.isBoxOpen(boxG)) await Hive.openBox(boxG);
  }

  // TRANSACTIONS
  List<TransactionModel> getAllTransactions() {
    final box = Hive.box(boxTx);
    return box.values.map((e) => TransactionModel.fromMap(Map.from(e))).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> createTransaction(TransactionModel t) async {
    final box = Hive.box(boxTx);
    await box.put(t.id, t.toMap());
    if (t.savingId != null) {
      await _updateSavingsBalance(
          t.savingId!, t.isIncome ? t.amount : -t.amount);
    }
  }

  Future<void> updateTransaction(TransactionModel t) async {
    final box = Hive.box(boxTx);
    final old = box.get(t.id);
    if (old == null) throw Exception('Transacción no encontrada');
    // Ajustar balances: calcular diferencia si tenía savings
    final previous = TransactionModel.fromMap(Map.from(old));
    if (previous.savingId != null) {
      // revertir efecto anterior
      await _updateSavingsBalance(previous.savingId!,
          previous.isIncome ? -previous.amount : previous.amount);
    }
    if (t.savingId != null) {
      await _updateSavingsBalance(
          t.savingId!, t.isIncome ? t.amount : -t.amount);
    }
    await box.put(t.id, t.toMap());
  }

  Future<void> deleteTransaction(String id) async {
    final box = Hive.box(boxTx);
    final m = box.get(id);
    if (m == null) return;
    final t = TransactionModel.fromMap(Map.from(m));
    if (t.savingId != null) {
      await _updateSavingsBalance(
          t.savingId!, t.isIncome ? -t.amount : t.amount);
    }
    await box.delete(id);
  }

  // savingsS
  List<Saving> getAllSavings() {
    final box = Hive.box(boxG);
    return box.values.map((e) => Saving.fromMap(Map.from(e))).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<void> createSavings(Saving g) async {
    final box = Hive.box(boxG);
    await box.put(g.id, g.toMap());
  }

  Future<void> updateSavings(Saving g) async {
    final box = Hive.box(boxG);
    await box.put(g.id, g.toMap());
  }

  Future<void> deleteSavings(String id, {String? moveToId}) async {
    final box = Hive.box(boxG);
    final m = box.get(id);
    if (m == null) return;
    final g = Saving.fromMap(Map.from(m));
    if (moveToId != null) {
      final targetMap = box.get(moveToId);
      if (targetMap != null) {
        final target = Saving.fromMap(Map.from(targetMap));
        target.balance += g.balance;
        await box.put(target.id, target.toMap());
      }
    }
    await box.delete(id);
  }

  Future<void> moveBetweenSavings(
      String fromId, String toId, double amount) async {
    final box = Hive.box(boxG);
    final fromMap = box.get(fromId);
    final toMap = box.get(toId);
    if (fromMap == null || toMap == null)
      throw Exception('savings no encontrado');
    final from = Saving.fromMap(Map.from(fromMap));
    final to = Saving.fromMap(Map.from(toMap));
    if (from.balance < amount) throw Exception('Saldo insuficiente');
    from.balance -= amount;
    to.balance += amount;
    await box.put(from.id, from.toMap());
    await box.put(to.id, to.toMap());
  }

  Future<void> _updateSavingsBalance(String id, double delta) async {
    final box = Hive.box(boxG);
    final m = box.get(id);
    if (m == null) return;
    final g = Saving.fromMap(Map.from(m));
    g.balance += delta;
    await box.put(g.id, g.toMap());
  }

  // UTILS
  double totalAvailable() {
    final g = getAllSavings();
    return g.fold(0.0, (p, e) => p + e.balance);
  }

  double totalIncomes() {
    final tx = getAllTransactions();
    return tx.where((t) => t.isIncome).fold(0.0, (p, e) => p + e.amount);
  }

  double totalExpenses() {
    final tx = getAllTransactions();
    return tx.where((t) => !t.isIncome).fold(0.0, (p, e) => p + e.amount);
  }

  /// devuelve un map day-> {in: x, out: y} para el mes (1..31) dado
  Map<int, Map<String, double>> monthlySummary(int year, int month) {
    final tx = getAllTransactions()
        .where((t) => t.date.year == year && t.date.month == month);
    final res = <int, Map<String, double>>{};
    for (var t in tx) {
      final day = t.date.day;
      res.putIfAbsent(day, () => {'in': 0.0, 'out': 0.0});
      if (t.isIncome) {
        res[day]!['in'] = res[day]!['in']! + t.amount;
      } else {
        res[day]!['out'] = res[day]!['out']! + t.amount;
      }
    }
    return res;
  }
}
