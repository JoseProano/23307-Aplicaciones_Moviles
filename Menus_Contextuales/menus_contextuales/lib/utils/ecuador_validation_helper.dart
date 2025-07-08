/// Helper para validaciones específicas de Ecuador
class EcuadorValidationHelper {
  
  /// Valida si una cédula ecuatoriana es válida
  static bool isValidCedula(String cedula) {
    if (cedula.isEmpty) return false;
    
    // Remover espacios y caracteres especiales
    cedula = cedula.replaceAll(RegExp(r'\D'), '');
    
    // Verificar longitud
    if (cedula.length != 10) return false;
    
    // Verificar que todos sean dígitos
    if (!RegExp(r'^\d+$').hasMatch(cedula)) return false;
    
    // Verificar que la provincia sea válida (primeros 2 dígitos)
    int provincia = int.parse(cedula.substring(0, 2));
    if (provincia < 1 || provincia > 24) return false;
    
    // Verificar dígito verificador
    List<int> digitos = cedula.split('').map(int.parse).toList();
    int verificador = digitos[9];
    
    int suma = 0;
    for (int i = 0; i < 9; i++) {
      int digito = digitos[i];
      if (i % 2 == 0) {
        // Posiciones impares (0, 2, 4, 6, 8)
        digito *= 2;
        if (digito > 9) digito -= 9;
      }
      suma += digito;
    }
    
    int digitoCalculado = (suma % 10 == 0) ? 0 : 10 - (suma % 10);
    return digitoCalculado == verificador;
  }
  
  /// Valida si un RUC ecuatoriano es válido
  static bool isValidRUC(String ruc) {
    if (ruc.isEmpty) return false;
    
    // Remover espacios y caracteres especiales
    ruc = ruc.replaceAll(RegExp(r'\D'), '');
    
    // Verificar longitud
    if (ruc.length != 13) return false;
    
    // Verificar que todos sean dígitos
    if (!RegExp(r'^\d+$').hasMatch(ruc)) return false;
    
    // Para RUC, los primeros 10 dígitos deben ser una cédula válida
    String cedula = ruc.substring(0, 10);
    if (!isValidCedula(cedula)) return false;
    
    // Los últimos 3 dígitos deben ser 001
    String sufijo = ruc.substring(10);
    return sufijo == '001';
  }
  
  /// Valida si una cédula o RUC es válido
  static bool isValidCedulaOrRUC(String value) {
    if (value.isEmpty) return false;
    
    // Remover espacios y caracteres especiales
    value = value.replaceAll(RegExp(r'\D'), '');
    
    if (value.length == 10) {
      return isValidCedula(value);
    } else if (value.length == 13) {
      return isValidRUC(value);
    }
    
    return false;
  }
  
  /// Formatea una cédula o RUC para mostrar
  static String formatCedulaOrRUC(String value) {
    if (value.isEmpty) return value;
    
    // Remover espacios y caracteres especiales
    value = value.replaceAll(RegExp(r'\D'), '');
    
    if (value.length == 10) {
      // Formatear cédula: 1234567890
      return value;
    } else if (value.length == 13) {
      // Formatear RUC: 1234567890001
      return value;
    }
    
    return value;
  }
  
  /// Mensaje de ayuda para el usuario
  static String getCedulaRUCHelpText() {
    return 'Ingresa tu cédula (10 dígitos) o RUC (13 dígitos).\n'
           'Ejemplo: 1234567890 o 1234567890001';
  }
}
