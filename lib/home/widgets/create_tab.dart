import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:madinaapp/home/view/camera_page_new.dart';
import 'package:madinaapp/products/products.dart';

class CreateTab extends StatelessWidget {
  const CreateTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () async {
              // Navigate to camera page and await result
              final result = await Navigator.of(context).push<bool>(
                MaterialPageRoute<bool>(
                  builder: (context) => const CameraPage(),
                ),
              );

              // If products were created, refresh the products bloc
              if (result == true && context.mounted) {
                print(
                    '🔄 CREATE_TAB: Products were created, refreshing catalog');
                context.read<ProductsBloc>().add(const ProductsLoaded());
              }
            },
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF006FFD),
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF006FFD).withOpacity(0.3),
                    spreadRadius: 4,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 48,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Создание продукта',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2024),
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Нажмите камеру, чтобы начать\nзапись видео для создания продуктов',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF71727A),
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}
