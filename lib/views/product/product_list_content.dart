import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../di/injection_container.dart';
import '../../viewmodels/product_viewmodel.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';

/// Contenu de la liste des produits (sans wrapper MainLayout)
class ProductListContent extends StatefulWidget {
  const ProductListContent({super.key});

  @override
  State<ProductListContent> createState() => _ProductListContentState();
}

class _ProductListContentState extends State<ProductListContent> {
  late final ProductViewModel _viewModel;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ProductViewModel>();
    _viewModel.loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<ProductViewModel>(
        builder: (context, viewModel, child) {
          return Text(
            'Liste des Produits',
            style: AppTheme.headingLarge,
          );
      
      
      
        },
      ),
    );
  }

  Widget _buildProductList(ProductViewModel viewModel, AppLocalizations tr) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(viewModel.errorMessage ?? tr.error),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: viewModel.loadProducts,
              child: Text(tr.retry),
            ),
          ],
        ),
      );
    }

    if (!viewModel.hasProducts) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(tr.noProducts),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: viewModel.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: viewModel.products.length,
        itemBuilder: (context, index) {
          final product = viewModel.products[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              title: Text(
                product.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.formattedPrice,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                context.go('/products/${product.id}');
              },
            ),
          );
        },
      ),
    );
  }
}
