import 'package:flutter/material.dart';
import 'filter_modal.dart';

class FilterButton extends StatefulWidget {
  final Map<String, dynamic> filters;
  final void Function(Map<String, dynamic>) onFiltersChanged;

  const FilterButton({
    super.key,
    required this.filters,
    required this.onFiltersChanged,
  });

  @override
  State<FilterButton> createState() => _FilterButtonState();
}

class _FilterButtonState extends State<FilterButton> {
  int get _activeFiltersCount {
    int count = 0;
    widget.filters.forEach((key, value) {
      if (value is List && value.isNotEmpty) {
        count += value.length;
      } else if (value != null && value != '' && value != false) {
        count++;
      }
    });
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showFilterModal,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFC5C6CC), width: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.filter_alt,
                color: Color(0xFF8F9098),
                size: 12,
              ),
              const SizedBox(width: 8),
              const Text(
                'Фильтр',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF1F2024),
                  fontFamily: 'Inter',
                ),
              ),
              if (_activeFiltersCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFF006FFD),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _activeFiltersCount.toString(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFFFFF),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterModal() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => FilterModal(
        onApplyFilters: widget.onFiltersChanged,
        initialFilters: widget.filters,
      ),
    );
  }
}
