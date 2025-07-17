import 'package:flutter/material.dart';

class ShopOwnerNavigation extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onItemSelected;

  const ShopOwnerNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        border: Border(
          top: BorderSide(
            color: Color(0xFFF8F9FE),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 32, left: 8, right: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(child: _buildNavItem(0, Icons.store, 'Дом')),
            Expanded(child: _buildNavItem(1, Icons.image, 'Каталог')),
            Expanded(child: _buildNavItem(2, Icons.camera_alt, 'Создавать')),
            Expanded(child: _buildNavItem(3, Icons.grid_view, 'Приказ')),
            Expanded(child: _buildNavItem(4, Icons.settings, 'Настройки')),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onItemSelected(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color:
                isSelected ? const Color(0xFF006FFD) : const Color(0xFFD4D6DD),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? const Color(0xFF1F2024)
                  : const Color(0xFF71727A),
            ),
          ),
        ],
      ),
    );
  }
}
