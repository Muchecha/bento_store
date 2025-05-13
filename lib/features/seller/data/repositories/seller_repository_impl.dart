import 'package:bento_store/core/utils/error_handler.dart';
import 'package:bento_store/features/seller/domain/entities/seller.dart';
import 'package:bento_store/features/seller/domain/repositories/seller_repository.dart';
import 'package:dio/dio.dart';

class SellerRepositoryImpl extends SellerRepository {
  final Dio _networkService;

  SellerRepositoryImpl(super.cacheService, this._networkService);

  @override
  Future<void> clearSelectedSeller() async {
    try {
      await clearCache('selectedSeller');
    } catch (e) {
      throw Exception('Erro ao limpar vendedor selecionado: ${e.toString()}');
    }
  }

  @override
  Future<Seller?> getSelectedSeller() async {
    try {
      return await getFromCache<Seller>('selectedSeller', Seller.fromMap);
    } catch (e) {
      throw Exception('Erro ao obter vendedor selecionado: ${e.toString()}');
    }
  }

  @override
  Future<List<Seller>> getSellers() async {
    try {
      final response = await _networkService.get('/users');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Seller.fromJson(json)).toList();
      } else {
        throw AppException(
          'Falha ao carregar vendedores: código ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw AppException('Falha ao carregar vendedores: ${e.message}');
    }
    catch (e) {
      throw AppException('Erro ao carregar vendedores: ${e.toString()}');
    }
  }

  @override
  Future<void> saveSelectedSeller(Seller seller) async {
    try {
      await saveToCache('selectedSeller', seller, (seller) => seller.toJson());
    } catch (e) {
      throw Exception('Erro ao salvar vendedor selecionado: ${e.toString()}');
    }
  }
}
