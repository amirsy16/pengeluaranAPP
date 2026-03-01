import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';

class TransactionDetailDialog extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetailDialog({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final date = DateFormat('EEEE, d MMMM yyyy').format(transaction.date);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: transaction.category.color.withOpacity(0.1),
                  child: Icon(transaction.category.icon,
                      color: transaction.category.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    transaction.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _DetailRow(label: 'Date', value: date),
            const SizedBox(height: 12),
            _DetailRow(
                label: 'Category', value: transaction.category.label),
            const SizedBox(height: 12),
            _DetailRow(
              label: 'Amount',
              value: formatter.format(transaction.amount),
              isBold: true,
              color: transaction.type == TransactionType.expense
                  ? Colors.red
                  : Colors.green,
            ),
            if (transaction.note != null && transaction.note!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _DetailRow(label: 'Note', value: transaction.note!),
            ],
            if (transaction.items != null &&
                transaction.items!.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Items Purchased',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: transaction.items!.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final item = transaction.items![i];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: Text(item.name,
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text(
                          '${item.quantity} x ${formatter.format(item.unitPrice)}'),
                      trailing: Text(
                        formatter.format(item.amount),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? color;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
              color: color,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

