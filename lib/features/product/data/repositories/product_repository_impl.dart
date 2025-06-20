import 'package:bento_store/core/utils/error_handler.dart';
import 'package:bento_store/features/product/domain/entities/product.dart';
import 'package:bento_store/features/product/domain/repositories/product_repository.dart';
import 'package:dio/dio.dart';

class ProductRepositoryImpl extends ProductRepository {
  final Dio _networkService;
  static const Duration _cacheExpiration = Duration(minutes: 5);

  ProductRepositoryImpl(super.cacheService, this._networkService);

  @override
  Future<void> clearSelectedProducts() async {
    await clearCache('selected_products');
  }

  @override
  Future<List<String>> getCategories({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final cachedCategories = await getFromCache<List<dynamic>>(
          'categories',
          (json) => (json['categories'] as List).cast<String>(),
        );
        if (cachedCategories != null) {
          return cachedCategories.cast<String>();
        }
      }

      final allProducts = await getProducts(forceRefresh: forceRefresh);
      final categories = allProducts.map((product) => product.category).toSet().toList()..sort();
      await saveToCache(
        'categories',
        categories,
        (category) => {'categories': category},
        expiration: _cacheExpiration,
      );
      return categories;
    } on DioException catch (e) {
      throw AppException('Erro ao buscar categorias: ${e.message}');
    } catch (e) {
      throw AppException('Erro ao buscar categorias: $e');
    }
  }

  @override
  Future<Product> getProductById(int id) {
    // TODO: implement getProductById
    throw UnimplementedError();
  }

  @override
  Future<List<Product>> getProducts({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final cachedProducts = await getFromCache<List<Product>>(
          'products',
          (json) =>
              (json['products'] as List)
                  .map((item) => Product.fromJson(item as Map<String, dynamic>))
                  .toList(),
        );
        if (cachedProducts != null) {
          return cachedProducts.cast<Product>();
        }
      }

      final response = await _networkService.get('/products');
      final products =
          (response.data as List)
              .map((json) => Product.fromJson(json as Map<String, dynamic>))
              .toList();

      await saveToCache(
        'products',
        products,
        (products) => {'products': products.map((p) => p.toJson()).toList()},
        expiration: _cacheExpiration,
      );
      return products;
    } on DioException catch (e) {
      throw AppException('Erro ao buscar produtos: ${e.error}');
    } catch (e) {
      throw AppException('Erro ao buscar produtos: $e');
    }
  }

  @override
  Future<List<Product>> getProductsByCategory(String category, {bool forceRefresh = false}) async {
    try {
      final cacheKey = 'products_category_$category';
      if (!forceRefresh) {
        final cachedProducts = await getFromCache<List<dynamic>>(
          cacheKey,
          (json) =>
              (json['products'] as List)
                  .map((item) => Product.fromJson(item as Map<String, dynamic>))
                  .toList(),
        );
        if (cachedProducts != null) {
          return cachedProducts.cast<Product>();
        }
      }

      final allProducts = await getProducts(forceRefresh: forceRefresh);
      final filteredProducts = allProducts.where((p) => p.category == category).toList();

      await saveToCache(
        cacheKey,
        filteredProducts,
        (products) => {'products': products.map((p) => p.toJson()).toList()},
        expiration: _cacheExpiration,
      );
      return filteredProducts;
    } on DioException catch (e) {
      throw AppException('Erro ao buscar produtos por categoria: ${e.error}');
    } catch (e) {
      throw AppException('Erro ao buscar produtos por categoria: $e');
    }
  }

  @override
  Future<List<Product>> getSelectedProducts() async {
    final cachedProducts = await getFromCache<List<dynamic>>(
      'selected_products',
      (json) =>
          (json['products'] as List)
              .map((item) => Product.fromJson(item as Map<String, dynamic>))
              .toList(),
    );
    return cachedProducts?.cast<Product>() ?? [];
  }

  @override
  Future<void> saveSelectedProducts(List<Product> products) async {
    await saveToCache(
      'selected_products',
      products,
      (products) => {'products': products.map((p) => p.toJson()).toList()},
      expiration: null,
    );
  }
}
