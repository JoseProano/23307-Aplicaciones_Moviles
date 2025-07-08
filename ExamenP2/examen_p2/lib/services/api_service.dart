import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario_model.dart';

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  static Future<List<Usuario>> getUsuarios() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users'));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Usuario.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar usuarios');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
