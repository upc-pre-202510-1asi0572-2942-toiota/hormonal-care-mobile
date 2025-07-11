import 'package:flutter/material.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/medical_record/medical_prescription/services/medical_record_service.dart';

class MedicalRecordGlucoseLevels extends StatefulWidget {
  final int patientId;

  const MedicalRecordGlucoseLevels({Key? key, required this.patientId}) : super(key: key);

  @override
  _MedicalRecordGlucoseLevelsState createState() => _MedicalRecordGlucoseLevelsState();
}

class _MedicalRecordGlucoseLevelsState extends State<MedicalRecordGlucoseLevels> {
  final MedicalRecordService _service = MedicalRecordService();
  String emergencyMessage = '';
  List<dynamic> glucoseLevels = [];
  List<Map<String, dynamic>> insulinLevels = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final today = DateTime.now();
      final formattedDate = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      await _service.postGlucoseData(widget.patientId);
      final emergencyMessage = await _service.monitorGlucose(widget.patientId);
      final glucoseLevels = await _service.fetchGlucoseByDate(widget.patientId, formattedDate);
      final insulinLevels = _service.calculateInsulinHistory(glucoseLevels);

      setState(() {
        this.emergencyMessage = emergencyMessage;
        this.glucoseLevels = glucoseLevels;
        this.insulinLevels = insulinLevels;
        this.loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Medical Record')),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Emergency Message: $emergencyMessage', style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Text('Glucose Levels:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...glucoseLevels.map((level) => Text('${level['time']} - ${level['glucoseLevel']} mg/dL')),
            SizedBox(height: 20),
            Text('Insulin History:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...insulinLevels.map((level) => Text('${level['time']} - ${level['insulinUnits']}')),
          ],
        ),
      ),
    );
  }
}