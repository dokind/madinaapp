import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:madinaapp/models/models.dart';
import 'package:madinaapp/products/products.dart';
import 'product_card.dart';
import 'order_card.dart';

class HomeTab extends StatelessWidget {
  final User? user;

  const HomeTab({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header with search
          _buildHeader(),
          // Main content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Complete your content section
                _buildCompleteContentSection(),
                const SizedBox(height: 40),
                // Your orders section
                _buildOrdersSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: const Row(
        children: [
          Expanded(child: SizedBox()),
          Icon(
            Icons.search,
            size: 20,
            color: Color(0xFF2F3036),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Завершите свое содержимое',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2024),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 250,
          child: BlocBuilder<ProductsBloc, ProductsState>(
            builder: (context, state) {
              if (state.status == ProductsStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == ProductsStatus.failure) {
                return Center(child: Text('Error: ${state.error}'));
              }

              final featuredProducts = state.featuredProducts;

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: featuredProducts.length,
                itemBuilder: (context, index) {
                  final product = featuredProducts[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index == featuredProducts.length - 1 ? 0 : 12,
                    ),
                    child: ProductCard(product: product),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ваши заказы',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2024),
              ),
            ),
            Text(
              'Увидеть больше',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF006FFD),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Orders list
        BlocBuilder<ProductsBloc, ProductsState>(
          builder: (context, state) {
            if (state.status == ProductsStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == ProductsStatus.failure) {
              return Center(child: Text('Error: ${state.error}'));
            }

            final orders = state.orders;

            return Column(
              children: orders
                  .map((order) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: OrderCard(order: order),
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}
