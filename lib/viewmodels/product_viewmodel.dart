import '../core/base/base_viewmodel.dart';
import '../models/request/create_product_request.dart';
import '../models/response/product_response.dart';
import '../services/interfaces/i_product_service.dart';

class ProductViewModel extends BaseViewModel {
  final IProductService _productService;

  ProductViewModel(this._productService);

  List<ProductResponse> _products = [];
  ProductResponse? _selectedProduct;
  String _searchQuery = '';

  List<ProductResponse> get products => _products;
  ProductResponse? get selectedProduct => _selectedProduct;
  String get searchQuery => _searchQuery;
  bool get hasProducts => _products.isNotEmpty;

  /// Charger tous les produits
  Future<void> loadProducts() async {
    final result = await runAsync(() => _productService.getProducts());

    if (result != null) {
      _products = result;
      notifyListeners();
    }
  }

  /// Charger un produit par ID
  Future<void> loadProductById(String id) async {
    final result = await runAsync(() => _productService.getProductById(id));

    if (result != null) {
      _selectedProduct = result;
      notifyListeners();
    }
  }

  /// Rechercher des produits
  Future<void> searchProducts(String query) async {
    _searchQuery = query;

    if (query.isEmpty) {
      await loadProducts();
      return;
    }

    final result = await runAsync(() => _productService.searchProducts(query));

    if (result != null) {
      _products = result;
      notifyListeners();
    }
  }

  /// Créer un produit
  Future<bool> createProduct(CreateProductRequest request) async {
    final result = await runAsync(() => _productService.createProduct(request));

    if (result != null) {
      _products.insert(0, result);
      notifyListeners();
      return true;
    }

    return false;
  }

  /// Mettre à jour un produit
  Future<bool> updateProduct(String id, CreateProductRequest request) async {
    final result = await runAsync(
      () => _productService.updateProduct(id, request),
    );

    if (result != null) {
      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        _products[index] = result;
      }
      if (_selectedProduct?.id == id) {
        _selectedProduct = result;
      }
      notifyListeners();
      return true;
    }

    return false;
  }

  /// Supprimer un produit
  Future<bool> deleteProduct(String id) async {
    final success = await runAsync(() async {
      await _productService.deleteProduct(id);
      return true;
    });

    if (success == true) {
      _products.removeWhere((p) => p.id == id);
      if (_selectedProduct?.id == id) {
        _selectedProduct = null;
      }
      notifyListeners();
      return true;
    }

    return false;
  }

  /// Effacer le produit sélectionné
  void clearSelectedProduct() {
    _selectedProduct = null;
    notifyListeners();
  }

  /// Rafraîchir les produits
  Future<void> refresh() async {
    if (_searchQuery.isNotEmpty) {
      await searchProducts(_searchQuery);
    } else {
      await loadProducts();
    }
  }
}
