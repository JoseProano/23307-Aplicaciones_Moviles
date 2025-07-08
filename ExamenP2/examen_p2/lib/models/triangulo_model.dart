enum TipoTriangulo {
  equilatero,
  isosceles,
  escaleno,
  invalido,
}

class TrianguloModel {
  final double lado1;
  final double lado2;
  final double lado3;
  final TipoTriangulo tipo;

  TrianguloModel({
    required this.lado1,
    required this.lado2,
    required this.lado3,
    required this.tipo,
  });
}
