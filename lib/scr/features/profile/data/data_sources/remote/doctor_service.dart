import 'dart:convert';
import 'package:http/http.dart' as http;

class DoctorService {
  final String baseUrl = 'http://localhost:8080/api/v1';

  Future<http.Response> updateDoctor({
    required int doctorId,
    required Map<String, dynamic> data,
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/doctor/$doctorId');
    return await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );
  }
} 