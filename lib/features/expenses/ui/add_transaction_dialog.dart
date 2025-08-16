// Diálogo para crear/editar transacciones (reutilizable)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/models/transaction_model.dart';
import '../providers/expenses_provider.dart';

class AddTransactionDialog {
  static Future<void> show(BuildContext context, WidgetRef ref,
      {TransactionModel? editing}) {
    final formKey = GlobalKey<FormState>();
    final txtConcept = TextEditingController(text: editing?.concept ?? '');
    final txtAmount = TextEditingController(
        text: editing != null ? editing.amount.toString() : '');
    DateTime chosen = editing?.date ?? DateTime.now();
    bool isIncome = editing?.isIncome ?? false;
    String? selectedGuard = editing?.savingId;
    final guardaditos = ref.read(guardaditosProvider);

    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title:
            Text(editing == null ? 'Nueva transacción' : 'Editar transacción'),
        content: StatefulBuilder(builder: (c, setState) {
          return SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(
                    controller: txtConcept,
                    decoration: const InputDecoration(labelText: 'Concepto'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Requerido' : null),
                TextFormField(
                  controller: txtAmount,
                  decoration: const InputDecoration(labelText: 'Monto'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => (v == null || double.tryParse(v) == null)
                      ? 'Número inválido'
                      : null,
                ),
                const SizedBox(height: 8),
                Row(children: [
                  const Text('Tipo:'),
                  const SizedBox(width: 8),
                  ChoiceChip(
                      label: const Text('Egreso'),
                      selected: !isIncome,
                      onSelected: (s) => setState(() => isIncome = !s)),
                  const SizedBox(width: 8),
                  ChoiceChip(
                      label: const Text('Ingreso'),
                      selected: isIncome,
                      onSelected: (s) => setState(() => isIncome = s)),
                ]),
                const SizedBox(height: 8),
                DropdownButtonFormField<String?>(
                  value: selectedGuard,
                  items: [
                    const DropdownMenuItem<String?>(
                        value: null, child: Text('Sin carpeta'))
                  ]
                      .followedBy(guardaditos.map((g) =>
                          DropdownMenuItem(value: g.id, child: Text(g.name))))
                      .toList(),
                  onChanged: (v) => setState(() => selectedGuard = v),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () async {
                    final d = await showDatePicker(
                        context: context,
                        initialDate: chosen,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100));
                    if (d != null) setState(() => chosen = d);
                  },
                  icon: const Icon(Icons.date_range),
                  label: Text(DateFormat.yMd().format(chosen)),
                )
              ]),
            ),
          );
        }),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final amount = double.parse(txtAmount.text);
              final tx = TransactionModel(
                id: editing?.id,
                concept: txtConcept.text,
                date: chosen,
                amount: amount,
                isIncome: isIncome,
                savingId: selectedGuard,
              );
              final notifier = ref.read(transactionsProvider.notifier);
              if (editing == null) {
                await notifier.add(tx);
              } else {
                await notifier.update(tx);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
