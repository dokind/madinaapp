import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:madinaapp/home/widgets/order_card.dart';
import 'package:madinaapp/models/models.dart';
import 'package:madinaapp/products/products.dart';
import 'filter_button.dart';

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  Map<String, dynamic> _filters = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: 16),
          // Search Bar
          _buildSearchBar(),
          const SizedBox(height: 16),
          // Filter Controls
          _buildFilterControls(),
          const SizedBox(height: 24),
          // Divider
          _buildDivider(),
          const SizedBox(height: 12),
          // Total Summary
          _buildTotalSummary(),
          const SizedBox(height: 12),
          // Order Cards
          _buildOrderCards(),
          const SizedBox(height: 100), // Bottom spacing for navigation
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        border: Border(
          bottom: BorderSide(color: Color(0xFFF8F9FE), width: 1),
        ),
      ),
      child: const Center(
        child: Text(
          'Ваши заказы',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2024),
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FE),
          borderRadius: BorderRadius.circular(24),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: const InputDecoration(
            hintText: 'Поиск заказов...',
            hintStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF8F9098),
              fontFamily: 'Inter',
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Color(0xFF2F3036),
              size: 16,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          ),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF1F2024),
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }

  Widget _buildFilterControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSortButton(),
          _buildFilterButton(),
        ],
      ),
    );
  }

  Widget _buildSortButton() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFC5C6CC), width: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(
              Icons.sort,
              color: Color(0xFF8F9098),
              size: 12,
            ),
            SizedBox(width: 8),
            Text(
              'Сортировка',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF1F2024),
                fontFamily: 'Inter',
              ),
            ),
            SizedBox(width: 12),
            Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFFC5C6CC),
              size: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return FilterButton(
      filters: _filters,
      onFiltersChanged: (filters) {
        setState(() {
          _filters = filters;
        });
      },
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: const Color(0xFFF8F9FE),
    );
  }

  Widget _buildTotalSummary() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Всего (4)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2024),
              fontFamily: 'Inter',
            ),
          ),
          Text(
            '91000.00 Som',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2024),
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCards() {
    return BlocBuilder<ProductsBloc, ProductsState>(
      builder: (context, state) {
        if (state.status == ProductsStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == ProductsStatus.failure) {
          return Center(child: Text('Error: ${state.error}'));
        }

        final filteredOrders = _getFilteredOrders(state.orders);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: filteredOrders
                .map((order) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: OrderCard(order: order),
                    ))
                .toList(),
          ),
        );
      },
    );
  }

  List<Order> _getFilteredOrders(List<Order> orders) {
    var filteredOrders = orders;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filteredOrders = filteredOrders.where((Order order) {
        return order.customerName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            (order.description
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false) ||
            order.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (order.category
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false);
      }).toList();
    }

    // Filter by categories
    final selectedCategories = _filters['categories'] as List<String>? ?? [];
    if (selectedCategories.isNotEmpty) {
      filteredOrders = filteredOrders.where((Order order) {
        return order.category != null &&
            selectedCategories.contains(order.category);
      }).toList();
    }

    return filteredOrders;
  }
}
