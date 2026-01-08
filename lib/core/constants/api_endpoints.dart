class ApiEndpoints {
  ApiEndpoints._();

  // Base URL
  static const String baseUrl = 'http://localhost:3000/api';
  //  static const String baseUrl = 'https://backend-a7rx.onrender.com/api';

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

  // Payments
  // ignore: constant_identifier_names
  static const String payments = '/payments';

  // Weighing Slips (Bons de pesée)
  // ignore: constant_identifier_names
  static const String all_weighing_slips = '/weighing-slips';
  // ignore: constant_identifier_names
  static const String create_weighing_slip = '/weighing-slips/';
  static String weighingSlipById(int id) => '/weighing-slips/$id';
  static String weighingSlipPrintById(int id) => '/weighing-slips/$id/print';

  // User
  static const String users = '/users';
  static const String userProfile = '/users/profile';

  // Products
  static const String products = '/products';
  
  static String userById(String userId) => '/users/$userId';

}
