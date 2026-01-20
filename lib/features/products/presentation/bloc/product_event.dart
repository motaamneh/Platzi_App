import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();
  
  @override
  List<Object?> get props => [];
}

class FetchProducts extends ProductEvent {
  const FetchProducts();
}

class RefreshProducts extends ProductEvent {
  const RefreshProducts();
}

class FetchProductDetail extends ProductEvent {
  final int productId;
  
  const FetchProductDetail({required this.productId});
  
  @override
  List<Object?> get props => [productId];
}

class UpdateProduct extends ProductEvent {
  final int productId;
  final String? title;
  final double? price;
  
  const UpdateProduct({
    required this.productId,
    this.title,
    this.price,
  });
  
  @override
  List<Object?> get props => [productId, title, price];
}

class DeleteProduct extends ProductEvent {
  final int productId;
  
  const DeleteProduct({required this.productId});
  
  @override
  List<Object?> get props => [productId];
}