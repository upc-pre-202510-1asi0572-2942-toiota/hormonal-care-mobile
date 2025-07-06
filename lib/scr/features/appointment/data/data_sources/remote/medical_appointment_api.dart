import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trabajo_moviles_ninjacode/scr/core/utils/usecases/jwt_storage.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class MedicalAppointmentApi {
  static const String _baseUrl = 'http://localhost:8080/api/v1';

  MedicalAppointmentApi() {
    tz.initializeTimeZones();
  }

  Future<String?> _getToken() async {
    return await JwtStorage.getToken();
  }

  Future<int?> _getUserId() async {
    return await JwtStorage.getUserId();
  }

  Future<Map<String, dynamic>?> fetchProfileDetails(int profileId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/profile/profile/$profileId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Invalid or expired token');
    } else {
      throw Exception('Failed to load profile details');
    }
  }

  Future<int?> getProfileIdByPatientId(int patientId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/medical-record/patient/$patientId/profile-id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return int.parse(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Invalid or expired token');
    } else {
      throw Exception('Failed to load profile ID');
    }
  }

  Future<int> _getDoctorId() async {
    final token = await _getToken();
    final userId = await _getUserId();
    if (userId == null) {
      throw Exception('User ID not found');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/doctor/by-user/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['id'];
    } else {
      throw Exception('Failed to load doctor ID');
    }
  }

  Future<int> getDoctorId() async {
    return await _getDoctorId();
  }

  Future<List<Map<String, dynamic>>> fetchAppointmentsForToday() async {
    final doctorId = await _getDoctorId();
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/medicalAppointment/medicalAppointments/doctor/$doctorId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<Map<String, dynamic>> appointments = List<Map<String, dynamic>>.from(json.decode(response.body));
      final limaTimeZone = tz.getLocation('America/Lima');
      final today = tz.TZDateTime.now(limaTimeZone);
      final todayAppointments = appointments.where((appointment) {
        final eventDate = tz.TZDateTime.from(DateTime.parse(appointment['eventDate']), limaTimeZone);
        return eventDate.year == today.year && eventDate.month == today.month && eventDate.day == today.day;
      }).toList();
      return todayAppointments;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Invalid or expired token');
    } else {
      throw Exception('Failed to load appointments');
    }
  }

   Future<List<Map<String, dynamic>>> fetchAppointmentsForTodayPatientListScreen(int doctorId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/medicalAppointment/medicalAppointments/doctor/1'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<Map<String, dynamic>> appointments = List<Map<String, dynamic>>.from(json.decode(response.body));
      final limaTimeZone = tz.getLocation('America/Lima');
      final today = tz.TZDateTime.now(limaTimeZone);
      final todayAppointments = appointments.where((appointment) {
        final eventDate = tz.TZDateTime.from(DateTime.parse(appointment['eventDate']), limaTimeZone);
        return eventDate.year == today.year && eventDate.month == today.month && eventDate.day == today.day;
      }).toList();
      return todayAppointments;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Invalid or expired token');
    } else {
      throw Exception('Failed to load appointments');
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllAppointments() async {
    final token = await _getToken();
    final doctorId = await _getDoctorId();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/medicalAppointment/medicalAppointments/doctor/$doctorId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Invalid or expired token');
    } else {
      throw Exception('Failed to load appointments');
    }
  }

  Future<List<Map<String, dynamic>>> fetchPatients() async {
    final token = await _getToken();
    final doctorId = await _getDoctorId();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/patient/doctor/$doctorId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Invalid or expired token');
    } else {
      throw Exception('Failed to load patients');
    }
  }

  Future<bool> createMedicalAppointment(Map<String, dynamic> appointmentData) async {
    final token = await _getToken();
    final doctorId = await _getDoctorId();
    if (token == null) {
      throw Exception('Token not found');
    }

    // doctorId debe estar en el body
    appointmentData['doctorId'] = doctorId;

    final response = await http.post(
      Uri.parse('$_baseUrl/medicalAppointment'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(appointmentData),
    );

    if (response.statusCode == 201) {
      return true;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Invalid or expired token');
    } else {
      throw Exception('Failed to create appointment');
    }
  }
  Future<List<Map<String, dynamic>>> fetchAppointmentsForPatient(int patientId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/medicalAppointment/medicalAppointments/patient/$patientId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Invalid or expired token');
    } else {
      throw Exception('Failed to load patient appointments');
    }
  }

  Future<bool> updateMedicalAppointment(
    String medicalAppointmentId,
    String eventDate,
    String startTime,
    String endTime,
    String title,
    String description,
    int doctorId,
    int patientId,
    String color, // Añadir el color aquí
  ) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final String url = '$_baseUrl/medicalAppointment/$medicalAppointmentId';

    // Obtener los datos existentes de la cita médica
    final existingAppointmentResponse = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (existingAppointmentResponse.statusCode != 200) {
      throw Exception('Failed to fetch existing appointment data');
    }

    final existingAppointmentData = jsonDecode(existingAppointmentResponse.body);

    // Construir el cuerpo de la solicitud PUT con los datos proporcionados y los datos existentes
    final updatedAppointmentData = {
      'eventDate': eventDate,
      'startTime': startTime,
      'endTime': endTime,
      'title': title,
      'description': description,
      'doctorId': existingAppointmentData['doctorId'],
      'patientId': patientId,
      'color': color, // Añadir el color aquí
    };

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updatedAppointmentData),
    );

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Invalid or expired token');
    } else {
      throw Exception('Failed to update appointment');
    }
  }

  Future<bool> deleteMedicalAppointment(String medicalAppointmentId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.delete(
      Uri.parse('$_baseUrl/medicalAppointment/$medicalAppointmentId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 204) {
      return true;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Invalid or expired token');
    } else {
      throw Exception('Failed to delete appointment');
    }
  }

  Future<Map<String, dynamic>> fetchAppointmentDetails(int appointmentId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/medicalAppointment/$appointmentId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load appointment details');
    }
  }

    Future<Map<String, dynamic>> fetchPatientDetails(int patientId) async {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Token not found');
      }
      final response = await http.get(
        Uri.parse('$_baseUrl/patient/$patientId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Invalid or expired token');
      } else {
        throw Exception('Failed to load patient details');
      }
    }
}