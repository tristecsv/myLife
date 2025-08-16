// Lista + CRUD simple para guardaditos
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/saving_model.dart';
import '../providers/expenses_provider.dart';

class GuardaditosList extends ConsumerWidget {
  const GuardaditosList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guard = ref.watch(guardaditosProvider);
    final notifier = ref.read(guardaditosProvider.notifier);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Guardaditos', style: Theme.of(context).textTheme.titleLarge),
        ElevatedButton.icon(
            onPressed: () => _showCreate(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Nuevo'))
      ]),
      const SizedBox(height: 12),
      if (guard.isEmpty) ...[
        const Text('No hay guardaditos.'),
      ] else
        Expanded(
          child: ListView.separated(
            itemCount: guard.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (c, i) {
              final g = guard[i];
              return ListTile(
                title: Text(g.name),
                subtitle: Text('\$${g.balance.toStringAsFixed(2)}'),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) async {
                    if (v == 'edit') _showEdit(context, ref, g);
                    if (v == 'delete') {
                      // simple delete; could ask to move balance
                      await notifier.remove(g.id);
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Editar')),
                    const PopupMenuItem(
                        value: 'delete', child: Text('Eliminar')),
                  ],
                ),
              );
            },
          ),
        )
    ]);
  }

  void _showCreate(BuildContext context, WidgetRef ref) {
    final name = TextEditingController();
    final bal = TextEditingController(text: '0');
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Nuevo guardadito'),
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
                    final g = Saving(
                        name: name.text.isEmpty ? 'Guardadito' : name.text,
                        balance: b);
                    await ref.read(guardaditosProvider.notifier).add(g);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Crear'))
            ],
          );
        });
  }

  void _showEdit(BuildContext context, WidgetRef ref, Saving g) {
    final name = TextEditingController(text: g.name);
    final bal = TextEditingController(text: g.balance.toString());
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Editar guardadito'),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Nombre')),
              TextField(
                  controller: bal,
                  decoration: const InputDecoration(labelText: 'Balance'),
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
                    final updated = Saving(
                        id: g.id,
                        name: name.text.isEmpty ? g.name : name.text,
                        balance: b);
                    await ref
                        .read(guardaditosProvider.notifier)
                        .update(updated);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Guardar'))
            ],
          );
        });
  }
}
