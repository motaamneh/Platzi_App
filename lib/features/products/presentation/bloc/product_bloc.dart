import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/product_repository.dart';
import '../../../../managers/logger_manager.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _productRepository;
  final LoggerManager _logger = LoggerManager();
  
  ProductBloc({required ProductRepository productRepository})
      : _productRepository = productRepository,
        super(const ProductInitial()) {
    
    on<FetchProducts>(_onFetchProducts);
    on<RefreshProducts>(_onRefreshProducts);
    on<FetchProductDetail>(_onFetchProductDetail);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
  }
  
  Future<void> _onFetchProducts(
    FetchProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    
    try {
      _logger.info('Fetching products');
      final products = await _productRepository.getProducts();
      _logger.info('Products fetched successfully');
      emit(ProductLoaded(products: products));
    } catch (e) {
      _logger.error('Failed to fetch products', e);
      emit(ProductError(message: e.toString()));
    }
  }
  
  Future<void> _onRefreshProducts(
    RefreshProducts event,
    Emitter<ProductState> emit,
  ) async {
    try {
      _logger.info('Refreshing products');
      final products = await _productRepository.getProducts();
      _logger.info('Products refreshed successfully');
      emit(ProductLoaded(products: products));
    } catch (e) {
      _logger.error('Failed to refresh products', e);
      emit(ProductError(message: e.toString()));
    }
  }
  
  Future<void> _onFetchProductDetail(
    FetchProductDetail event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductDetailLoading());
    
    try {
      _logger.info('Fetching product detail: ${event.productId}');
      final product = await _productRepository.getProduct(event.productId);
      _logger.info('Product detail fetched successfully');
      emit(ProductDetailLoaded(product: product));
    } catch (e) {
      _logger.error('Failed to fetch product detail', e);
      emit(ProductDetailError(message: e.toString()));
    }
  }
  
  Future<void> _onUpdateProduct(
    UpdateProduct event,
    Emitter<ProductState> emit,
  ) async {
    final currentState = state;
    emit(const ProductOperationLoading());
    
    try {
      _logger.info('Updating product: ${event.productId}');
      await _productRepository.updateProduct(
        event.productId,
        title: event.title,
        price: event.price,
      );
      _logger.info('Product updated successfully');
      
      emit(const ProductOperationSuccess(message: 'Product updated successfully'));
      
      // Refresh the list
      if (currentState is ProductLoaded) {
        add(const RefreshProducts());
      }
    } catch (e) {
      _logger.error('Failed to update product', e);
      emit(ProductError(message: e.toString()));
      if (currentState is ProductLoaded) {
        emit(currentState);
      }
    }
  }
  
  Future<void> _onDeleteProduct(
    DeleteProduct event,
    Emitter<ProductState> emit,
  ) async {
    final currentState = state;
    emit(const ProductOperationLoading());
    
    try {
      _logger.info('Deleting product: ${event.productId}');
      await _productRepository.deleteProduct(event.productId);
      _logger.info('Product deleted successfully');
      
      emit(const ProductOperationSuccess(message: 'Product deleted successfully'));
      
      // Remove from current list
      if (currentState is ProductLoaded) {
        final updatedProducts = currentState.products
            .where((product) => product.id != event.productId)
            .toList();
        emit(ProductLoaded(products: updatedProducts));
      }
    } catch (e) {
      _logger.error('Failed to delete product', e);
      emit(ProductError(message: e.toString()));
      if (currentState is ProductLoaded) {
        emit(currentState);
      }
    }
  }
}