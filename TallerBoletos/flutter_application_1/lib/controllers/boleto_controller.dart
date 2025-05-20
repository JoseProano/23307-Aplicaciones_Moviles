/// Controlador para la validación de boletos de concierto.
class BoletoController {
  /// Valida si un boleto cumple con las reglas establecidas.
  ///
  /// - [numero]: Número del boleto a validar.
  /// - Retorna `true` si el boleto es válido, de lo contrario `false`.
  bool validarBoleto(int numero) {
    // Convertir el número a una cadena para extraer los dígitos
    String numeroStr = numero.toString();

    // Verificar que el boleto tenga exactamente 5 dígitos
    if (numeroStr.length != 5) {
      return false;
    }

    // Extraer los dígitos individuales
    int primerDigito = int.parse(numeroStr[0]);
    int segundoDigito = int.parse(numeroStr[1]);
    int penultimoDigito = int.parse(numeroStr[3]);
    int ultimoDigito = int.parse(numeroStr[4]);

    // Verificar que los dos últimos dígitos sean divisibles por el primer dígito
    int ultimosDosDigitos = penultimoDigito * 10 + ultimoDigito;
    if (primerDigito == 0 || ultimosDosDigitos % primerDigito != 0) {
      return false;
    }

    // Verificar que el duplo de los dos primeros dígitos sea menor que el cuadrado de los dos últimos dígitos
    int primerosDosDigitos = primerDigito * 10 + segundoDigito;
    if ((2 * primerosDosDigitos) >= (ultimosDosDigitos * ultimosDosDigitos)) {
      return false;
    }

    // Si pasa todas las validaciones, el boleto es válido
    return true;
  }
}