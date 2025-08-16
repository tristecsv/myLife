import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mylife/features/expenses/data/models/saving_model.dart';
import '../providers/expenses_provider.dart';
import 'add_transaction_dialog.dart';
import 'savings_list.dart';
import 'monthly_chart.dart';

// TODO: terminar de clonar la vista, y inicilaizar el repo
class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txs = ref.watch(transactionsProvider);
    final guard = ref.watch(guardaditosProvider);
    final repo = ref.read(expensesRepoProvider);
    final totalAvailable = repo.totalAvailable();
    final totalIn = repo.totalIncomes();
    final totalOut = repo.totalExpenses();

    final now = DateTime.now();
    final monthly = repo.monthlySummary(now.year, now.month);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header: title + buttons
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Administrador de Gastos',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Controla tus ingresos y gastos',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withOpacity(0.7))),
          ]),
          Row(children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.folder),
              label: const Text('Nuevo Guardadito'),
              onPressed: () => _showCreateGuardadito(context, ref),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Nueva Transacción'),
              onPressed: () => AddTransactionDialog.show(context, ref),
            )
          ])
        ]),
        const SizedBox(height: 16),

        // Cards resumen (grid)
        GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : 1,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 3.5,
          children: [
            _summaryCard(
                context,
                'Balance Total',
                NumberFormat.simpleCurrency(locale: 'es_MX')
                    .format(totalAvailable),
                Icons.account_balance_wallet),
            _summaryCard(
                context,
                'Ingresos',
                NumberFormat.simpleCurrency(locale: 'es_MX').format(totalIn),
                Icons.trending_up,
                valueColor: Colors.green),
            _summaryCard(
                context,
                'Gastos',
                NumberFormat.simpleCurrency(locale: 'es_MX').format(totalOut),
                Icons.trending_down,
                valueColor: Colors.red),
          ],
        ),

        const SizedBox(height: 12),

        // Chart + recent transactions area
        Expanded(
          child: Row(children: [
            // Left: chart + guardaditos list
            Expanded(
              flex: 2,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Entradas / Salidas (mes)',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium),
                                    Text(
                                        '${DateFormat.MMMM().format(now)} ${now.year}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall)
                                  ]),
                              const SizedBox(height: 8),
                              // MonthlyIncomeExpenseChart(
                              //     dayInOut: monthly,
                              //     month: now.month,
                              //     year: now.year),
                            ]),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Expanded(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: GuardaditosList(),
                        ),
                      ),
                    )
                  ]),
            ),

            const SizedBox(width: 12),

            // Right: recent transactions
            Expanded(
              flex: 1,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Transacciones Recientes',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Expanded(
                          child: txs.isEmpty
                              ? Center(
                                  child: Text(
                                      'No hay transacciones registradas',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium))
                              : ListView.separated(
                                  itemCount: txs.length,
                                  separatorBuilder: (_, __) => const Divider(),
                                  itemBuilder: (c, i) {
                                    final t = txs[i];
                                    return ListTile(
                                      dense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 0),
                                      leading: CircleAvatar(
                                        radius: 18,
                                        backgroundColor: t.isIncome
                                            ? Colors.green[100]
                                            : Colors.red[100],
                                        child: Icon(
                                            t.isIncome
                                                ? Icons.arrow_downward
                                                : Icons.arrow_upward,
                                            size: 18,
                                            color: t.isIncome
                                                ? Colors.green
                                                : Colors.red),
                                      ),
                                      title: Text(t.concept),
                                      subtitle: Text(DateFormat.yMd()
                                          .add_jm()
                                          .format(t.date)),
                                      trailing: Text(
                                        '${t.isIncome ? '+' : '-'}${NumberFormat.simpleCurrency(locale: 'es_MX').format(t.amount)}',
                                        style: TextStyle(
                                            color: t.isIncome
                                                ? Colors.green
                                                : Colors.red,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      onLongPress: () async {
                                        await ref
                                            .read(transactionsProvider.notifier)
                                            .remove(t.id);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Transacción eliminada')));
                                      },
                                      onTap: () => AddTransactionDialog.show(
                                          context, ref,
                                          editing: t),
                                    );
                                  }),
                        )
                      ]),
                ),
              ),
            )
          ]),
        )
      ]),
    );
  }

  Widget _summaryCard(
      BuildContext context, String title, String value, IconData icon,
      {Color? valueColor}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        child: Row(children: [
          Icon(icon, size: 28),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold, color: valueColor)),
              ]))
        ]),
      ),
    );
  }

  void _showCreateGuardadito(BuildContext context, WidgetRef ref) {
    final name = TextEditingController();
    final bal = TextEditingController(text: '0');
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Nuevo Guardadito'),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Nombre')),
              TextField(
                  controller: bal,
                  decoration:
                      const InputDecoration(labelText: 'Balance inicial'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true)),
            ]),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar')),
              ElevatedButton(
                  onPressed: () async {
                    final b = double.tryParse(bal.text) ?? 0.0;
                    await ref.read(guardaditosProvider.notifier).add(Saving(
                        name: name.text.isEmpty ? 'Guardadito' : name.text,
                        balance: b));
                    Navigator.pop(ctx);
                  },
                  child: const Text('Crear'))
            ],
          );
        });
  }
}
