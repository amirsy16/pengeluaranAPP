import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';

class HiveService {
  static const String _boxName = 'transactions';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(CategoryTypeAdapter());
    Hive.registerAdapter(TransactionModelAdapter());
    await Hive.openBox<TransactionModel>(_boxName);
  }

  static Box<TransactionModel> get _box =>
      Hive.box<TransactionModel>(_boxName);

  static List<TransactionModel> getAllTransactions() {
    return _box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static Future<void> addTransaction(TransactionModel transaction) async {
    await _box.put(transaction.id, transaction);
  }

  static Future<void> deleteTransaction(String id) async {
    await _box.delete(id);
  }

  static Future<void> updateTransaction(TransactionModel transaction) async {
    await _box.put(transaction.id, transaction);
  }

  static Future<void> clearAllTransactions() async {
    await _box.clear();
  }
}


