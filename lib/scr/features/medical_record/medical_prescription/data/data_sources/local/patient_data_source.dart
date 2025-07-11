import 'package:trabajo_moviles_ninjacode/scr/features/medical_record/medical_prescription/domain/models/patient_model.dart';
import '../../../domain/models/services/patients_list_service.dart';

class PatientsDataSource {
  final PatientsListService _patientsListService = PatientsListService();

  Future<List<Patient>> getPatients() async {
    try {
      return await _patientsListService.getPatients(1);
    } catch (e) {
      throw Exception('Error fetching patients: $e');
    }
  }
}
