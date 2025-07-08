import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Helper para gestionar permisos de administrador
class AdminHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Lista de emails que son administradores por defecto
  static const List<String> _defaultAdminEmails = [
    'admin@tienda-local.com',
  ];
  
  /// Verifica si un usuario es administrador
  static Future<bool> isUserAdmin(String userId) async {
    try {
      // Obtener el documento del usuario
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      
      if (!userDoc.exists) {
        return false;
      }
      
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      
      // Verificar si tiene el campo isAdmin
      if (userData.containsKey('isAdmin')) {
        return userData['isAdmin'] == true;
      }
      
      // Si no tiene el campo, verificar si está en la lista de emails por defecto
      String email = userData['email'] ?? '';
      return _defaultAdminEmails.contains(email);
      
    } catch (e) {
      print('Error verificando si es admin: $e');
      return false;
    }
  }
  
  /// Verifica si un email es administrador por defecto
  static bool isDefaultAdminEmail(String email) {
    return _defaultAdminEmails.contains(email);
  }
  
  /// Marca un usuario como administrador
  static Future<bool> setUserAsAdmin(String userId, bool isAdmin) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'isAdmin': isAdmin});
      
      return true;
    } catch (e) {
      print('Error actualizando permisos de admin: $e');
      return false;
    }
  }
  
  /// Obtiene todos los usuarios administradores
  static Future<List<UserModel>> getAllAdmins() async {
    try {
      // Obtener usuarios con isAdmin = true
      QuerySnapshot adminQuery = await _firestore
          .collection('users')
          .where('isAdmin', isEqualTo: true)
          .get();
      
      List<UserModel> admins = [];
      
      for (QueryDocumentSnapshot doc in adminQuery.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        admins.add(UserModel.fromJson(data));
      }
      
      // También obtener usuarios con emails por defecto que no tengan el campo isAdmin
      for (String email in _defaultAdminEmails) {
        QuerySnapshot defaultAdminQuery = await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .get();
        
        for (QueryDocumentSnapshot doc in defaultAdminQuery.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          
          // Solo agregar si no tiene el campo isAdmin o si es false
          if (!data.containsKey('isAdmin') || data['isAdmin'] != true) {
            // Actualizar el documento para marcar como admin
            await _firestore
                .collection('users')
                .doc(doc.id)
                .update({'isAdmin': true});
            
            admins.add(UserModel.fromJson(data));
          }
        }
      }
      
      return admins;
    } catch (e) {
      print('Error obteniendo administradores: $e');
      return [];
    }
  }
  
  /// Migra usuarios existentes para agregar el campo isAdmin
  static Future<void> migrateExistingAdmins() async {
    try {
      for (String email in _defaultAdminEmails) {
        QuerySnapshot query = await _firestore
            .collection('users')
            .where('email', isEqualTo: email)
            .get();
        
        for (QueryDocumentSnapshot doc in query.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          
          // Solo actualizar si no tiene el campo isAdmin
          if (!data.containsKey('isAdmin')) {
            await _firestore
                .collection('users')
                .doc(doc.id)
                .update({'isAdmin': true});
            
            print('Usuario $email marcado como administrador');
          }
        }
      }
    } catch (e) {
      print('Error migrando administradores: $e');
    }
  }
}
