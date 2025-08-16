// Providers + Notifiers (Riverpod)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/expenses_repository.dart';
import '../data/models/transaction_model.dart';
import '../data/models/saving_model.dart';

final expensesRepoProvider = Provider<ExpensesRepository>((ref) {
  final r = ExpensesRepository();
  // Init fuera, pero si no se hizo: intentar init
  r.init();
  return r;
});

final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, List<TransactionModel>>((ref) {
  final repo = ref.watch(expensesRepoProvider);
  return TransactionsNotifier(repo);
});

class TransactionsNotifier extends StateNotifier<List<TransactionModel>> {
  final ExpensesRepository repo;
  TransactionsNotifier(this.repo) : super([]) {
    load();
  }

  Future<void> load() async {
    try {
      await repo.init();
      state = repo.getAllTransactions();
    } catch (e) {
      // manejar/loguear
      state = [];
    }
  }

  Future<void> add(TransactionModel t) async {
    await repo.createTransaction(t);
    await load();
  }

  Future<void> update(TransactionModel t) async {
    await repo.updateTransaction(t);
    await load();
  }

  Future<void> remove(String id) async {
    await repo.deleteTransaction(id);
    await load();
  }
}

final guardaditosProvider =
    StateNotifierProvider<SavingsNotifier, List<Saving>>((ref) {
  final repo = ref.watch(expensesRepoProvider);
  return SavingsNotifier(repo);
});

class SavingsNotifier extends StateNotifier<List<Saving>> {
  final ExpensesRepository repo;
  SavingsNotifier(this.repo) : super([]) {
    load();
  }

  Future<void> load() async {
    await repo.init();
    state = repo.getAllSavings();
  }

  Future<void> add(Saving g) async {
    await repo.createSavings(g);
    await load();
  }

  Future<void> update(Saving g) async {
    await repo.updateSavings(g);
    await load();
  }

  Future<void> remove(String id, {String? moveToId}) async {
    await repo.deleteSavings(id, moveToId: moveToId);
    await load();
  }

  Future<void> move(String fromId, String toId, double amount) async {
    await repo.moveBetweenSavings(fromId, toId, amount);
    await load();
  }
}
