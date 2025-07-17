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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFilterSection(
            'Категория',
            _buildCategoryFilter(),
            hasCount: _getSelectedCount('categories') > 0,
            count: _getSelectedCount('categories'),
          ),
          _buildDivider(),
          _buildFilterSection(
            'Ценовой диапазон',
            _buildPriceRangeFilter(),
            hasArrow: true,
          ),
          _buildDivider(),
          _buildFilterSection(
            'Цвет',
            _buildColorFilter(),
            hasCount: _getSelectedCount('colors') > 0,
            count: _getSelectedCount('colors'),
          ),
          if (_getSelectedCount('colors') > 0) _buildColorTags(),
          _buildDivider(),
          _buildFilterSection(
            'Размер',
            _buildSizeFilter(),
            hasArrow: true,
          ),
          _buildDivider(),
          _buildFilterSection(
            'Обзор клиентов',
            _buildCustomerReviewsFilter(),
            hasArrow: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, Widget content,
      {bool hasCount = false, int count = 0, bool hasArrow = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF1F2024),
              fontFamily: 'Inter',
            ),
          ),
          if (hasCount)
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFF006FFD),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFFFFFF),
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
          if (hasArrow)
            const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF8F9098),
              size: 12,
            ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: const Color(0xFFF8F9FE),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = [
      'Льняная ткань',
      'Шелковая ткань',
      'Хлопковая ткань',
      'Шерстяная ткань',
      'Синтетическая ткань',
    ];
    final selectedCategories = _filters['categories'] as List<String>? ?? [];

    return Column(
      children: categories.map((category) {
        final isSelected = selectedCategories.contains(category);
        return GestureDetector(
          onTap: () => _toggleCategorySelection(category),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF006FFD) : const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              category,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: isSelected ? const Color(0xFFFFFFFF) : const Color(0xFF006FFD),
                fontFamily: 'Inter',
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriceRangeFilter() {
    return Container(); // Placeholder for price range filter
  }

  Widget _buildColorFilter() {
    return Container(); // Placeholder for color filter
  }

  Widget _buildColorTags() {
    final selectedColors = _filters['colors'] as List<String>? ?? [];

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
      child: Column(
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
    return Row(
      children: colors.map((color) {
        final isSelected = selectedColors.contains(color);
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
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
                color,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? const Color(0xFFFFFFFF)
                      : const Color(0xFF006FFD),
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSizeFilter() {
    return Container(); // Placeholder for size filter
  }

  Widget _buildCustomerReviewsFilter() {
    return Container(); // Placeholder for customer reviews filter
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

  int _getSelectedCount(String filterType) {
    switch (filterType) {
      case 'categories':
        return (_filters['categories'] as List<String>? ?? []).length;
      case 'colors':
        return (_filters['colors'] as List<String>? ?? []).length;
      case 'sizes':
        return (_filters['sizes'] as List<String>? ?? []).length;
      default:
        return 0;
    }
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
