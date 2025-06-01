import 'package:dio/dio.dart';

import '../../../../core/utils/error_handler.dart';
import '../../../product/domain/entities/product.dart';
import '../../domain/entities/sale.dart';
import '../../domain/repositories/sale_repository.dart';

class SaleRepositoryImpl implements SaleRepository {
  final Dio _networkService;

  SaleRepositoryImpl(this._networkService);

  @override
  Future<Sale> createSale(int userId, List<Product> products) async {
    try {
      final response = await _networkService.post(
        '/carts',
        data: {
          'userId': userId,
          'date': DateTime.now().toIso8601String(),
          'products':
              products
                  .map(
                    (product) => {
                      'id': product.id,
                      'title': product.title,
                      'price': product.price,
                      'description': product.description,
                      'category': product.category,
                      'image': product.image,
                    },
                  )
                  .toList(),
        },
      );

      if (response.statusCode != 200) {
        throw AppException(
          'Falha ao criar venda: código ${response.statusCode}',
        );
      }
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        final List<dynamic> products = data['products'];

        return Sale(
          id: data['id'],
          userId: data['userId'],
          products:
              products
                  .map<Product>(
                    (product) => Product(
                      id: product['id'],
                      title: product['title'] ?? '',
                      price: (product['price'] ?? 0.0).toDouble(),
                      description: product['description'] ?? '',
                      category: product['category'] ?? '',
                      image: product['image'] ?? '',
                      rating: 0.0,
                      ratingCount: 0,
                    ),
                  )
                  .toList(),
        );
      }

      return Sale(id: 0, userId: 0, products: []);
    } on DioException catch (e) {
      throw AppException('Erro ao criar venda: ${e.error}');
    } catch (e) {
      throw AppException('Erro ao criar venda: ${e.toString()}');
    }
  }

  @override
  Future<void> cancelSale(int saleId) async {
    try {
      final response = await _networkService.delete('/carts/$saleId');

      if (response.statusCode != 200) {
        throw AppException(
          'Falha ao cancelar venda: código ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw AppException('Erro ao cancelar venda: ${e.error}');
    } catch (e) {
      throw AppException('Erro ao cancelar venda: ${e.toString()}');
    }
  }

  @override
  Future<List<Sale>> getSales() async {
    try {
      final response = await _networkService.get('/carts');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) {
          final List<dynamic> products = json['products'];
          return Sale(
            id: json['id'],
            userId: json['userId'],
            products:
                products
                    .map<Product>(
                      (product) => Product(
                        id: product['productId'],
                        title: product['title'] ?? '',
                        price: (product['price'] ?? 0.0).toDouble(),
                        description: product['description'] ?? '',
                        category: product['category'] ?? '',
                        image: product['image'] ?? '',
                        rating: 0.0,
                        ratingCount: 0,
                      ),
                    )
                    .toList(),
          );
        }).toList();
      } else {
        throw AppException(
          'Falha ao carregar vendas: código ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw AppException('Erro ao carregar vendas: ${e.error}');
    } catch (e) {
      throw AppException('Erro ao carregar vendas: ${e.toString()}');
    }
  }
}
