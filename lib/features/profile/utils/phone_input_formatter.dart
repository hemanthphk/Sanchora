import 'package:flutter/services.dart';

class PhoneInputFormatter extends TextInputFormatter {
  final String Function() getCountry;

  PhoneInputFormatter({required this.getCountry});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (!getCountry().contains('India')) return newValue;

    // Allow clearing the field
    if (newValue.text.isEmpty) return newValue;

    // Clean the strings by removing the visual prefix if it exists
    String cleanNew = newValue.text.replaceFirst(RegExp(r'^\+91\s?'), '');
    
    // Extract raw mobile digits
    String digits = cleanNew.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 10) digits = digits.substring(0, 10);

    // Rebuild the formatted string
    final buffer = StringBuffer();
    if (digits.isNotEmpty || newValue.text.isNotEmpty) {
      buffer.write('+91 ');
      for (int i = 0; i < digits.length; i++) {
        if (i == 5) buffer.write(' ');
        buffer.write(digits[i]);
      }
    }
    final formatted = buffer.toString();

    // Calculate cursor position
    int cursorInCleanNew = newValue.selection.baseOffset - (newValue.text.length - cleanNew.length);
    if (cursorInCleanNew < 0) cursorInCleanNew = 0;
    
    int mobileDigitsBeforeCursor = 0;
    for (int i = 0; i < cursorInCleanNew && i < cleanNew.length; i++) {
      if (RegExp(r'\d').hasMatch(cleanNew[i])) {
        mobileDigitsBeforeCursor++;
      }
    }

    int newOffset = 4; // Length of "+91 "
    int mobileDigitsSeen = 0;
    for (int i = 4; i < formatted.length; i++) {
      if (mobileDigitsSeen == mobileDigitsBeforeCursor) {
        newOffset = i;
        break;
      }
      if (RegExp(r'\d').hasMatch(formatted[i])) {
        mobileDigitsSeen++;
      }
      newOffset = i + 1;
    }

    // Ensure offset is within bounds
    if (newOffset > formatted.length) {
      newOffset = formatted.length;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }
}
