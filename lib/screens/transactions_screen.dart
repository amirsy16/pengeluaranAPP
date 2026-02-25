import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/empty_state.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  TransactionType? _filterType;
  CategoryType? _filterCategory;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final filtered = provider.getFilteredTransactions(
      type: _filterType,
      category: _filterCategory,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        title: const Text(
          'Transactions',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 48,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _filterType == null && _filterCategory == null,
                  onTap: () => setState(() {
                    _filterType = null;
                    _filterCategory = null;
                  }),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Income',
                  icon: Icons.arrow_downward_rounded,
                  color: const Color(0xFF06D6A0),
                  isSelected: _filterType == TransactionType.income,
                  onTap: () => setState(() {
                    _filterType = TransactionType.income;
                    _filterCategory = null;
                  }),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Expense',
                  icon: Icons.arrow_upward_rounded,
                  color: const Color(0xFFFF6B6B),
                  isSelected: _filterType == TransactionType.expense &&
                      _filterCategory == null,
                  onTap: () => setState(() {
                    _filterType = TransactionType.expense;
                    _filterCategory = null;
                  }),
                ),
                const SizedBox(width: 8),
                ...CategoryType.values
                    .where((c) => c != CategoryType.salary)
                    .map((c) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _FilterChip(
                            label: c.label,
                            icon: c.icon,
                            color: c.color,
                            isSelected: _filterCategory == c,
                            onTap: () => setState(() {
                              _filterType = null;
                              _filterCategory = c;
                            }),
                          ),
                        )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? const EmptyState(
                    message: 'No transactions found',
                    subtitle: 'Try a different filter',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final tx = filtered[index];
                      return TransactionTile(
                        transaction: tx,
                        onDelete: () {
                          context
                              .read<TransactionProvider>()
                              .deleteTransaction(tx.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Transaction deleted'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.15)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: isSelected ? activeColor : Colors.grey),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected ? activeColor : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


