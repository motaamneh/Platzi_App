import 'package:equatable/equatable.dart';
import '../../data/models/product_model.dart';

abstract class ProductState extends Equatable {
  const ProductState();
  
  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

class ProductLoading extends ProductState {
  const ProductLoading();
}

class ProductLoaded extends ProductState {
  final List<ProductModel> products;
  
  const ProductLoaded({required this.products});
  
  @override
  List<Object?> get props => [products];
}

class ProductError extends ProductState {
  final String message;
  
  const ProductError({required this.message});
  
  @override
  List<Object?> get props => [message];
}

// For single product detail
class ProductDetailLoading extends ProductState {
  const ProductDetailLoading();
}

class ProductDetailLoaded extends ProductState {
  final ProductModel product;
  
  const ProductDetailLoaded({required this.product});
  
  @override
  List<Object?> get props => [product];
}

class ProductDetailError extends ProductState {
  final String message;
  
  const ProductDetailError({required this.message});
  
  @override
  List<Object?> get props => [message];
}

// For update/delete operations
class ProductOperationLoading extends ProductState {
  const ProductOperationLoading();
}

class ProductOperationSuccess extends ProductState {
  final String message;
  
  const ProductOperationSuccess({required this.message});
  
  @override
  List<Object?> get props => [message];
}