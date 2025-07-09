import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:trabajo_moviles_ninjacode/scr/core/utils/usecases/jwt_storage.dart';

class ProfileService {
  final String baseUrl = 'http://localhost:8080/api/v1';

  Future<Map<String, dynamic>> fetchProfileDetails(int userId) async {
    final token = await JwtStorage.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/profile/profile/userId/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load profile details');
    }
  }

  Future<void> updateProfile(int profileId, Map<String, dynamic> updatedProfile) async {
    final token = await JwtStorage.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/profile/profile/$profileId/full-update'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(updatedProfile),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update profile');
    }
  }

  Future<Map<String, dynamic>> fetchDoctorProfessionalDetails(int profileId) async {
    final token = await JwtStorage.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/doctor/doctor/profile/$profileId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load doctor professional details');
    }
  }

  Future<void> updateDoctorProfile(int doctorId, Map<String, dynamic> updatedDoctorProfile) async {
    final token = await JwtStorage.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/doctor/doctor/$doctorId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(updatedDoctorProfile),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update doctor profile');
    }
  }

  Future<http.StreamedResponse> uploadProfileImage({
    required int profileId,
    required File imageFile,
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/profile/$profileId/image');
    var request = http.MultipartRequest('PUT', url);
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
    return await request.send();
  }
}