import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trabajo_moviles_ninjacode/scr/core/utils/usecases/jwt_storage.dart';

class AuthService {
  final String baseUrl = 'http://localhost:8080/api/v1';

  Future<Map<String, dynamic>> signUp(String username, String password, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/authentication/sign-up'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
        'roles': [role]
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Error in registration');
    }
  }

  Future<String?> signIn(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/authentication/sign-in'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final token = responseData['token'];
      final userId = responseData['id'];
      final role = responseData['role'];

      if (token != null && userId != null && role != null) {
        await JwtStorage.saveToken(token);
        await JwtStorage.saveUserId(userId);
        await JwtStorage.saveRole(role);

        if (role == 'ROLE_DOCTOR') {
          final fullName = await fetchAndSaveDoctorFullName(userId, token);
          // Puedes usar fullName como lo necesites
        }

        return token;
      } else {
        throw Exception('Token, User ID, o Role es null');
      }
    } else {
      throw Exception('Error en sign-in');
    }
  }

  Future<String?> fetchAndSaveDoctorFullName(int userId, String token) async {
    final doctorResponse = await http.get(
      Uri.parse('$baseUrl/doctor/by-user/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (doctorResponse.statusCode == 200) {
      final doctorData = json.decode(doctorResponse.body);
      final fullName = doctorData['fullName'];
      if (fullName != null) {
        await JwtStorage.saveDoctorFullName(fullName);
        return fullName;
      } else {
        throw Exception('fullName es null');
      }
    } else {
      throw Exception('Error obteniendo datos del doctor: ${doctorResponse.statusCode}');
    }
  }

  Future<int?> getUserId() async {
    return await JwtStorage.getUserId();
  }

  Future<String?> getRole() async {
    return await JwtStorage.getRole();
  }

  Future<void> logout() async {
    await JwtStorage.clearAll();
  }
}
