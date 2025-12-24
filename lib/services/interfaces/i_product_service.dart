import '../../models/request/create_product_request.dart';
import '../../models/response/product_response.dart';

abstract class IProductService {
  Future<List<ProductResponse>> getProducts();
  Future<ProductResponse> getProductById(String id);
  Future<ProductResponse> createProduct(CreateProductRequest request);
  Future<ProductResponse> updateProduct(String id, CreateProductRequest request);
  Future<void> deleteProduct(String id);
  Future<List<ProductResponse>> searchProducts(String query);
}
