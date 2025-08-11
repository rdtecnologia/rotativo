import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:intl/intl.dart';

class AppFormatters {
  // CPF formatter
  static final cpfFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // Phone formatter
  static final phoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // License plate formatter (ABC-1234)
  static final plateFormatter = MaskTextInputFormatter(
    mask: 'AAA-####',
    filter: {"A": RegExp(r'[A-Z]'), "#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // Remove all non-numeric characters
  static String removeNonNumeric(String text) {
    return text.replaceAll(RegExp(r'[^\d]'), '');
  }

  // Format CPF
  static String formatCPF(String cpf) {
    final clean = removeNonNumeric(cpf);
    if (clean.length == 11) {
      return '${clean.substring(0, 3)}.${clean.substring(3, 6)}.${clean.substring(6, 9)}-${clean.substring(9)}';
    }
    return cpf;
  }

  // Format phone
  static String formatPhone(String phone) {
    final clean = removeNonNumeric(phone);
    if (clean.length == 11) {
      return '(${clean.substring(0, 2)}) ${clean.substring(2, 7)}-${clean.substring(7)}';
    } else if (clean.length == 10) {
      return '(${clean.substring(0, 2)}) ${clean.substring(2, 6)}-${clean.substring(6)}';
    }
    return phone;
  }

  // Format currency (Brazilian Real)
  static String formatCurrency(double value) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: '',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }

  // Format date and time
  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(dateTime);
  }

  // Format date only
  static String formatDate(DateTime dateTime) {
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(dateTime);
  }

  // Format time only
  static String formatTime(DateTime dateTime) {
    final formatter = DateFormat('HH:mm');
    return formatter.format(dateTime);
  }
}