import 'dart:convert';
import 'package:http/http.dart' as http;

class MedicalRecordService {
  final String baseUrl = 'https://hormonalcarebackend-9c81ad662b45.herokuapp.com/api/v1/patient';

  Future<String> monitorGlucose(int patientId) async {
    final url = '$baseUrl/$patientId/monitor-glucose';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Error monitoring glucose: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> fetchGlucoseByDate(int patientId, String date) async {
    final url = '$baseUrl/$patientId/glucose/$date';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error fetching glucose levels: ${response.statusCode}');
    }
  }

  Future<void> postGlucoseData(int patientId) async {
    final url = '$baseUrl/$patientId/fetch-glucose-from-blynk';
    final response = await http.post(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Error posting glucose data: ${response.statusCode}');
    }
  }

  List<Map<String, dynamic>> calculateInsulinHistory(List<dynamic> glucoseLevels) {
    const targetGlucose = 100;
    const ISF = 40;
    final insulinHistory = <Map<String, dynamic>>[];

    for (var level in glucoseLevels) {
      if (level['glucoseLevel'] > 200) {
        final correctiveInsulin = (level['glucoseLevel'] - targetGlucose) / ISF;
        insulinHistory.add({
          'time': level['time'],
          'insulinUnits': '${correctiveInsulin.toStringAsFixed(2)} U',
        });
      }
    }

    return insulinHistory;
  }
}