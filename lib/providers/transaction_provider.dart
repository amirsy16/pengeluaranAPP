import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/hive_service.dart';

class TransactionProvider extends ChangeNotifier {
  List<TransactionModel> _transactions = [];

  TransactionProvider() {
    _loadTransactions();
  }

  void _loadTransactions() {
    _transactions = HiveService.getAllTransactions();
    notifyListeners();
  }

  List<TransactionModel> get transactions => _transactions;

  double get totalBalance => totalIncome - totalExpenses;

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpenses => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  List<TransactionModel> get recentTransactions =>
      _transactions.take(5).toList();

  List<TransactionModel> getFilteredTransactions({
    TransactionType? type,
    CategoryType? category,
  }) {
    return _transactions.where((t) {
      if (type != null && t.type != type) return false;
      if (category != null && t.category != category) return false;
      return true;
    }).toList();
  }

  Map<CategoryType, double> get expensesByCategory {
    final Map<CategoryType, double> map = {};
    for (final t in _transactions.where((t) => t.type == TransactionType.expense)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  Map<String, Map<String, double>> get monthlyData {
    final Map<String, Map<String, double>> map = {};
    final now = DateTime.now();
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final key = '${month.year}-${month.month.toString().padLeft(2, '0')}';
      map[key] = {'income': 0, 'expense': 0};
    }
    for (final t in _transactions) {
      final key =
          '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}';
      if (map.containsKey(key)) {
        if (t.type == TransactionType.income) {
          map[key]!['income'] = (map[key]!['income'] ?? 0) + t.amount;
        } else {
          map[key]!['expense'] = (map[key]!['expense'] ?? 0) + t.amount;
        }
      }
    }
    return map;
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await HiveService.addTransaction(transaction);
    _loadTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    await HiveService.deleteTransaction(id);
    _loadTransactions();
  }

  Future<void> resetAllTransactions() async {
    await HiveService.clearAllTransactions();
    _loadTransactions();
  }
}


