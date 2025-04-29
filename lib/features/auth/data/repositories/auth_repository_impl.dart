import 'package:bento_store/core/services/interface/secure_storage.dart';
import 'package:bento_store/core/utils/error_handler.dart';
import 'package:bento_store/features/auth/domain/entities/auth_credentials.dart';
import 'package:bento_store/features/auth/domain/repositories/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SecureStorage _secureStorage;
  final Dio _networkService;

  // AuthRepositoryImpl(this._secureStorage, this._networkService);

  static const String _tokenKey = 'admin_token';
  static const String _tokenExpiryKey = 'admin_token_expiry';
  static const int _sessionTimeoutMinutes = 30;

  AuthRepositoryImpl(this._networkService, this._secureStorage);

  @override
  Future<String?> getToken() async {
    if (await _isSessionExpired()) {
    await logout();
    return null;
    }

    await _saveExpiryTimestamp();
    return await _secureStorage.getToken(key: _tokenKey);
  }

  @override
  Future<bool> isAuthenticated() async {
    final hasToken = await _secureStorage.hasToken(key: _tokenKey);
    if (!hasToken) return false;

    return !await _isSessionExpired();
  }

  @override
  Future<String> login(AuthCredentials credentials) async {
    try {
      final response = await _networkService.post('/auth/login', data: credentials.toJson());

      if (response.statusCode == 200) {
        final token = response.data['token'] as String;
        await _secureStorage.saveToken(key: _tokenKey, value: token);
        await _saveExpiryTimestamp();

        return token;
      } else {
        throw AppException('Falha na autenticação');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AppException('Usuário ou senha inválidos');
      }

      throw AppException(e.error.toString());
    } catch (e) {
      throw AppException('Erro inesperado durante a autenticação: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    await _secureStorage.deleteToken(key: _tokenKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenExpiryKey);
  }

  @override
  Future<bool> refreshSession() async {
    final hasToken = await _secureStorage.hasToken(key: _tokenKey);
    if (!hasToken) return false;

    await _saveExpiryTimestamp();
    return true;
  }

  Future<void> _saveExpiryTimestamp() async {
    final expiryTime =
        DateTime.now().add(Duration(minutes: _sessionTimeoutMinutes)).millisecondsSinceEpoch;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_tokenExpiryKey, expiryTime);
  }

  Future<bool> _isSessionExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryTimestamp = prefs.getInt(_tokenExpiryKey);

    if (expiryTimestamp == null) return true;

    final now = DateTime.now().millisecondsSinceEpoch;
    return now > expiryTimestamp;
  }
}
