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
      // Show loading while refreshing (centered loading indicator)
      emit(const ProductLoading());
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

    try {
      _logger.info('Updating product: ${event.productId}');

      final updatedProduct = await _productRepository.updateProduct(
        event.productId,
        title: event.title,
        price: event.price,
      );

      _logger.info('Product updated successfully: ${updatedProduct.title}');

      emit(const ProductOperationSuccess(
          message: 'Product updated successfully!'));

      // Update the product in the current list
      if (currentState is ProductLoaded) {
        final updatedProducts = currentState.products.map((product) {
          if (product.id == event.productId) {
            return updatedProduct;
          }
          return product;
        }).toList();

        emit(ProductLoaded(products: updatedProducts));
      } else if (currentState is ProductDetailLoaded) {
        emit(ProductDetailLoaded(product: updatedProduct));
      } else {
        // If not in a loaded state, refresh the list
        add(const RefreshProducts());
      }
    } catch (e) {
      _logger.error('Failed to update product', e);

      // Emit an operation failure (so UI can show a snack) but don't replace the list
      emit(ProductOperationFailure(message: e.toString()));

      // Restore previous state immediately
      if (currentState is ProductLoaded) {
        emit(currentState);
      } else if (currentState is ProductDetailLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> _onDeleteProduct(
    DeleteProduct event,
    Emitter<ProductState> emit,
  ) async {
    final currentState = state;

    try {
      _logger.info('Deleting product: ${event.productId}');

      final success = await _productRepository.deleteProduct(event.productId);

      if (success) {
        _logger.info('Product deleted successfully');
        emit(const ProductOperationSuccess(
            message: 'Product deleted successfully!'));

        // Remove from current list
        if (currentState is ProductLoaded) {
          final updatedProducts = currentState.products
              .where((product) => product.id != event.productId)
              .toList();
          emit(ProductLoaded(products: updatedProducts));
        } else {
          // Refresh the list
          add(const RefreshProducts());
        }
      } else {
        throw Exception('Delete operation failed');
      }
    } catch (e) {
      _logger.error('Failed to delete product', e);
      emit(ProductError(message: e.toString()));

      // Restore previous state
      if (currentState is ProductLoaded) {
        emit(currentState);
      }
    }
  }
}
