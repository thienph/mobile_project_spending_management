import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_project_spending_management/core/di/injection.dart';
import 'package:mobile_project_spending_management/core/theme/app_theme.dart';
import 'package:mobile_project_spending_management/core/utils/date_extensions.dart';
import 'package:mobile_project_spending_management/domain/entities/transaction.dart';
import 'package:mobile_project_spending_management/presentation/bloc/categories/category_bloc.dart';
import 'package:mobile_project_spending_management/presentation/bloc/transactions/transaction_bloc.dart';
import 'package:mobile_project_spending_management/presentation/bloc/transactions/transaction_event.dart';
import 'package:mobile_project_spending_management/presentation/bloc/transactions/transaction_state.dart';
import 'package:mobile_project_spending_management/presentation/widgets/category_picker.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late TextEditingController _noteController;

  DateTime _selectedDate = DateTime.now();
  String _transactionType = 'expense'; // 'income' or 'expense'
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _amountController = TextEditingController();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submitTransaction() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số tiền hợp lệ')),
      );
      return;
    }

    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập mô tả')),
      );
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn danh mục')),
      );
      return;
    }

    final transaction = Transaction(
      amount: amount,
      description: _descriptionController.text,
      date: _selectedDate,
      categoryId: _selectedCategoryId!,
      type: _transactionType,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      isRecurring: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    context.read<TransactionBloc>().add(AddTransactionEvent(transaction));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm giao dịch'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionAdded) {
            context.pop(true); // Return true to indicate success
          } else if (state is TransactionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi: ${state.message}')),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transaction Type Selection
              Text(
                'Loại giao dịch',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Row(
                children: ['expense', 'income']
                    .map((type) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: AppTheme.spacingSm),
                            child: ChoiceChip(
                              selected: _transactionType == type,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => _transactionType = type);
                                }
                              },
                              label: Text(
                                type == 'income' ? 'Thu' : 'Chi',
                              ),
                              selectedColor: type == 'income'
                                  ? AppTheme.incomeColor
                                  : AppTheme.expenseColor,
                              labelStyle: TextStyle(
                                color: _transactionType == type
                                    ? Colors.white
                                    : AppTheme.textPrimaryColor,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: AppTheme.spacingLg),

              // Description
              Text(
                'Mô tả',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppTheme.spacingMd),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'Ví dụ: Ăn trưa',
                  filled: true,
                  fillColor: AppTheme.backgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    borderSide: const BorderSide(color: AppTheme.borderColor),
                  ),
                  contentPadding: const EdgeInsets.all(AppTheme.spacingMd),
                ),
              ),
              const SizedBox(height: AppTheme.spacingLg),

              // Amount
              Text(
                'Số tiền',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppTheme.spacingMd),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '0',
                  filled: true,
                  fillColor: AppTheme.backgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    borderSide: const BorderSide(color: AppTheme.borderColor),
                  ),
                  contentPadding: const EdgeInsets.all(AppTheme.spacingMd),
                ),
              ),
              const SizedBox(height: AppTheme.spacingLg),

              // Date
              Text(
                'Ngày giao dịch',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppTheme.spacingMd),
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate.toDateString(),
                        style: const TextStyle(
                          fontSize: AppTheme.fontSizeLg,
                          fontWeight: AppTheme.fontWeightSemiBold,
                        ),
                      ),
                      const Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingLg),

              // Category Picker
              BlocProvider(
                create: (context) => getIt<CategoryBloc>(),
                child: CategoryPicker(
                  transactionType: _transactionType,
                  selectedCategoryId: _selectedCategoryId,
                  onCategorySelected: (id, name) {
                    setState(() {
                      _selectedCategoryId = id;
                    });
                  },
                ),
              ),
              const SizedBox(height: AppTheme.spacingLg),

              // Note
              Text(
                'Ghi chú (tùy chọn)',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppTheme.spacingMd),
              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Thêm ghi chú...',
                  filled: true,
                  fillColor: AppTheme.backgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    borderSide: const BorderSide(color: AppTheme.borderColor),
                  ),
                  contentPadding: const EdgeInsets.all(AppTheme.spacingMd),
                ),
              ),
              const SizedBox(height: AppTheme.spacingXl),

              // Submit Button
              BlocBuilder<TransactionBloc, TransactionState>(
                builder: (context, state) {
                  final isLoading = state is TransactionLoading;
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submitTransaction,
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Thêm giao dịch'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
