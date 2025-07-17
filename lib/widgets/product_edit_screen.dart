import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:madinaapp/models/models.dart';
import 'package:madinaapp/products/products.dart';

class ProductEditScreen extends StatefulWidget {
  final Product product;
  final void Function(Product) onSave;
  final VoidCallback onCancel;

  const ProductEditScreen({
    super.key,
    required this.product,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _categoryController;
  late String _selectedColor;
  late String _selectedUnit;
  late List<ProductColor> _availableColors;

  final List<String> _units = ['метр', 'м²', 'двор', 'штука', 'кг', 'литр'];
  final List<String> _categories = [
    'Шелковая ткань',
    'Льняная ткань',
    'Хлопковая ткань',
    'Шерстяная ткань',
    'Синтетика'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _descriptionController =
        TextEditingController(text: widget.product.description);
    _priceController =
        TextEditingController(text: widget.product.price.toString());

    // Initialize available colors first
    _availableColors = List.from(widget.product.availableColors);
    if (_availableColors.isEmpty) {
      // Add a default color if none exist
      _availableColors.add(ProductColor(
        name: widget.product.color,
        colorValue: 0xFF000000, // Default black
        isSelected: true,
      ));
    }

    // Set selected color, ensure it exists in available colors
    _selectedColor = widget.product.color;
    if (!_availableColors.any((c) => c.name == widget.product.color)) {
      // Add the current color if it doesn't exist in available colors
      _availableColors.add(ProductColor(
        name: widget.product.color,
        colorValue: 0xFF000000, // Default black
        isSelected: true,
      ));
    }

    // Ensure the category exists in the list, if not use the first one
    if (_categories.contains(widget.product.category)) {
      _categoryController =
          TextEditingController(text: widget.product.category);
    } else {
      // If category doesn't match, use the first available category
      _categoryController = TextEditingController(text: _categories.first);
    }

    // Ensure the unit exists in the list, if not use the first one
    if (_units.contains(widget.product.unit)) {
      _selectedUnit = widget.product.unit;
    } else {
      // If unit doesn't match, use the first available unit
      _selectedUnit = _units.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _saveProduct() {
    final editedProduct = Product(
      id: widget.product.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.tryParse(_priceController.text) ?? widget.product.price,
      imagePath: widget.product.imagePath,
      category: _categoryController.text.trim(),
      color: _selectedColor,
      images: widget.product.images,
      availableColors: _availableColors,
      unit: _selectedUnit,
      isFavorite: widget.product.isFavorite,
    );

    // Update the product in the ProductsBloc
    context.read<ProductsBloc>().add(ProductUpdated(editedProduct));

    // Call the original callback
    widget.onSave(editedProduct);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top navigation bar
          Container(
            height: 44,
            color: Colors.white,
          ),
          Container(
            height: 56,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                GestureDetector(
                  onTap: widget.onCancel,
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
                const Spacer(),
                const Text(
                  'Редактировать продукт',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2024),
                    fontFamily: 'Inter',
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _saveProduct,
                  child: const Text(
                    'Сохранить',
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

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image Preview
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF2FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        widget.product.imagePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Product Name
                  _buildTextField(
                    label: 'Название продукта',
                    controller: _nameController,
                    hint: 'Введите название продукта',
                  ),
                  const SizedBox(height: 16),

                  // Product Description
                  _buildTextField(
                    label: 'Описание',
                    controller: _descriptionController,
                    hint: 'Введите описание продукта',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Category
                  _buildDropdownField(
                    label: 'Категория',
                    value: _categories.contains(_categoryController.text)
                        ? _categoryController.text
                        : _categories.first,
                    items: _categories,
                    onChanged: (value) {
                      setState(() {
                        _categoryController.text = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Price and Unit
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildTextField(
                          label: 'Цена',
                          controller: _priceController,
                          hint: '0.00',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdownField(
                          label: 'Единица',
                          value: _units.contains(_selectedUnit)
                              ? _selectedUnit
                              : _units.first,
                          items: _units,
                          onChanged: (value) {
                            setState(() {
                              _selectedUnit = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Color Selection
                  const Text(
                    'Цвет',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2024),
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _availableColors.map((color) {
                      final isSelected = color.name == _selectedColor;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedColor = color.name;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF006FFD)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF006FFD)
                                  : const Color(0xFFE5E7EB),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Color(color.colorValue),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                color.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF6B7280),
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Save Button
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006FFD),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Сохранить изменения',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2024),
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Inter',
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontFamily: 'Inter',
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF006FFD)),
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2024),
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Inter',
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              isExpanded: true,
            ),
          ),
        ),
      ],
    );
  }
}
