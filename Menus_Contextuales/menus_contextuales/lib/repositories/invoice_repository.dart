import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/invoice_model.dart';

class InvoiceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Crear una nueva factura
  Future<String?> createInvoice(InvoiceModel invoice) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('invoices')
          .add(invoice.toMap());
      return docRef.id;
    } catch (e) {
      print('Error creating invoice: $e');
      return null;
    }
  }

  // Obtener facturas del usuario
  Future<List<InvoiceModel>> getUserInvoices(String userId) async {
    try {
      // Método alternativo sin orderBy para evitar problemas de índice
      QuerySnapshot querySnapshot = await _firestore
          .collection('invoices')
          .where('userId', isEqualTo: userId)
          .get();

      List<InvoiceModel> invoices = querySnapshot.docs
          .map((doc) => InvoiceModel.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      
      // Ordenar en memoria después de obtener los datos
      invoices.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return invoices;
    } catch (e) {
      print('Error getting user invoices: $e');
      return [];
    }
  }

  // Obtener una factura por ID
  Future<InvoiceModel?> getInvoiceById(String invoiceId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('invoices')
          .doc(invoiceId)
          .get();

      if (doc.exists) {
        return InvoiceModel.fromMap(
            doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting invoice by id: $e');
      return null;
    }
  }

  // Obtener factura por orden ID
  Future<InvoiceModel?> getInvoiceByOrderId(String orderId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('invoices')
          .where('orderId', isEqualTo: orderId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return InvoiceModel.fromMap(
            querySnapshot.docs.first.data() as Map<String, dynamic>,
            querySnapshot.docs.first.id);
      }
      return null;
    } catch (e) {
      print('Error getting invoice by order id: $e');
      return null;
    }
  }

  // Actualizar estado de factura
  Future<bool> updateInvoiceStatus(String invoiceId, InvoiceStatus status, {DateTime? paidAt}) async {
    try {
      Map<String, dynamic> updates = {
        'status': status.toString().split('.').last,
      };
      
      if (status == InvoiceStatus.paid && paidAt != null) {
        updates['paidAt'] = paidAt.toIso8601String();
      }

      await _firestore
          .collection('invoices')
          .doc(invoiceId)
          .update(updates);
      return true;
    } catch (e) {
      print('Error updating invoice status: $e');
      return false;
    }
  }

  // Obtener todas las facturas (para administradores)
  Future<List<InvoiceModel>> getAllInvoices() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('invoices')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => InvoiceModel.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error getting all invoices: $e');
      return [];
    }
  }

  // Obtener facturas por estado
  Future<List<InvoiceModel>> getInvoicesByStatus(InvoiceStatus status) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('invoices')
          .where('status', isEqualTo: status.toString().split('.').last)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => InvoiceModel.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error getting invoices by status: $e');
      return [];
    }
  }

  // Generar número de factura único
  Future<String> generateInvoiceNumber() async {
    try {
      // Obtener el año actual
      final year = DateTime.now().year;
      
      // Buscar la última factura del año
      QuerySnapshot querySnapshot = await _firestore
          .collection('invoices')
          .where('invoiceNumber', isGreaterThanOrEqualTo: '$year-')
          .where('invoiceNumber', isLessThan: '${year + 1}-')
          .orderBy('invoiceNumber', descending: true)
          .limit(1)
          .get();

      int nextNumber = 1;
      if (querySnapshot.docs.isNotEmpty) {
        String lastInvoiceNumber = querySnapshot.docs.first.get('invoiceNumber');
        String numberPart = lastInvoiceNumber.split('-').last;
        nextNumber = int.parse(numberPart) + 1;
      }

      return '$year-${nextNumber.toString().padLeft(4, '0')}';
    } catch (e) {
      print('Error generating invoice number: $e');
      // Fallback: usar timestamp
      return '${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  // Eliminar factura (solo para administradores)
  Future<bool> deleteInvoice(String invoiceId) async {
    try {
      await _firestore.collection('invoices').doc(invoiceId).delete();
      return true;
    } catch (e) {
      print('Error deleting invoice: $e');
      return false;
    }
  }
}
