import 'dart:convert';
import 'dart:developer';

import 'package:bento_store/core/services/interface/cache_service.dart';

abstract class BaseRepository {
  final CacheService _cacheService;

  BaseRepository(this._cacheService);

  Future<T?> getFromCache<T>(String key, T Function(Map<String, dynamic>) fromJson) async {
    final cachedData = await _cacheService.get(key);
    if (cachedData == null) return null;

    try {
      if (cachedData is String) {
        if (cachedData.startsWith('{') && cachedData.endsWith('}')) {
          return fromJson(jsonDecode(cachedData));
        } else {
          return null;
        }
      }
      return fromJson(cachedData as Map<String, dynamic>);
    } catch (e) {
      log('Erro ao converter cache: $e');
      return null;
    }
  }

  Future<void> saveToCache<T>(
    String key,
    T data,
    Map<String, dynamic> Function(T) toJson,
    {Duration? expiration}
  ) async {
    final jsonData = toJson(data);
    final jsonString = jsonEncode(jsonData);
    await _cacheService.save(key, jsonString, expiration: expiration);
  }

  Future<void> clearCache(String key) async {
    await _cacheService.remove(key);
  }
}
