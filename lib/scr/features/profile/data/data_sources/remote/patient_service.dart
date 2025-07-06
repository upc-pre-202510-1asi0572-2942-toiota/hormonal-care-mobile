import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trabajo_moviles_ninjacode/scr/core/utils/usecases/jwt_storage.dart';

class PatientService {
  final String baseUrl = 'http://localhost:8080/api/v1/patient';

  Future<Map<String, dynamic>> fetchPatientDetails(int patientId) async {
    final token = await JwtStorage.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/$patientId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load patient details');
    }
  }

  static PatientService fromJson(Map<String, dynamic> json) {
    return PatientService();
  }
}