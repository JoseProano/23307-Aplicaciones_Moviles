import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/estudiante.dart';
import '../models/nota.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _estudiantesCollection = 'estudiantes';

  // CRUD para Estudiantes

  // Crear estudiante
  Future<String> crearEstudiante(Estudiante estudiante) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_estudiantesCollection)
          .add(estudiante.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear estudiante: $e');
    }
  }

  // Obtener estudiantes con paginación y filtros
  Stream<List<Estudiante>> obtenerEstudiantes({
    int limit = 5,
    DocumentSnapshot? startAfter,
    String? filtroNombre,
    int? filtroEdad,
  }) {
    Query query = _firestore.collection(_estudiantesCollection);

    // Para búsquedas con filtros, obtenemos más datos y filtramos en el cliente
    // para hacer búsquedas insensibles a mayúsculas y parciales
    if (filtroNombre != null && filtroNombre.isNotEmpty || filtroEdad != null) {
      // Obtenemos más documentos para poder filtrar localmente
      query = query.orderBy('fechaRegistro', descending: true).limit(50);
      
      return query.snapshots().map((snapshot) {
        List<Estudiante> estudiantes = snapshot.docs
            .map((doc) => Estudiante.fromDocument(doc))
            .toList();

        // Filtrar localmente
        if (filtroNombre != null && filtroNombre.isNotEmpty) {
          estudiantes = estudiantes.where((estudiante) =>
              estudiante.nombre.toLowerCase().contains(filtroNombre.toLowerCase())
          ).toList();
        }

        if (filtroEdad != null) {
          estudiantes = estudiantes.where((estudiante) =>
              estudiante.edad == filtroEdad
          ).toList();
        }

        // Aplicar paginación local (simplificada)
        return estudiantes.take(limit).toList();
      });
    } else {
      // Sin filtros, usar paginación de Firestore
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      
      query = query.orderBy('fechaRegistro', descending: true).limit(limit);

      return query.snapshots().map((snapshot) =>
          snapshot.docs.map((doc) => Estudiante.fromDocument(doc)).toList());
    }
  }

  // Obtener un estudiante por ID
  Future<Estudiante?> obtenerEstudiantePorId(String id) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_estudiantesCollection)
          .doc(id)
          .get();
      
      if (doc.exists) {
        return Estudiante.fromDocument(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener estudiante: $e');
    }
  }

  // Actualizar estudiante
  Future<void> actualizarEstudiante(String id, Estudiante estudiante) async {
    try {
      await _firestore
          .collection(_estudiantesCollection)
          .doc(id)
          .update(estudiante.toMap());
    } catch (e) {
      throw Exception('Error al actualizar estudiante: $e');
    }
  }

  // Eliminar estudiante
  Future<void> eliminarEstudiante(String id) async {
    try {
      // Eliminar todas las notas del estudiante primero
      await eliminarTodasLasNotasDeEstudiante(id);
      
      // Luego eliminar el estudiante
      await _firestore
          .collection(_estudiantesCollection)
          .doc(id)
          .delete();
    } catch (e) {
      throw Exception('Error al eliminar estudiante: $e');
    }
  }

  // Buscar estudiantes por nombre
  Stream<List<Estudiante>> buscarEstudiantesPorNombre(String nombre) {
    return _firestore
        .collection(_estudiantesCollection)
        .where('nombre', isGreaterThanOrEqualTo: nombre)
        .where('nombre', isLessThan: nombre + '\uf8ff')
        .orderBy('nombre')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Estudiante.fromDocument(doc)).toList());
  }

  // Buscar estudiantes por edad
  Stream<List<Estudiante>> buscarEstudiantesPorEdad(int edad) {
    return _firestore
        .collection(_estudiantesCollection)
        .where('edad', isEqualTo: edad)
        .orderBy('fechaRegistro', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Estudiante.fromDocument(doc)).toList());
  }

  // Obtener total de estudiantes (para paginación)
  Future<int> obtenerTotalEstudiantes() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_estudiantesCollection)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Error al obtener total de estudiantes: $e');
    }
  }

  // CRUD para Notas (Subcolección)

  // Crear nota para un estudiante
  Future<String> crearNota(String estudianteId, Nota nota) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_estudiantesCollection)
          .doc(estudianteId)
          .collection('notas')
          .add(nota.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear nota: $e');
    }
  }

  // Obtener notas de un estudiante
  Stream<List<Nota>> obtenerNotasDeEstudiante(String estudianteId) {
    return _firestore
        .collection(_estudiantesCollection)
        .doc(estudianteId)
        .collection('notas')
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Nota.fromDocument(doc)).toList());
  }

  // Actualizar nota
  Future<void> actualizarNota(String estudianteId, String notaId, Nota nota) async {
    try {
      await _firestore
          .collection(_estudiantesCollection)
          .doc(estudianteId)
          .collection('notas')
          .doc(notaId)
          .update(nota.toMap());
    } catch (e) {
      throw Exception('Error al actualizar nota: $e');
    }
  }

  // Eliminar nota
  Future<void> eliminarNota(String estudianteId, String notaId) async {
    try {
      await _firestore
          .collection(_estudiantesCollection)
          .doc(estudianteId)
          .collection('notas')
          .doc(notaId)
          .delete();
    } catch (e) {
      throw Exception('Error al eliminar nota: $e');
    }
  }

  // Eliminar todas las notas de un estudiante
  Future<void> eliminarTodasLasNotasDeEstudiante(String estudianteId) async {
    try {
      QuerySnapshot notasSnapshot = await _firestore
          .collection(_estudiantesCollection)
          .doc(estudianteId)
          .collection('notas')
          .get();

      WriteBatch batch = _firestore.batch();
      for (DocumentSnapshot doc in notasSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Error al eliminar todas las notas: $e');
    }
  }

  // Obtener promedio de calificaciones de un estudiante
  Future<double> obtenerPromedioEstudiante(String estudianteId) async {
    try {
      QuerySnapshot notasSnapshot = await _firestore
          .collection(_estudiantesCollection)
          .doc(estudianteId)
          .collection('notas')
          .get();

      if (notasSnapshot.docs.isEmpty) {
        return 0.0;
      }

      double suma = 0.0;
      for (DocumentSnapshot doc in notasSnapshot.docs) {
        Nota nota = Nota.fromDocument(doc);
        suma += nota.calificacion;
      }

      return suma / notasSnapshot.docs.length;
    } catch (e) {
      throw Exception('Error al calcular promedio: $e');
    }
  }
}
