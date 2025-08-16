import 'package:uuid/uuid.dart';

const _gUuid = Uuid();

class Saving {
  final String id;
  final String name;
  double balance;

  Saving({String? id, required this.name, required this.balance})
      : id = id ?? _gUuid.v4();

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'balance': balance};

  factory Saving.fromMap(Map<dynamic, dynamic> m) => Saving(
        id: m['id'] as String,
        name: m['name'] as String,
        balance: (m['balance'] as num).toDouble(),
      );
}
