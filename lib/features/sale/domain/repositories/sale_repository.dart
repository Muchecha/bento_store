import '../../../product/domain/entities/product.dart';
import '../entities/sale.dart';

abstract class SaleRepository {
  Future<Sale> createSale(int userId, List<Product> products);

  Future<void> cancelSale(int saleId);

  Future<List<Sale>> getSales();
}
