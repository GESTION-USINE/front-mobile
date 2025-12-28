class ApiEndpoints {
  ApiEndpoints._();

  // Base URL
  static const String baseUrl = 'http://localhost:3000/api';

  // Auth
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';


  // Client Material Prices
  static const String clientMaterialPrices = '/materials/client-material-prices';



  // client 

  // ignore: constant_identifier_names
  static const String all_clients = '/clients';
  // ignore: constant_identifier_names
  static const String create_client = '/clients/';

  // Materials
  // ignore: constant_identifier_names
  static const String all_materials = '/materials';
  // ignore: constant_identifier_names
  static const String create_material = '/materials/';

  // User
  static const String users = '/users';
  static const String userProfile = '/users/profile';

  // Products
  static const String products = '/products';
  
  static String userById(String userId) => '/users/$userId';

}
