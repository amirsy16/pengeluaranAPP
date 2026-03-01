import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/empty_state.dart';
import 'add_transaction_screen.dart';
import '../widgets/transaction_detail_dialog.dart'; // Import this

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Reset Data'),
          ],
        ),
        content: const Text(
          'Apakah kamu yakin ingin mereset semua data pemasukan dan pengeluaran? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<TransactionProvider>().resetAllTransactions();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Semua data berhasil direset'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final recent = provider.recentTransactions;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 60,
            floating: true,
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerLowest,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good day! 👋',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                      ),
                ),
                Text(
                  'Expense Tracker',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Reset Data',
                onPressed: () => _showResetDialog(context),
                icon: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.refresh_rounded,
                      color: Colors.red, size: 20),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 16, left: 4),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'public/mylogo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(
                        Icons.person_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BalanceCard(),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      if (recent.isNotEmpty)
                        TextButton(
                          onPressed: () {},
                          child: const Text('See All'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          if (recent.isEmpty)
            SliverToBoxAdapter(
              child: EmptyState(
                message: 'No transactions yet',
                subtitle: 'Tap the + button to add your first transaction',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final tx = recent[index];
                    return TransactionTile(
                      transaction: tx,
                      onDelete: () =>
                          context.read<TransactionProvider>().deleteTransaction(tx.id),
                      onTap: () { // Add onTap
                        showDialog(
                          context: context,
                          builder: (ctx) => TransactionDetailDialog(
                            transaction: tx,
                          ),
                        );
                      },
                    );
                  },
                  childCount: recent.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'dashboard_fab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddTransactionScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

