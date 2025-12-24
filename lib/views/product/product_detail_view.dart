import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../di/injection_container.dart';
import '../../viewmodels/product_viewmodel.dart';
import '../../core/localization/app_localizations.dart';

class ProductDetailView extends StatefulWidget {
  final String productId;

  const ProductDetailView({super.key, required this.productId});

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  late final ProductViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ProductViewModel>();
    _viewModel.loadProductById(widget.productId);
  }

  @override
  void dispose() {
    _viewModel.clearSelectedProduct();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          title: Text(tr.productDetails),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                // TODO: Navigation vers édition
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showDeleteDialog(context, tr),
            ),
          ],
        ),
        body: Consumer<ProductViewModel>(
          builder: (context, viewModel, child) {
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
                      onPressed: () => viewModel.loadProductById(widget.productId),
                      child: Text(tr.retry),
                    ),
                  ],
                ),
              );
            }

            final product = viewModel.selectedProduct;
            if (product == null) {
              return const Center(child: Text('Produit non trouvé'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image placeholder
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      size: 80,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Titre
                  Text(
                    product.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),

                  // Prix
                  Text(
                    product.formattedPrice,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Stock
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: product.isInStock
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      product.isInStock
                          ? 'En stock (${product.stockQuantity})'
                          : 'Rupture de stock',
                      style: TextStyle(
                        color: product.isInStock ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    tr.description,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, AppLocalizations tr) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr.delete),
        content: const Text('Voulez-vous vraiment supprimer ce produit ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await _viewModel.deleteProduct(widget.productId);
              if (success && mounted) {
                Navigator.pop(context);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(tr.delete),
          ),
        ],
      ),
    );
  }
}
