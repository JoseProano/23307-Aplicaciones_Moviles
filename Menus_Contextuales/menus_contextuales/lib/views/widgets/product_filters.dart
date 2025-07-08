import 'package:flutter/material.dart';
import '../../models/category_model.dart';
import '../../utils/app_theme.dart';

class CategoryFilter extends StatelessWidget {
  final List<CategoryModel> categories;
  final String? selectedCategoryId;
  final Function(String?) onCategorySelected;

  const CategoryFilter({
    Key? key,
    required this.categories,
    this.selectedCategoryId,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        children: [
          // Botón "Todos"
          _buildFilterChip(
            label: 'Todos',
            isSelected: selectedCategoryId == null,
            onTap: () => onCategorySelected(null),
          ),
          
          // Categorías
          ...categories.map((category) => _buildFilterChip(
            label: category.name,
            isSelected: selectedCategoryId == category.id,
            onTap: () => onCategorySelected(category.id),
            color: _getColorFromString(category.color),
          )),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: color?.withOpacity(0.1) ?? AppColors.greyLight,
        selectedColor: color ?? AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected 
              ? Colors.white 
              : (color ?? AppColors.textPrimary),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        checkmarkColor: Colors.white,
      ),
    );
  }

  Color _getColorFromString(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }
}

class ProductSortFilter extends StatelessWidget {
  final String currentSort;
  final Function(String) onSortChanged;

  const ProductSortFilter({
    Key? key,
    required this.currentSort,
    required this.onSortChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.sort),
      onSelected: onSortChanged,
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'name_asc',
          child: Text('Nombre (A-Z)'),
        ),
        const PopupMenuItem(
          value: 'name_desc',
          child: Text('Nombre (Z-A)'),
        ),
        const PopupMenuItem(
          value: 'price_asc',
          child: Text('Precio (Menor a Mayor)'),
        ),
        const PopupMenuItem(
          value: 'price_desc',
          child: Text('Precio (Mayor a Menor)'),
        ),
        const PopupMenuItem(
          value: 'created_desc',
          child: Text('Más Recientes'),
        ),
      ],
    );
  }
}

class ProductSearchBar extends StatefulWidget {
  final String? initialQuery;
  final Function(String) onSearch;
  final VoidCallback? onClear;

  const ProductSearchBar({
    Key? key,
    this.initialQuery,
    required this.onSearch,
    this.onClear,
  }) : super(key: key);

  @override
  State<ProductSearchBar> createState() => _ProductSearchBarState();
}

class _ProductSearchBarState extends State<ProductSearchBar> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Buscar productos...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _hasText
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    widget.onClear?.call();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.large),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.greyLight.withOpacity(0.3),
        ),
        onSubmitted: widget.onSearch,
        textInputAction: TextInputAction.search,
      ),
    );
  }
}
