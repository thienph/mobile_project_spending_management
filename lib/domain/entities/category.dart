import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final int id;
  final String name;
  final String icon;
  final String color;
  final String type; // 'income' or 'expense'
  final bool isDefault;
  final DateTime createdAt;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    required this.isDefault,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, icon, color, type, isDefault, createdAt];
}
