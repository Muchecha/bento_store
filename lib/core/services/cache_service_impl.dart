import 'package:bento_store/core/services/interface/cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheServiceImpl implements CacheService {
  static const String _selectedSellerKey = 'selectedSeller';
  static const String _selectedProductsKey = 'selectedProducts';

  final SharedPreferences _sharedPreferences;

  CacheServiceImpl(this._sharedPreferences);

  @override
  Future<void> clear() async {
    await _sharedPreferences.clear();
  }

  @override
  Future<dynamic> get(String key) async {
    final jsonString = _sharedPreferences.getString(key);
    if (jsonString == null) return null;

    final expiryTime = _sharedPreferences.getInt('${key}_expiry');
    if (expiryTime != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now > expiryTime) {
        await _sharedPreferences.remove(key);
        await _sharedPreferences.remove('${key}_expiry');
        return null;
      }
    }
    return jsonString;
  }

  @override
  Future<void> remove(String key) async {
    await _sharedPreferences.remove(key);
    await _sharedPreferences.remove('${key}_expiry');
  }

  @override
  Future<void> save(String key, data, {Duration? expiration}) async {
    final jsonString = data.toString();
    await _sharedPreferences.setString(key, jsonString);

    if (expiration != null) {
      final expiryTime = DateTime.now().add(expiration).millisecondsSinceEpoch;
      await _sharedPreferences.setInt('${key}_expiry', expiryTime);
    }
  }

  // Métodos específicos para manter compatibilidade
  Future<void> saveSelectedSeller(Map<String, dynamic> seller) async {
    await save(_selectedSellerKey, seller);
  }

  Future<Map<String, dynamic>?> getSelectedSeller() async {
    final data = await get(_selectedSellerKey);
    return data as Map<String, dynamic>?;
  }

  Future<void> saveSelectedProducts(List<Map<String, dynamic>> products) async {
    await save(_selectedProductsKey, {'products': products});
  }

  Future<List<Map<String, dynamic>>> getSelectedProducts() async {
    final data = await get(_selectedProductsKey);
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(data['products'] ?? []);
  }
}
