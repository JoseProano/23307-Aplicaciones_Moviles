import '../models/cart_item_model.dart';
import '../models/invoice_model.dart';

class EcuadorInvoiceHelper {
  // IVA Ecuador
  static const double IVA_ECUADOR = 15.0;
  
  // Crear factura ecuatoriana
  static InvoiceModel createEcuadorInvoice({
    required String orderId,
    required String userId,
    required String userEmail,
    required String invoiceNumber,
    required String customerName,
    required String customerPhone,
    required String customerAddress,
    required String customerCity,
    required String cedula,
    String? businessName,
    String? businessAddress,
    required List<CartItemModel> cartItems,
  }) {
    // Convertir items del carrito a items de factura
    List<InvoiceItemModel> invoiceItems = cartItems.map((cartItem) {
      return InvoiceItemModel(
        productId: cartItem.product.id,
        productName: cartItem.product.name,
        quantity: cartItem.quantity,
        unitPrice: cartItem.product.price,
        totalPrice: cartItem.totalPrice,
      );
    }).toList();
    
    // Calcular totales
    double subtotal = invoiceItems.fold(0.0, (sum, item) => sum + item.totalPrice);
    double ivaAmount = subtotal * (IVA_ECUADOR / 100);
    double totalAmount = subtotal + ivaAmount;
    
    return InvoiceModel(
      id: '',
      orderId: orderId,
      userId: userId,
      userEmail: userEmail,
      invoiceNumber: invoiceNumber,
      createdAt: DateTime.now(),
      customerName: customerName,
      customerPhone: customerPhone,
      customerAddress: customerAddress,
      customerCity: customerCity,
      cedula: cedula,
      businessName: businessName,
      businessAddress: businessAddress,
      subtotal: subtotal,
      ivaPercentage: IVA_ECUADOR,
      ivaAmount: ivaAmount,
      totalAmount: totalAmount,
      items: invoiceItems,
      status: InvoiceStatus.pending,
    );
  }
  
  // Validar cédula ecuatoriana (básico)
  static bool isValidCedula(String cedula) {
    // Remover espacios y guiones
    cedula = cedula.replaceAll(RegExp(r'[\s-]'), '');
    
    // Debe tener 10 dígitos para cédula o 13 para RUC
    if (cedula.length != 10 && cedula.length != 13) {
      return false;
    }
    
    // Solo números
    if (!RegExp(r'^\d+$').hasMatch(cedula)) {
      return false;
    }
    
    return true;
  }
  
  // Determinar si es cédula o RUC
  static String getDocumentType(String cedula) {
    cedula = cedula.replaceAll(RegExp(r'[\s-]'), '');
    
    if (cedula.length == 10) {
      return 'Cédula';
    } else if (cedula.length == 13) {
      return 'RUC';
    } else {
      return 'Documento';
    }
  }
  
  // Formatear cédula/RUC para mostrar
  static String formatDocument(String cedula) {
    cedula = cedula.replaceAll(RegExp(r'[\s-]'), '');
    
    if (cedula.length == 10) {
      // Formato cédula: 123456789-0
      return '${cedula.substring(0, 9)}-${cedula.substring(9)}';
    } else if (cedula.length == 13) {
      // Formato RUC: 1234567890001
      return cedula;
    } else {
      return cedula;
    }
  }
  
  // Obtener ciudades principales de Ecuador
  static List<String> getEcuadorCities() {
    return [
      'Quito',
      'Guayaquil',
      'Cuenca',
      'Santo Domingo',
      'Machala',
      'Durán',
      'Manta',
      'Portoviejo',
      'Loja',
      'Ambato',
      'Esmeraldas',
      'Riobamba',
      'Milagro',
      'Ibarra',
      'La Libertad',
      'Babahoyo',
      'Quevedo',
      'Sangolquí',
      'Tulcán',
      'Pasaje',
      'Otra',
    ];
  }
}
