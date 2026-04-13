import 'package:intl/intl.dart';

/// Currency formatter for Polish format
class CurrencyFormatter {
  /// Format price from WooCommerce (raw string) to Polish format
  /// WooCommerce returns prices as integers (e.g., "9900" for 99.00)
  static String format(String? price, {String currencySymbol = 'zł'}) {
    if (price == null || price.isEmpty) return '-';

    try {
      // WooCommerce Store API returns prices as integers (minor units)
      // e.g., "9900" = 99.00 PLN
      final intValue = int.tryParse(price) ?? 0;
      final decimalValue = intValue / 100;

      final formatter = NumberFormat.currency(
        locale: 'pl_PL',
        symbol: currencySymbol,
        decimalDigits: 2,
      );

      return formatter.format(decimalValue);
    } catch (e) {
      return price;
    }
  }

  /// Format price from double to Polish format
  static String formatDouble(double? price, {String currencySymbol = 'zł'}) {
    if (price == null) return '-';

    try {
      final formatter = NumberFormat.currency(
        locale: 'pl_PL',
        symbol: currencySymbol,
        decimalDigits: 2,
      );

      return formatter.format(price);
    } catch (e) {
      return price.toString();
    }
  }

  /// Parse WooCommerce price string to double
  /// WooCommerce returns prices as integers (e.g., "9900" for 99.00)
  static double? parseWooCommercePrice(String? price) {
    if (price == null || price.isEmpty) return null;

    try {
      final intValue = int.tryParse(price) ?? 0;
      return intValue / 100;
    } catch (e) {
      return double.tryParse(price);
    }
  }

  /// Format price with custom separators
  static String formatWithSeparators(
    String? price, {
    String decimalSeparator = ',',
    String thousandSeparator = ' ',
    String currencySymbol = 'zł',
    bool symbolAfter = true,
  }) {
    if (price == null || price.isEmpty) return '-';

    try {
      final intValue = int.tryParse(price) ?? 0;
      final decimalValue = intValue / 100;

      // Format with Polish locale
      final formatter = NumberFormat.currency(
        locale: 'pl_PL',
        symbol: symbolAfter ? currencySymbol : '',
        decimalDigits: 2,
      );

      String formatted = formatter.format(decimalValue);

      // Ensure comma as decimal separator (Polish format)
      if (decimalSeparator != '.') {
        formatted = formatted.replaceAll('.', decimalSeparator);
      }

      return formatted;
    } catch (e) {
      return price;
    }
  }
}