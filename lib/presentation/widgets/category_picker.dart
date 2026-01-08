import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_project_spending_management/core/theme/app_theme.dart';
import 'package:mobile_project_spending_management/presentation/bloc/categories/category_bloc.dart';
import 'package:mobile_project_spending_management/presentation/bloc/categories/category_event.dart';
import 'package:mobile_project_spending_management/presentation/bloc/categories/category_state.dart';

class CategoryPicker extends StatefulWidget {
  final String transactionType; // 'income' or 'expense'
  final int? selectedCategoryId;
  final Function(int, String) onCategorySelected; // (id, name)

  const CategoryPicker({
    super.key,
    required this.transactionType,
    this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  State<CategoryPicker> createState() => _CategoryPickerState();
}

class _CategoryPickerState extends State<CategoryPicker> {
  late CategoryBloc _categoryBloc;

  @override
  void initState() {
    super.initState();
    _categoryBloc = context.read<CategoryBloc>();
    _categoryBloc.add(LoadCategories(widget.transactionType));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danh mục',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: AppTheme.spacingMd),
        BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            if (state is CategoryLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CategoryError) {
              return Container(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Text(state.message),
              );
            }

            if (state is CategoryLoaded) {
              final categories = state.categories;

              if (categories.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: const Text('Không có danh mục'),
                );
              }

              return Wrap(
                spacing: AppTheme.spacingSm,
                runSpacing: AppTheme.spacingSm,
                children: categories.map((category) {
                  final isSelected = widget.selectedCategoryId == category.id;
                  return FilterChip(
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        widget.onCategorySelected(category.id, category.name);
                      }
                    },
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(category.icon),
                        const SizedBox(width: AppTheme.spacingSm),
                        Text(category.name),
                      ],
                    ),
                    backgroundColor: Color(int.parse('0xFF${category.color.replaceFirst('#', '')}')).withValues(alpha: 0.2),
                    selectedColor: Color(int.parse('0xFF${category.color.replaceFirst('#', '')}')).withValues(alpha: 0.5),
                  );
                }).toList(),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
