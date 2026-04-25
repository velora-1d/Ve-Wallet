import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class NominalInputFormatter extends TextInputFormatter {
  NominalInputFormatter({this.allowZero = true});

  final bool allowZero;
  static final NumberFormat _formatter = NumberFormat.decimalPattern('id_ID');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final normalized = allowZero
        ? digits
        : digits.replaceFirst(RegExp(r'^0+'), '');
    final safeDigits = normalized.isEmpty ? '0' : normalized;
    final formatted = _formatter.format(int.parse(safeDigits));

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  static String formatNumber(num value) {
    return _formatter.format(value);
  }

  static double parseToDouble(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return 0;
    return double.parse(digits);
  }

  static int parseToInt(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return 0;
    return int.parse(digits);
  }
}
