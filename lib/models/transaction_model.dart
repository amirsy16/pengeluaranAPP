import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 0)
enum TransactionType {
  @HiveField(0)
  income,
  @HiveField(1)
  expense,
}

@HiveType(typeId: 1)
enum CategoryType {
  @HiveField(0)
  food,
  @HiveField(1)
  transport,
  @HiveField(2)
  shopping,
  @HiveField(3)
  entertainment,
  @HiveField(4)
  health,
  @HiveField(5)
  education,
  @HiveField(6)
  bills,
  @HiveField(7)
  salary,
  @HiveField(8)
  others,
}

extension CategoryTypeExtension on CategoryType {
  String get label {
    switch (this) {
      case CategoryType.food:
        return 'Food';
      case CategoryType.transport:
        return 'Transport';
      case CategoryType.shopping:
        return 'Shopping';
      case CategoryType.entertainment:
        return 'Entertainment';
      case CategoryType.health:
        return 'Health';
      case CategoryType.education:
        return 'Education';
      case CategoryType.bills:
        return 'Bills';
      case CategoryType.salary:
        return 'Salary';
      case CategoryType.others:
        return 'Others';
    }
  }

  IconData get icon {
    switch (this) {
      case CategoryType.food:
        return Icons.restaurant_rounded;
      case CategoryType.transport:
        return Icons.directions_car_rounded;
      case CategoryType.shopping:
        return Icons.shopping_bag_rounded;
      case CategoryType.entertainment:
        return Icons.movie_rounded;
      case CategoryType.health:
        return Icons.favorite_rounded;
      case CategoryType.education:
        return Icons.school_rounded;
      case CategoryType.bills:
        return Icons.receipt_long_rounded;
      case CategoryType.salary:
        return Icons.payments_rounded;
      case CategoryType.others:
        return Icons.more_horiz_rounded;
    }
  }

  Color get color {
    switch (this) {
      case CategoryType.food:
        return const Color(0xFFFF6B6B);
      case CategoryType.transport:
        return const Color(0xFF4ECDC4);
      case CategoryType.shopping:
        return const Color(0xFFFFBE0B);
      case CategoryType.entertainment:
        return const Color(0xFF8338EC);
      case CategoryType.health:
        return const Color(0xFFFF006E);
      case CategoryType.education:
        return const Color(0xFF3A86FF);
      case CategoryType.bills:
        return const Color(0xFFFF9F1C);
      case CategoryType.salary:
        return const Color(0xFF06D6A0);
      case CategoryType.others:
        return const Color(0xFF8D99AE);
    }
  }
}

@HiveType(typeId: 2)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final TransactionType type;

  @HiveField(4)
  final CategoryType category;

  @HiveField(5)
  final DateTime date;

  @HiveField(6)
  final String? note;

  @HiveField(7)
  final List<TransactionItem>? items;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
    this.items,
  });
}

@HiveType(typeId: 3)
class TransactionItem extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final int quantity;

  @HiveField(3)
  final double unitPrice;

  TransactionItem({
    required this.name,
    required this.amount,
    this.quantity = 1,
    this.unitPrice = 0,
  });
}
