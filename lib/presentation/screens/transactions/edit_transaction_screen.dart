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

class EditTransactionScreen extends StatefulWidget {
  final Transaction transaction;

  const EditTransactionScreen({
    super.key,
    required this.transaction,
  });

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late TextEditingController _noteController;

  late DateTime _selectedDate;
  late String _transactionType;
  late int _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.transaction.description);
    
    // Format initial amount (e.g. 50000.0 -> 50.000)
    String amountStr = widget.transaction.amount.toInt().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < amountStr.length; i++) {
      if (i > 0 && (amountStr.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(amountStr[i]);
    }
    _amountController = TextEditingController(text: buffer.toString());
    _noteController = TextEditingController(text: widget.transaction.note ?? '');
    _selectedDate = widget.transaction.date;
    _transactionType = widget.transaction.type;
    _selectedCategoryId = widget.transaction.categoryId;

    _descriptionController.addListener(_onFieldChanged);
    _amountController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _descriptionController.removeListener(_onFieldChanged);
    _amountController.removeListener(_onFieldChanged);
    _descriptionController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    setState(() {});
  }

  bool get _isFormValid {
    final cleanAmount = _amountController.text.replaceAll('.', '');
    final amount = double.tryParse(cleanAmount);
    return amount != null && amount > 0 && _descriptionController.text.isNotEmpty;
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
      _showTopBanner(context, 'Vui lòng nhập số tiền hợp lệ', isError: true);
      return;
    }

    if (_descriptionController.text.isEmpty) {
      _showTopBanner(context, 'Vui lòng nhập mô tả', isError: true);
      return;
    }

    final transaction = Transaction(
      id: widget.transaction.id,
      amount: amount,
      description: _descriptionController.text,
      date: _selectedDate,
      categoryId: _selectedCategoryId,
      type: _transactionType,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      isRecurring: widget.transaction.isRecurring,
      recurringTransactionId: widget.transaction.recurringTransactionId,
      createdAt: widget.transaction.createdAt,
      updatedAt: DateTime.now(),
    );

    context.read<TransactionBloc>().add(UpdateTransactionEvent(transaction));
  }

  void _deleteTransaction() {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa giao dịch'),
        content: const Text('Bạn có chắc muốn xóa giao dịch này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<TransactionBloc>().add(DeleteTransactionEvent(widget.transaction.id!));
            },
            child: const Text('Xóa', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }

  void _showTopBanner(BuildContext context, String message, {bool isError = false}) {
    final screenHeight = MediaQuery.of(context).size.height;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? AppTheme.errorColor : AppTheme.successColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(
          AppTheme.spacingMd,
          AppTheme.spacingMd,
          AppTheme.spacingMd,
          screenHeight - 150,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sửa giao dịch'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
            onPressed: _deleteTransaction,
          ),
        ],
      ),
      body: BlocListener<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionUpdated) {
            _showTopBanner(context, 'Cập nhật giao dịch thành công');
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                context.pop(true); // Return true to indicate success
              }
            });
          } else if (state is TransactionDeleted) {
            _showTopBanner(context, 'Xóa giao dịch thành công');
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                context.pop(true); // Return true to indicate success
              }
            });
          } else if (state is TransactionError) {
            _showTopBanner(context, 'Lỗi: ${state.message}', isError: true);
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
                    setState(() => _selectedCategoryId = id);
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
                      onPressed: (isLoading || !_isFormValid) ? null : _submitTransaction,
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Cập nhật giao dịch'),
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
