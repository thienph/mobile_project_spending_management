import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final cleanAmount = _amountController.text.replaceAll('.', '');
    final amount = double.tryParse(cleanAmount);
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
              Center(
                child: SegmentedButton<String>(
                  segments: const <ButtonSegment<String>>[
                    ButtonSegment<String>(value: 'expense', label: Text('Chi tiêu')),
                    ButtonSegment<String>(value: 'income', label: Text('Thu nhập')),
                  ],
                  selected: <String>{_transactionType},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _transactionType = newSelection.first;
                    });
                  },
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: _transactionType == 'income'
                        ? AppTheme.incomeColor
                        : AppTheme.expenseColor,
                    selectedForegroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingLg),

              // Amount
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CurrencyInputFormatter(),
                ],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
                decoration: InputDecoration(
                  hintText: '0',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: AppTheme.textSecondaryColor.withValues(alpha: 0.5),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingLg),

              // Description
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Mô tả',
                  hintText: 'Ví dụ: Ăn trưa',
                  prefixIcon: const Icon(Icons.description_outlined),
                  filled: true,
                  fillColor: AppTheme.backgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),

              // Date
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppTheme.textSecondaryColor),
                      const SizedBox(width: AppTheme.spacingMd),
                      Text(
                        _selectedDate.toDateString(),
                        style: const TextStyle(
                          fontSize: AppTheme.fontSizeMd,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),

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
              const SizedBox(height: AppTheme.spacingMd),

              // Note
              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Ghi chú',
                  alignLabelWithHint: true,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.note_outlined),
                  ),
                  filled: true,
                  fillColor: AppTheme.backgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    borderSide: BorderSide.none,
                  ),
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

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String value = newValue.text.replaceAll('.', '');
    // Remove leading zeros
    final number = int.tryParse(value);
    if (number == null) return newValue;
    value = number.toString();

    final buffer = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      if (i > 0 && (value.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(value[i]);
    }
    final newText = buffer.toString();

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
