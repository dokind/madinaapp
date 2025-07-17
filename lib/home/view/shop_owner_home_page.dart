import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:madinaapp/authentication/bloc/bloc.dart';
import 'package:madinaapp/products/products.dart';
import 'package:madinaapp/home/widgets/shop_owner_navigation.dart';
import 'package:madinaapp/home/widgets/home_tab.dart';
import 'package:madinaapp/home/widgets/catalog_tab.dart';
import 'package:madinaapp/home/widgets/create_tab.dart';
import 'package:madinaapp/home/widgets/orders_tab.dart';
import 'package:madinaapp/home/widgets/settings_tab.dart';

class ShopOwnerHomePage extends StatefulWidget {
  const ShopOwnerHomePage({super.key});

  @override
  State<ShopOwnerHomePage> createState() => _ShopOwnerHomePageState();
}

class _ShopOwnerHomePageState extends State<ShopOwnerHomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          return SafeArea(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                const HomeTab(),
                const CatalogTab(),
                const CreateTab(),
                const OrdersTab(),
                SettingsTab(user: state.user),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: ShopOwnerNavigation(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });

          // If switching to catalog tab (index 1), refresh products
          if (index == 1 && context.mounted) {
            print(
                '🔄 SHOP_OWNER: Switching to catalog tab, refreshing products');
            context.read<ProductsBloc>().add(const ProductsLoaded());
          }
        },
      ),
    );
  }
}
