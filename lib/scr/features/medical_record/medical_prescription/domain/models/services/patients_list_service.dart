import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trabajo_moviles_ninjacode/scr/core/utils/usecases/jwt_storage.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/iam/domain/services/auth_service.dart';
import '../patient_model.dart';

class PatientsListService {
  final String baseUrl = 'http://localhost:8080/api/v1/medical-record/patient';
  final String profileBaseUrl = 'http://localhost:8080/api/v1/profile/profile';
  final String doctorBaseUrl = 'http://localhost:8080/api/v1/doctor/doctor';

  Future<List<Patient>> getPatients(int doctorId) async {
    final token = await JwtStorage.getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final response = await http.get(
      Uri.parse('http://localhost:8080/api/v1/patient/doctor/$doctorId'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Error fetching patients for doctor id $doctorId');
    }
    final List<dynamic> patientsData = json.decode(response.body);
    return patientsData.map((json) => Patient.fromJson(json)).toList();
  }
}