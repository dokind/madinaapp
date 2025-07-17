import 'package:flutter/material.dart';

class FilterModal extends StatefulWidget {
  final void Function(Map<String, dynamic>) onApplyFilters;
  final Map<String, dynamic> initialFilters;

  const FilterModal({
    super.key,
    required this.onApplyFilters,
    this.initialFilters = const {},
  });

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  Map<String, dynamic> _filters = {};

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.initialFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          children: [
            _buildNavBar(),
            Expanded(
              child: SingleChildScrollView(
                child: _buildFilterContent(),
              ),
            ),
            _buildApplyButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBar() {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        border: Border(
          bottom: BorderSide(color: Color(0xFFF8F9FE), width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text(
                'Отмена',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF006FFD),
                  fontFamily: 'Inter',
                ),
              ),
            ),
            const Text(
              'Фильтр',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2024),
                fontFamily: 'Inter',
              ),
            ),
            GestureDetector(
              onTap: _clearAllFilters,
              child: const Text(
                'Очистить все',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF006FFD),
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterContent() {
    return Column(
      children: [
        _buildCategorySection(),
        _buildDivider(),
        _buildPriceRangeSection(),
        _buildDivider(),
        _buildColorSection(),
        _buildDivider(),
        _buildSizeSection(),
        _buildDivider(),
        _buildCustomerReviewsSection(),
      ],
    );
  }

  Widget _buildCategorySection() {
    final selectedCategories = _filters['categories'] as List<String>? ?? [];
    return GestureDetector(
      onTap: () {
        // Add category selection logic here
        _showCategorySelection();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Категория',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF1F2024),
                fontFamily: 'Inter',
                height: 1.43,
              ),
            ),
            if (selectedCategories.isNotEmpty)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFF006FFD),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    selectedCategories.length.toString(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFFFFFF),
                      fontFamily: 'Inter',
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRangeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Ценовой диапазон',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF1F2024),
              fontFamily: 'Inter',
              height: 1.43,
            ),
          ),
          Icon(
            Icons.keyboard_arrow_right,
            color: Color(0xFF8F9098),
            size: 12,
          ),
        ],
      ),
    );
  }

  Widget _buildColorSection() {
    final selectedColors = _filters['colors'] as List<String>? ?? [];
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              // Always show color tags when tapped
              if (selectedColors.isEmpty) {
                _filters['colors'] = [
                  'Зеленый'
                ]; // Default selection to show tags
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Цвет',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF1F2024),
                    fontFamily: 'Inter',
                    height: 1.43,
                  ),
                ),
                if (selectedColors.isNotEmpty)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFF006FFD),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        selectedColors.length.toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFFFFFF),
                          fontFamily: 'Inter',
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        _buildColorTags(),
      ],
    );
  }

  Widget _buildSizeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Размер',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF1F2024),
              fontFamily: 'Inter',
              height: 1.43,
            ),
          ),
          Icon(
            Icons.keyboard_arrow_right,
            color: Color(0xFF8F9098),
            size: 12,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerReviewsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Обзор клиентов',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF1F2024),
              fontFamily: 'Inter',
              height: 1.43,
            ),
          ),
          Icon(
            Icons.keyboard_arrow_right,
            color: Color(0xFF8F9098),
            size: 12,
          ),
        ],
      ),
    );
  }

  Widget _buildColorTags() {
    final selectedColors = _filters['colors'] as List<String>? ?? [];

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildColorRow(
              ['Черный', 'Белый', 'Серый', 'Желтый'], selectedColors),
          const SizedBox(height: 8),
          _buildColorRow(
              ['Синий', 'Фиолетовый', 'Зеленый', 'Красный', 'Розовый'],
              selectedColors),
          const SizedBox(height: 8),
          _buildColorRow(['Апельсин', 'Золото', 'Серебро'], selectedColors),
        ],
      ),
    );
  }

  Widget _buildColorRow(List<String> colors, List<String> selectedColors) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.map((color) {
        final isSelected = selectedColors.contains(color);
        return GestureDetector(
          onTap: () => _toggleColorSelection(color),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF006FFD)
                  : const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              color.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(0xFFFFFFFF)
                    : const Color(0xFF006FFD),
                fontFamily: 'Inter',
                letterSpacing: 0.5,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: const Color(0xFFF8F9FE),
    );
  }

  Widget _buildApplyButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        border: Border(
          top: BorderSide(color: Color(0xFFF8F9FE), width: 1),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: _applyFilters,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF006FFD),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Применить фильтры',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFFFFFF),
              fontFamily: 'Inter',
            ),
          ),
        ),
      ),
    );
  }

  void _showCategorySelection() {
    final categories = [
      'Льняная ткань',
      'Шелковая ткань',
      'Хлопковая ткань',
      'Шерстяная ткань',
      'Синтетическая ткань',
    ];

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выберите категории'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: categories.map((category) {
              final selectedCategories =
                  _filters['categories'] as List<String>? ?? [];
              final isSelected = selectedCategories.contains(category);
              return CheckboxListTile(
                title: Text(category),
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    _toggleCategorySelection(category);
                  });
                  Navigator.pop(context);
                  _showCategorySelection(); // Refresh dialog
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Готово'),
          ),
        ],
      ),
    );
  }

  void _toggleColorSelection(String color) {
    setState(() {
      final colors = _filters['colors'] as List<String>? ?? [];
      if (colors.contains(color)) {
        colors.remove(color);
      } else {
        colors.add(color);
      }
      _filters['colors'] = colors;
    });
  }

  void _toggleCategorySelection(String category) {
    setState(() {
      final categories = _filters['categories'] as List<String>? ?? [];
      if (categories.contains(category)) {
        categories.remove(category);
      } else {
        categories.add(category);
      }
      _filters['categories'] = categories;
    });
  }

  void _clearAllFilters() {
    setState(() {
      _filters.clear();
    });
  }

  void _applyFilters() {
    widget.onApplyFilters(_filters);
    Navigator.pop(context);
  }
}
