class ApiConstants {
  // Base URLs
  static const String baseUrl = 'https://api.escuelajs.co/api/v1';
  
  // Endpoints
  static const String products = '/products';
  static const String categories = '/categories';
  
  // Methods
  static String getProduct(int id) => '$products/$id';
  static String updateProduct(int id) => '$products/$id';
  static String deleteProduct(int id) => '$products/$id';
}