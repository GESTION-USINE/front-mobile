import '../../models/request/login_request.dart';
import '../../models/response/login_response.dart';

abstract class IAuthService {
  Future<LoginResponse> login(LoginRequest request);
  Future<void> logout();
  Future<void> refreshToken();
}
