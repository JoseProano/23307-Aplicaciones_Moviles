import 'package:cloud_firestore/cloud_firestore.dart';

class Estudiante {
  final String? id;
  final String nombre;
  final int edad;
  final String carrera;
  final String email;
  final DateTime fechaRegistro;

  Estudiante({
    this.id,
    required this.nombre,
    required this.edad,
    required this.carrera,
    required this.email,
    required this.fechaRegistro,
  });

  // Convertir de Firestore Document a Estudiante
  factory Estudiante.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Estudiante(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      edad: data['edad'] ?? 0,
      carrera: data['carrera'] ?? '',
      email: data['email'] ?? '',
      fechaRegistro: (data['fechaRegistro'] as Timestamp).toDate(),
    );
  }

  // Convertir de Map a Estudiante
  factory Estudiante.fromMap(Map<String, dynamic> map, {String? id}) {
    return Estudiante(
      id: id,
      nombre: map['nombre'] ?? '',
      edad: map['edad'] ?? 0,
      carrera: map['carrera'] ?? '',
      email: map['email'] ?? '',
      fechaRegistro: map['fechaRegistro'] is Timestamp 
          ? (map['fechaRegistro'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Convertir Estudiante a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'edad': edad,
      'carrera': carrera,
      'email': email,
      'fechaRegistro': Timestamp.fromDate(fechaRegistro),
    };
  }

  // Método copyWith para crear copias con modificaciones
  Estudiante copyWith({
    String? id,
    String? nombre,
    int? edad,
    String? carrera,
    String? email,
    DateTime? fechaRegistro,
  }) {
    return Estudiante(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      edad: edad ?? this.edad,
      carrera: carrera ?? this.carrera,
      email: email ?? this.email,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }

  @override
  String toString() {
    return 'Estudiante{id: $id, nombre: $nombre, edad: $edad, carrera: $carrera, email: $email}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Estudiante && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
