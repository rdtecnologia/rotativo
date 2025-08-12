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

  // License plate formatter (supports both old Brazilian and Mercosul formats)
  static final plateFormatter = MaskTextInputFormatter(
    mask: 'AAA-####',
    filter: {"A": RegExp(r'[A-Z]'), "#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // Mercosul plate formatter (ABC-1D23) - allowing letter or number in second position of second segment
  static final mercosulPlateFormatter = MaskTextInputFormatter(
    mask: 'AAA-#A##',
    filter: {"A": RegExp(r'[A-Z]'), "#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // Custom Mercosul formatter that allows both letter and number in the second position of second segment
  static final flexibleMercosulPlateFormatter = MaskTextInputFormatter(
    mask: 'AAA-#A##',
    filter: {"A": RegExp(r'[A-Z]'), "#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // Smart plate formatter that detects format automatically
  static final smartPlateFormatter = MaskTextInputFormatter(
    mask: 'AAA-####',
    filter: {"A": RegExp(r'[A-Z]'), "#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // Universal plate formatter that handles both formats
  static final universalPlateFormatter = MaskTextInputFormatter(
    mask: 'AAA-####',
    filter: {"A": RegExp(r'[A-Z]'), "#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // Detect plate format and return appropriate formatter
  static MaskTextInputFormatter getPlateFormatter(String plate) {
    final cleanPlate = plate.replaceAll(RegExp(r'[^A-Z0-9]'), '');
    
    if (cleanPlate.length == 7) {
      // Old Brazilian format: ABC1234
      return MaskTextInputFormatter(
        mask: 'AAA-####',
        filter: {"A": RegExp(r'[A-Z]'), "#": RegExp(r'[0-9]')},
        type: MaskAutoCompletionType.lazy,
      );
    } else if (cleanPlate.length == 8) {
      // Mercosul format: ABC1D23 (allowing letter or number in second position)
      return flexibleMercosulPlateFormatter;
    }
    
    // Default to old format
    return plateFormatter;
  }

  // Validate plate format
  static bool isValidPlateFormat(String plate) {
    final cleanPlate = plate.replaceAll(RegExp(r'[^A-Z0-9]'), '');
    
    if (cleanPlate.length == 7) {
      // Old Brazilian format: ABC1234
      return RegExp(r'^[A-Z]{3}[0-9]{4}$').hasMatch(cleanPlate);
    } else if (cleanPlate.length == 8) {
      // Mercosul format: ABC1D23 (allowing letter or number in second position of second segment)
      return RegExp(r'^[A-Z]{3}[0-9][A-Z0-9][0-9]{2}$').hasMatch(cleanPlate);
    }
    
    return false;
  }

  // Format plate for display
  static String formatPlate(String plate) {
    final cleanPlate = plate.replaceAll(RegExp(r'[^A-Z0-9]'), '').toUpperCase();
    
    if (cleanPlate.length == 7) {
      // Old Brazilian format: ABC-1234
      return '${cleanPlate.substring(0, 3)}-${cleanPlate.substring(3)}';
    } else if (cleanPlate.length == 8) {
      // Mercosul format: ABC-1D23
      return '${cleanPlate.substring(0, 3)}-${cleanPlate.substring(3)}';
    }
    
    return plate;
  }

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