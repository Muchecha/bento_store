import 'package:intl/intl.dart';

class FormatUtils {
  static String formatCurrency(double value) {
    String valueStr = value.toStringAsFixed(2);
    String cleanValue = valueStr.replaceAll(RegExp(r'\D'), '');

    double amount = double.parse(cleanValue) / 100;
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    String formattedValue = formatter.format(amount);
    return formattedValue;
  }

  static String formatCurrencyWithSymbol(double value) {
    return formatCurrency(value);
  }
}
