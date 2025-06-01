// lib/core/utils/sale_calculator.dart
class SaleCalculator {
  /// Calcula o valor total de uma lista de vendas
  static double calculateListTotalValue(List<dynamic> sales) {
    double total = 0.0;

    try {
      for (var sale in sales) {
        total += calculateSingleSaleValue(sale);
      }
    } catch (e) {
      print('Erro ao calcular valor total da lista: $e');
    }

    return total;
  }

  /// Calcula o valor total de uma única venda
  static double calculateSingleSaleValue(dynamic sale) {
    double total = 0.0;

    try {
      if (sale?.products != null && sale.products is List) {
        for (var product in sale.products) {
          total += calculateProductPrice(product);
        }
      }
    } catch (e) {
      print('Erro ao calcular valor da venda: $e');
    }

    return total;
  }

  static double calculateProductPrice(dynamic product) {
    try {
      if (product?.price != null) {
        var price = product.price;
        if (price is int) {
          return price.toDouble();
        } else if (price is double) {
          return price;
        } else if (price is String) {
          return double.tryParse(price) ?? 0.0;
        }
      }
    } catch (e) {
      print('Erro ao calcular preço do produto: $e');
    }

    return 0.0;
  }
}
