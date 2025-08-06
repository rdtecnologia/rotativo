import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

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
}