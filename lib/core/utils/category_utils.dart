import 'package:flutter/material.dart';

class CategoryUtils {
  static const String defaultIconName = 'more_horiz';

  static const Map<String, IconData> categoryIcons = {
    'restaurant': Icons.restaurant,
    'shopping_cart': Icons.shopping_cart,
    'commute': Icons.commute,
    'home': Icons.home,
    'medical_services': Icons.medical_services,
    'school': Icons.school,
    'movie': Icons.movie,
    'payments': Icons.payments,
    'card_giftcard': Icons.card_giftcard,
    'savings': Icons.savings,
    'work': Icons.work,
    'fitness_center': Icons.fitness_center,
    'flight': Icons.flight,
    'local_gas_station': Icons.local_gas_station,
    'checkroom': Icons.checkroom,
    'electrical_services': Icons.electrical_services,
    'water_drop': Icons.water_drop,
    'wifi': Icons.wifi,
    'phone_android': Icons.phone_android,
    'receipt_long': Icons.receipt_long,
    'more_horiz': Icons.more_horiz,
  };

  static const List<Color> categoryColors = [
    Color(0xFFF44336), // Red
    Color(0xFFE91E63), // Pink
    Color(0xFF9C27B0), // Purple
    Color(0xFF673AB7), // Deep Purple
    Color(0xFF3F51B5), // Indigo
    Color(0xFF2196F3), // Blue
    Color(0xFF03A9F4), // Light Blue
    Color(0xFF00BCD4), // Cyan
    Color(0xFF009688), // Teal
    Color(0xFF4CAF50), // Green
    Color(0xFF8BC34A), // Light Green
    Color(0xFFCDDC39), // Lime
    Color(0xFFFFEB3B), // Yellow
    Color(0xFFFFC107), // Amber
    Color(0xFFFF9800), // Orange
    Color(0xFFFF5722), // Deep Orange
    Color(0xFF795548), // Brown
    Color(0xFF9E9E9E), // Grey
    Color(0xFF607D8B), // Blue Grey
    Color(0xFF000000), // Black
  ];

  static String resolveIconName(String storedIcon) {
    if (categoryIcons.containsKey(storedIcon)) {
      return storedIcon;
    }

    final legacyCodePoint = int.tryParse(storedIcon);
    if (legacyCodePoint != null) {
      for (final entry in categoryIcons.entries) {
        if (entry.value.codePoint == legacyCodePoint) {
          return entry.key;
        }
      }
    }

    return defaultIconName;
  }

  static IconData getIcon(String iconName) {
    return categoryIcons[resolveIconName(iconName)] ?? Icons.more_horiz;
  }

  static String getIconName(IconData icon) {
    return categoryIcons.entries
        .firstWhere(
          (entry) => entry.value == icon,
          orElse: () => categoryIcons.entries.last,
        )
        .key;
  }
}
