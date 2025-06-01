import 'package:bento_store/features/auth/domain/entities/auth_credentials.dart';

abstract class AuthRepository {
  Future<String> login(AuthCredentials credentials);
  Future<void> logout();
  Future<bool> isAuthenticated();
  Future<String?> getToken();
  Future<bool> refreshSession();
}