import 'package:flutter/material.dart';
import 'package:mobile_project_spending_management/core/theme/app_theme.dart';
import 'package:mobile_project_spending_management/core/utils/number_extensions.dart';
import 'package:mobile_project_spending_management/domain/entities/category.dart';
import 'package:mobile_project_spending_management/domain/entities/transaction.dart';
import 'package:go_router/go_router.dart';

class CategoryTransactionGroup extends StatefulWidget {
  final Category category;
  final List<Transaction> transactions;
  final VoidCallback onTransactionChanged;

  const CategoryTransactionGroup({
    super.key,
    required this.category,
    required this.transactions,
    required this.onTransactionChanged,
  });

  @override
  State<CategoryTransactionGroup> createState() => _CategoryTransactionGroupState();
}

class _CategoryTransactionGroupState extends State<CategoryTransactionGroup> {
  bool _isExpanded = false;

  double get _total {
    return widget.transactions.fold(0.0, (sum, t) => sum + t.amount);
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = widget.category.type == 'income';
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: Column(
        children: [
          // Header - Category Summary
          InkWell(
            onTap: () {
              setState(() => _isExpanded = !_isExpanded);
            },
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Row(
                children: [
                  // Category Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _parseColor(widget.category.color).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Center(
                      child: Text(
                        widget.category.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  // Category Name & Count
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.category.name,
                          style: const TextStyle(
                            fontSize: AppTheme.fontSizeLg,
                            fontWeight: AppTheme.fontWeightSemiBold,
                            color: AppTheme.textPrimaryColor,
                          ),
                        ),
                        Text(
                          '${widget.transactions.length} giao dịch',
                          style: const TextStyle(
                            fontSize: AppTheme.fontSizeSm,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Total Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isIncome ? '+' : '-'}${_total.toCurrency()}',
                        style: TextStyle(
                          fontSize: AppTheme.fontSizeLg,
                          fontWeight: AppTheme.fontWeightBold,
                          color: isIncome ? AppTheme.incomeColor : AppTheme.expenseColor,
                        ),
                      ),
                      Icon(
                        _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: AppTheme.textSecondaryColor,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Expanded Transaction List
          if (_isExpanded)
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppTheme.dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: widget.transactions.map((transaction) {
                  return _buildTransactionItem(transaction, isIncome);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction, bool isIncome) {
    return InkWell(
      onTap: () async {
        final result = await context.pushNamed(
          'edit-transaction',
          pathParameters: {'id': transaction.id!.toString()},
          extra: transaction,
        );
        if (result == true && mounted) {
          widget.onTransactionChanged();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingMd,
        ),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppTheme.dividerColor,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 8), // Indent
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (transaction.description != null && transaction.description!.isNotEmpty)
                    Text(
                      transaction.description!,
                      style: const TextStyle(
                        fontSize: AppTheme.fontSizeMd,
                        color: AppTheme.textPrimaryColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Text(
              '${isIncome ? '+' : '-'}${transaction.amount.toCurrency()}',
              style: TextStyle(
                fontSize: AppTheme.fontSizeMd,
                fontWeight: AppTheme.fontWeightSemiBold,
                color: isIncome ? AppTheme.incomeColor : AppTheme.expenseColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppTheme.primaryColor;
    }
  }
}
