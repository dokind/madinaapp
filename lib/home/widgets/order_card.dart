import 'package:flutter/material.dart';
import 'package:madinaapp/models/models.dart';
import 'package:madinaapp/home/view/order_detail_page.dart';

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final statusColors = _getOrderStatusColors(order.status);
    final statusText = _getOrderStatusText(order.status);
    final totalAmount = _calculateOrderTotal(order);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => OrderDetailPage(order: order),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: statusColors['bgColor'],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Image section
            _buildImageSection(),
            // Content section
            Expanded(
              child:
                  _buildContentSection(statusText, statusColors, totalAmount),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    final imageUrl = order.products.isNotEmpty
        ? order.products.first.imagePath
        : 'assets/images/1.png';

    return Container(
      width: 80,
      height: 113,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(imageUrl),
                  fit: BoxFit.cover,
                  onError: (error, stackTrace) {
                    // Handle image loading error
                  },
                ),
              ),
            ),
          ),
          // Pagination dots
          _buildPaginationDots(),
        ],
      ),
    );
  }

  Widget _buildPaginationDots() {
    return Positioned(
      bottom: 8,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildDot(isActive: false),
          const SizedBox(width: 4),
          _buildDot(isActive: true),
          const SizedBox(width: 4),
          _buildDot(isActive: false),
          const SizedBox(width: 4),
          _buildDot(isActive: false),
        ],
      ),
    );
  }

  Widget _buildDot({required bool isActive}) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF006FFD) : const Color(0xFFFFFFFF),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildContentSection(
    String statusText,
    Map<String, Color> statusColors,
    double totalAmount,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status tag
          _buildStatusTag(statusText, statusColors),
          const SizedBox(height: 4),
          // Customer name and amount
          _buildCustomerRow(totalAmount),
          const SizedBox(height: 4),
          // Description
          _buildDescription(),
          const SizedBox(height: 4),
          // Time ago
          _buildTimeAgo(),
        ],
      ),
    );
  }

  Widget _buildStatusTag(String statusText, Map<String, Color> statusColors) {
    return Container(
      decoration: BoxDecoration(
        color: statusColors['statusBgColor'],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Text(
          statusText.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: statusColors['statusTextColor'],
            fontFamily: 'Inter',
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerRow(double totalAmount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          order.customerName,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2024),
            fontFamily: 'Inter',
          ),
        ),
        Text(
          '${totalAmount.toStringAsFixed(2)} Som',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2024),
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      order.description ?? '',
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Color(0xFF71727A),
        fontFamily: 'Inter',
        letterSpacing: 0.12,
        height: 1.33,
      ),
    );
  }

  Widget _buildTimeAgo() {
    return Text(
      order.timeAgo ?? '',
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: Color(0xFF71727A),
        fontFamily: 'Inter',
        letterSpacing: 0.1,
        height: 1.6,
      ),
    );
  }

  double _calculateOrderTotal(Order order) {
    return order.products.fold(0.0, (sum, product) => sum + product.price);
  }

  Map<String, Color> _getOrderStatusColors(OrderStatus status) {
    switch (status) {
      case OrderStatus.actionRequired:
        return {
          'bgColor': const Color(0xFFF8F9FE),
          'statusBgColor': const Color(0xFFEAF2FF),
          'statusTextColor': const Color(0xFF006FFD),
        };
      case OrderStatus.refundRequested:
        return {
          'bgColor': const Color(0xFFFFF4E4),
          'statusBgColor': const Color(0xFFFFB37C),
          'statusTextColor': const Color(0xFFFFFFFF),
        };
      case OrderStatus.processing:
        return {
          'bgColor': const Color(0xFFF0F9FF),
          'statusBgColor': const Color(0xFF22C55E),
          'statusTextColor': const Color(0xFFFFFFFF),
        };
      case OrderStatus.completed:
        return {
          'bgColor': const Color(0xFFF0FDF4),
          'statusBgColor': const Color(0xFF16A34A),
          'statusTextColor': const Color(0xFFFFFFFF),
        };
      case OrderStatus.pending:
        return {
          'bgColor': const Color(0xFFFFF9E6),
          'statusBgColor': const Color(0xFFFFC107),
          'statusTextColor': const Color(0xFFFFFFFF),
        };
    }
  }

  String _getOrderStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.actionRequired:
        return 'Действие необходимо';
      case OrderStatus.refundRequested:
        return 'Возмещение запросило';
      case OrderStatus.processing:
        return 'Обработка';
      case OrderStatus.completed:
        return 'Завершено';
      case OrderStatus.pending:
        return 'В ожидании';
    }
  }
}
