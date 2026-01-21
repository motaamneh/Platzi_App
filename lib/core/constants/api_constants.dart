class ApiConstants {
  
  static const String baseUrl = 'https://api.escuelajs.co/api/v1';
  

  static const String products = '/products';
  static const String categories = '/categories';
  
  
  static String getProduct(int id) => '$products/$id';
  static String updateProduct(int id) => '$products/$id';
  static String deleteProduct(int id) => '$products/$id';
}