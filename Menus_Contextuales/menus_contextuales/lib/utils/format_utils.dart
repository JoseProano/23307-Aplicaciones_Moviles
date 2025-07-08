import 'package:intl/intl.dart';

class FormatUtils {
  // Formatear precio
  static String formatPrice(double price) {
    final formatter = NumberFormat.currency(
      locale: 'es_ES',
      symbol: '\$',
      decimalDigits: 2,
    );
    return formatter.format(price);
  }

  // Formatear precio sin símbolo
  static String formatPriceWithoutSymbol(double price) {
    final formatter = NumberFormat('#,##0.00', 'es_ES');
    return formatter.format(price);
  }

  // Formatear fecha
  static String formatDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy', 'es_ES');
    return formatter.format(date);
  }

  // Formatear fecha y hora
  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm', 'es_ES');
    return formatter.format(dateTime);
  }

  // Formatear fecha relativa (hace 2 días, hace 1 hora, etc.)
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return formatDate(date);
    } else if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Hace un momento';
    }
  }

  // Formatear número con separadores de miles
  static String formatNumber(int number) {
    final formatter = NumberFormat('#,##0', 'es_ES');
    return formatter.format(number);
  }

  // Formatear porcentaje
  static String formatPercentage(double percentage) {
    final formatter = NumberFormat.percentPattern('es_ES');
    return formatter.format(percentage / 100);
  }

  // Formatear tamaño de archivo
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    int i = (bytes.toString().length - 1) ~/ 3;
    double size = bytes / (1024 * i);
    return "${size.toStringAsFixed(size >= 100 ? 0 : 1)} ${suffixes[i]}";
  }

  // Capitalizar primera letra
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Capitalizar cada palabra
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ')
        .map((word) => word.isEmpty ? word : capitalize(word))
        .join(' ');
  }

  // Truncar texto
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Remover acentos y caracteres especiales
  static String removeAccents(String text) {
    const withAccents = 'áàäâéèëêíìïîóòöôúùüûñçÁÀÄÂÉÈËÊÍÌÏÎÓÒÖÔÚÙÜÛÑÇ';
    const withoutAccents = 'aaaaeeeeiiiioooouuuuncAAAAEEEEIIIIOOOOUUUUNC';
    
    String result = text;
    for (int i = 0; i < withAccents.length; i++) {
      result = result.replaceAll(withAccents[i], withoutAccents[i]);
    }
    return result;
  }

  // Limpiar texto para búsqueda
  static String cleanTextForSearch(String text) {
    return removeAccents(text.toLowerCase().trim());
  }

  // Validar email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validar teléfono
  static bool isValidPhone(String phone) {
    return RegExp(r'^\+?[\d\s\-\(\)]{8,15}$').hasMatch(phone);
  }

  // Generar ID único simple
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Generar ID con prefijo
  static String generateIdWithPrefix(String prefix) {
    return '${prefix}_${generateId()}';
  }

  // Formatear precio como moneda
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'es_ES',
      symbol: '\$',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }
}

class ValidationUtils {
  // Validar que no esté vacío
  static String? validateRequired(String? value, [String fieldName = 'Campo']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }
    return null;
  }

  // Validar email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email es requerido';
    }
    if (!FormatUtils.isValidEmail(value)) {
      return 'Email no válido';
    }
    return null;
  }

  // Validar contraseña
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Contraseña es requerida';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  // Validar confirmación de contraseña
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Confirmación de contraseña es requerida';
    }
    if (value != password) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  // Validar teléfono
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Opcional
    }
    if (!FormatUtils.isValidPhone(value)) {
      return 'Teléfono no válido';
    }
    return null;
  }

  // Validar número
  static String? validateNumber(String? value, [String fieldName = 'Número']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es requerido';
    }
    if (double.tryParse(value) == null) {
      return '$fieldName debe ser un número válido';
    }
    return null;
  }

  // Validar rango numérico
  static String? validateNumberRange(String? value, double min, double max, [String fieldName = 'Número']) {
    String? numberValidation = validateNumber(value, fieldName);
    if (numberValidation != null) return numberValidation;
    
    double number = double.parse(value!);
    if (number < min || number > max) {
      return '$fieldName debe estar entre $min y $max';
    }
    return null;
  }

  // Validar longitud mínima
  static String? validateMinLength(String? value, int minLength, [String fieldName = 'Campo']) {
    if (value == null || value.length < minLength) {
      return '$fieldName debe tener al menos $minLength caracteres';
    }
    return null;
  }

  // Validar longitud máxima
  static String? validateMaxLength(String? value, int maxLength, [String fieldName = 'Campo']) {
    if (value != null && value.length > maxLength) {
      return '$fieldName no puede tener más de $maxLength caracteres';
    }
    return null;
  }
}
