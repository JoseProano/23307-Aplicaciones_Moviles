import 'package:cloud_firestore/cloud_firestore.dart';

class Nota {
  final String? id;
  final String materia;
  final double calificacion;
  final String descripcion;
  final DateTime fecha;

  Nota({
    this.id,
    required this.materia,
    required this.calificacion,
    required this.descripcion,
    required this.fecha,
  });

  // Convertir de Firestore Document a Nota
  factory Nota.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Nota(
      id: doc.id,
      materia: data['materia'] ?? '',
      calificacion: (data['calificacion'] ?? 0.0).toDouble(),
      descripcion: data['descripcion'] ?? '',
      fecha: (data['fecha'] as Timestamp).toDate(),
    );
  }

  // Convertir de Map a Nota
  factory Nota.fromMap(Map<String, dynamic> map, {String? id}) {
    return Nota(
      id: id,
      materia: map['materia'] ?? '',
      calificacion: (map['calificacion'] ?? 0.0).toDouble(),
      descripcion: map['descripcion'] ?? '',
      fecha: map['fecha'] is Timestamp 
          ? (map['fecha'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Convertir Nota a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'materia': materia,
      'calificacion': calificacion,
      'descripcion': descripcion,
      'fecha': Timestamp.fromDate(fecha),
    };
  }

  // Método copyWith para crear copias con modificaciones
  Nota copyWith({
    String? id,
    String? materia,
    double? calificacion,
    String? descripcion,
    DateTime? fecha,
  }) {
    return Nota(
      id: id ?? this.id,
      materia: materia ?? this.materia,
      calificacion: calificacion ?? this.calificacion,
      descripcion: descripcion ?? this.descripcion,
      fecha: fecha ?? this.fecha,
    );
  }

  @override
  String toString() {
    return 'Nota{id: $id, materia: $materia, calificacion: $calificacion, descripcion: $descripcion}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Nota && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
