import '../models/product_model.dart';
import '../../../../managers/api_manager.dart';
import '../../../../managers/logger_manager.dart';
import '../../../../core/constants/api_constants.dart';

class ProductRepository {
  final ApiManager _apiManager = ApiManager();
  final LoggerManager _logger = LoggerManager();
  
  // Get all products
  Future<List<ProductModel>> getProducts({int limit = 20, int offset = 0}) async {
    try {
      _logger.info('Fetching products');
      
      final response = await _apiManager.get(
        '${ApiConstants.products}?limit=$limit&offset=$offset',
      );
      
      final List<dynamic> productsJson = response as List<dynamic>;
      final products = productsJson
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
      
      _logger.info('Fetched ${products.length} products');
      return products;
    } catch (e) {
      _logger.error('Failed to fetch products', e);
      throw Exception('Failed to load products: $e');
    }
  }
  
  // Get single product
  Future<ProductModel> getProduct(int id) async {
    try {
      _logger.info('Fetching product: $id');
      
      final response = await _apiManager.get(ApiConstants.getProduct(id));
      
      final product = ProductModel.fromJson(response as Map<String, dynamic>);
      
      _logger.info('Fetched product: ${product.title}');
      return product;
    } catch (e) {
      _logger.error('Failed to fetch product: $id', e);
      throw Exception('Failed to load product: $e');
    }
  }
  
  // Update product
  Future<ProductModel> updateProduct(int id, {String? title, double? price}) async {
    try {
      _logger.info('Updating product: $id');
      
      final Map<String, dynamic> body = {};
      if (title != null) body['title'] = title;
      if (price != null) body['price'] = price;
      
      final response = await _apiManager.put(
        ApiConstants.updateProduct(id),
        body,
      );
      
      final product = ProductModel.fromJson(response as Map<String, dynamic>);
      
      _logger.info('Updated product: ${product.title}');
      return product;
    } catch (e) {
      _logger.error('Failed to update product: $id', e);
      throw Exception('Failed to update product: $e');
    }
  }
  
  // Delete product
  Future<bool> deleteProduct(int id) async {
    try {
      _logger.info('Deleting product: $id');
      
      await _apiManager.delete(ApiConstants.deleteProduct(id));
      
      _logger.info('Deleted product: $id');
      return true;
    } catch (e) {
      _logger.error('Failed to delete product: $id', e);
      throw Exception('Failed to delete product: $e');
    }
  }
}