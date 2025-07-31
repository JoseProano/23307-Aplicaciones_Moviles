import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/estudiante.dart';
import '../models/nota.dart';
import '../services/firestore_service.dart';

class EstudianteViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  // Estado de la aplicación
  bool _isLoading = false;
  String? _errorMessage;
  List<Estudiante> _estudiantes = [];
  Estudiante? _estudianteSeleccionado;
  List<Nota> _notasEstudianteSeleccionado = [];

  // Filtros y paginación
  String _filtroNombre = '';
  int? _filtroEdad;
  int _limite = 5;
  bool _tieneMasDatos = true;
  int _paginaActual = 1;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Estudiante> get estudiantes => _estudiantes;
  Estudiante? get estudianteSeleccionado => _estudianteSeleccionado;
  List<Nota> get notasEstudianteSeleccionado => _notasEstudianteSeleccionado;
  String get filtroNombre => _filtroNombre;
  int? get filtroEdad => _filtroEdad;
  bool get tieneMasDatos => _tieneMasDatos;
  int get paginaActual => _paginaActual;

  // Setters para filtros
  void setFiltroNombre(String nombre) {
    _filtroNombre = nombre;
    _reiniciarPaginacion();
    notifyListeners();
  }

  void setFiltroEdad(int? edad) {
    _filtroEdad = edad;
    _reiniciarPaginacion();
    notifyListeners();
  }

  void limpiarFiltros() {
    _filtroNombre = '';
    _filtroEdad = null;
    _reiniciarPaginacion();
    cargarEstudiantes(); // Recargar inmediatamente después de limpiar filtros
  }

  // Métodos privados
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _reiniciarPaginacion() {
    _tieneMasDatos = true;
    _paginaActual = 1;
    _estudiantes.clear();
  }

  void _limpiarDatos() {
    _estudiantes.clear();
  }

  // CRUD Estudiantes

  // Cargar estudiantes con paginación y filtros
  Future<void> cargarEstudiantes({bool esNuevaPagina = false}) async {
    try {
      _setLoading(true);
      _setError(null);

      // Solo reinicializar paginación si NO es nueva página
      if (!esNuevaPagina) {
        _reiniciarPaginacion();
      } else {
        _limpiarDatos(); // Solo limpiar datos, mantener número de página
      }

      print('Cargando estudiantes - Página: $_paginaActual, EsNuevaPagina: $esNuevaPagina');
      print('Filtros - Nombre: "$_filtroNombre", Edad: $_filtroEdad');
      print('Estado de filtros - Nombre vacío: ${_filtroNombre.isEmpty}, Edad nula: ${_filtroEdad == null}');

      // Decidir si usar filtrado local o paginación de Firestore
      bool tienesFiltros = _filtroNombre.trim().isNotEmpty || _filtroEdad != null;
      print('¿Tienes filtros?: $tienesFiltros');
      
      if (tienesFiltros) {
        // Con filtros: usar búsqueda local con paginación manual
        Stream<List<Estudiante>> stream = _firestoreService.obtenerEstudiantes(
          limit: 100, // Obtener más documentos para filtrar localmente
          startAfter: null, // Sin paginación de Firestore para filtros
          filtroNombre: _filtroNombre.isNotEmpty ? _filtroNombre : null,
          filtroEdad: _filtroEdad,
        );

        List<Estudiante> estudiantesFiltrados = await stream.first;
        print('Estudiantes filtrados obtenidos: ${estudiantesFiltrados.length}');
        
        // Aplicar paginación local
        int inicio = (_paginaActual - 1) * _limite;
        int fin = inicio + _limite;
        
        _estudiantes = estudiantesFiltrados.skip(inicio).take(_limite).toList();
        _tieneMasDatos = fin < estudiantesFiltrados.length;
        
        print('Página actual: $_paginaActual, Mostrando: ${_estudiantes.length}, TieneMasDatos: $_tieneMasDatos');
      } else {
        // Sin filtros: usar paginación de Firestore
        print('Usando paginación de Firestore');
        Query query = FirebaseFirestore.instance.collection('estudiantes')
            .orderBy('fechaRegistro', descending: true);

        // Para páginas específicas, necesitamos calcular el offset
        if (_paginaActual > 1) {
          // Obtener documentos hasta la página anterior
          int skip = (_paginaActual - 1) * _limite;
          QuerySnapshot offsetSnapshot = await FirebaseFirestore.instance
              .collection('estudiantes')
              .orderBy('fechaRegistro', descending: true)
              .limit(skip)
              .get();
          
          if (offsetSnapshot.docs.isNotEmpty) {
            query = query.startAfterDocument(offsetSnapshot.docs.last);
          }
        }

        query = query.limit(_limite);
        QuerySnapshot snapshot = await query.get();

        if (snapshot.docs.isNotEmpty) {
          _estudiantes = snapshot.docs
              .map((doc) => Estudiante.fromDocument(doc))
              .toList();

          print('Obtenidos de Firestore: ${_estudiantes.length} estudiantes');

          // Verificar si hay más páginas obteniendo un documento adicional
          QuerySnapshot nextPageCheck = await FirebaseFirestore.instance
              .collection('estudiantes')
              .orderBy('fechaRegistro', descending: true)
              .startAfterDocument(snapshot.docs.last)
              .limit(1)
              .get();
          
          _tieneMasDatos = nextPageCheck.docs.isNotEmpty;
          print('TieneMasDatos: $_tieneMasDatos');
        } else {
          _estudiantes = [];
          _tieneMasDatos = false;
          print('No se obtuvieron documentos');
        }
      }

      print('Estado final - Página: $_paginaActual, Total estudiantes: ${_estudiantes.length}, TieneMasDatos: $_tieneMasDatos');
    } catch (e) {
      print('Error al cargar estudiantes: $e');
      _setError('Error al cargar estudiantes: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Navegación de páginas
  Future<void> irAPaginaSiguiente() async {
    if (_tieneMasDatos && !_isLoading) {
      _paginaActual++;
      print('Navegando a página siguiente: $_paginaActual');
      await cargarEstudiantes(esNuevaPagina: true);
    }
  }

  Future<void> irAPaginaAnterior() async {
    if (_paginaActual > 1 && !_isLoading) {
      _paginaActual--;
      print('Navegando a página anterior: $_paginaActual');
      await cargarEstudiantes(esNuevaPagina: true);
    }
  }

  // Crear estudiante
  Future<bool> crearEstudiante(Estudiante estudiante) async {
    try {
      _setLoading(true);
      _setError(null);

      await _firestoreService.crearEstudiante(estudiante);
      
      // Recargar la lista
      await cargarEstudiantes();
      
      return true;
    } catch (e) {
      _setError('Error al crear estudiante: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Actualizar estudiante
  Future<bool> actualizarEstudiante(String id, Estudiante estudiante) async {
    try {
      _setLoading(true);
      _setError(null);

      await _firestoreService.actualizarEstudiante(id, estudiante);
      
      // Actualizar en la lista local
      int index = _estudiantes.indexWhere((e) => e.id == id);
      if (index != -1) {
        _estudiantes[index] = estudiante.copyWith(id: id);
      }

      // Actualizar estudiante seleccionado si es el mismo
      if (_estudianteSeleccionado?.id == id) {
        _estudianteSeleccionado = estudiante.copyWith(id: id);
      }

      return true;
    } catch (e) {
      _setError('Error al actualizar estudiante: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Eliminar estudiante
  Future<bool> eliminarEstudiante(String id) async {
    try {
      _setLoading(true);
      _setError(null);

      await _firestoreService.eliminarEstudiante(id);
      
      // Eliminar de la lista local
      _estudiantes.removeWhere((e) => e.id == id);
      
      // Limpiar selección si es el mismo estudiante
      if (_estudianteSeleccionado?.id == id) {
        _estudianteSeleccionado = null;
        _notasEstudianteSeleccionado.clear();
      }

      return true;
    } catch (e) {
      _setError('Error al eliminar estudiante: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Seleccionar estudiante y cargar sus notas
  Future<void> seleccionarEstudiante(Estudiante estudiante) async {
    try {
      _estudianteSeleccionado = estudiante;
      _setLoading(true);
      _setError(null);

      // Cargar notas del estudiante
      await cargarNotasEstudiante(estudiante.id!);
    } catch (e) {
      _setError('Error al seleccionar estudiante: $e');
    } finally {
      _setLoading(false);
    }
  }

  // CRUD Notas

  // Cargar notas de un estudiante
  Future<void> cargarNotasEstudiante(String estudianteId) async {
    try {
      _firestoreService.obtenerNotasDeEstudiante(estudianteId).listen(
        (notas) {
          _notasEstudianteSeleccionado = notas;
          notifyListeners();
        },
        onError: (error) {
          _setError('Error al cargar notas: $error');
        },
      );
    } catch (e) {
      _setError('Error al cargar notas: $e');
    }
  }

  // Crear nota
  Future<bool> crearNota(String estudianteId, Nota nota) async {
    try {
      _setLoading(true);
      _setError(null);

      await _firestoreService.crearNota(estudianteId, nota);
      return true;
    } catch (e) {
      _setError('Error al crear nota: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Actualizar nota
  Future<bool> actualizarNota(String estudianteId, String notaId, Nota nota) async {
    try {
      _setLoading(true);
      _setError(null);

      await _firestoreService.actualizarNota(estudianteId, notaId, nota);
      return true;
    } catch (e) {
      _setError('Error al actualizar nota: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Eliminar nota
  Future<bool> eliminarNota(String estudianteId, String notaId) async {
    try {
      _setLoading(true);
      _setError(null);

      await _firestoreService.eliminarNota(estudianteId, notaId);
      return true;
    } catch (e) {
      _setError('Error al eliminar nota: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Obtener promedio de un estudiante
  Future<double> obtenerPromedioEstudiante(String estudianteId) async {
    try {
      return await _firestoreService.obtenerPromedioEstudiante(estudianteId);
    } catch (e) {
      _setError('Error al obtener promedio: $e');
      return 0.0;
    }
  }

  // Buscar estudiantes
  void buscarEstudiantes(String termino) {
    if (termino.isEmpty) {
      limpiarFiltros(); // Ya incluye cargarEstudiantes()
      return;
    }

    // Intentar convertir a número para búsqueda por edad
    int? edad = int.tryParse(termino);
    
    if (edad != null) {
      _filtroEdad = edad;
      _filtroNombre = '';
      _reiniciarPaginacion();
      cargarEstudiantes();
    } else {
      _filtroNombre = termino;
      _filtroEdad = null;
      _reiniciarPaginacion();
      cargarEstudiantes();
    }
  }

  // Limpiar selección
  void limpiarSeleccion() {
    _estudianteSeleccionado = null;
    _notasEstudianteSeleccionado.clear();
    notifyListeners();
  }

  // Refrescar datos
  Future<void> refrescar() async {
    await cargarEstudiantes();
  }
}
