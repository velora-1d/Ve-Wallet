import 'package:flutter/material.dart';

class WalletIconUtils {
  static const String defaultIconKey = 'account_balance_wallet';

  static const Map<String, IconData> walletIcons = {
    'account_balance_wallet': Icons.account_balance_wallet,
    'account_balance': Icons.account_balance,
    'money': Icons.money,
    'credit_card': Icons.credit_card,
    'savings': Icons.savings,
    'payments': Icons.payments,
    'trending_up': Icons.trending_up,
    'wallet': Icons.wallet,
  };

  static String resolveIconKey(String storedIcon) {
    if (walletIcons.containsKey(storedIcon)) {
      return storedIcon;
    }

    final legacyCodePoint = int.tryParse(storedIcon);
    if (legacyCodePoint != null) {
      for (final entry in walletIcons.entries) {
        if (entry.value.codePoint == legacyCodePoint) {
          return entry.key;
        }
      }
    }

    return defaultIconKey;
  }

  static IconData getIcon(String storedIcon) {
    return walletIcons[resolveIconKey(storedIcon)] ??
        walletIcons[defaultIconKey]!;
  }

  static String getIconKey(IconData icon) {
    return walletIcons.entries
        .firstWhere(
          (entry) => entry.value == icon,
          orElse: () =>
              const MapEntry(defaultIconKey, Icons.account_balance_wallet),
        )
        .key;
  }
}
