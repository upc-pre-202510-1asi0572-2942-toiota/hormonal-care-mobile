import 'package:flutter/material.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/appointment/presentation/screens/add_appointment.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/appointment/presentation/screens/appointment_detail.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/profile/data/data_sources/remote/patient_service.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/profile/data/data_sources/remote/profile_service.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/appointment/data/data_sources/remote/medical_appointment_api.dart';
import 'package:trabajo_moviles_ninjacode/scr/core/utils/usecases/jwt_storage.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';

class HomePatientsScreen extends StatefulWidget {
  final int doctorId;

  HomePatientsScreen({required this.doctorId});

  @override
  _HomePatientsScreenState createState() => _HomePatientsScreenState();
}

class _HomePatientsScreenState extends State<HomePatientsScreen> {
  final MedicalAppointmentApi _appointmentApi = MedicalAppointmentApi();
  final PatientService _patientService = PatientService();
  final ProfileService _profileService = ProfileService();

  List<Map<String, String>> patients = [];
  String errorMessage = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    setState(() {
      isLoading = true;
    });

    try {
      final role = await JwtStorage.getRole();
      if (role != 'ROLE_DOCTOR') {
        throw Exception('Only doctors can view patients');
      }

      // Obtener solo los appointments de hoy
      final appointments = await _appointmentApi.fetchAppointmentsForToday();
      final List<Map<String, String>> fetchedPatients = [];
      for (var appointment in appointments) {
        String imageUrl = '';
        try {
          final patientDetails = await _patientService.fetchPatientDetails(appointment['patientId']);
          imageUrl = patientDetails['image'] ?? '';
        } catch (_) {}
        fetchedPatients.add({
          'name': appointment['title'] ?? 'No name',
          'time': appointment['startTime'] ?? 'No start time',
          'endTime': appointment['endTime'] ?? 'No end time',
          'image': imageUrl,
          'eventDate': appointment['eventDate'] ?? 'No date',
          'patientId': appointment['patientId'].toString(),
          'title': appointment['title'] ?? 'No title',
          'description': appointment['description'] ?? 'No description',
          'color': appointment['color'] ?? '0xFF039BE5',
          'appointmentId': appointment['id'].toString(),
        });
      }

      // Ordenar las citas por hora
      fetchedPatients.sort((a, b) {
        final aTime = a['time'] ?? '';
        final bTime = b['time'] ?? '';
        return aTime.compareTo(bTime);
      });

      setState(() {
        patients = fetchedPatients;
        errorMessage = '';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching patients: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final limaTimeZone = tz.getLocation('America/Lima');
    final now = tz.TZDateTime.now(limaTimeZone);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6A828D),
        title: Text("Today's Patients"),
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchPatients,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : ListView.builder(
                    itemCount: patients.length,
                    itemBuilder: (context, index) {
                      final eventDate = tz.TZDateTime.from(DateTime.parse(patients[index]['eventDate']!), limaTimeZone);
                      final isPast = eventDate.isBefore(now);

                      return Card(
                        color: isPast ? Color(0xFFB0BEC5) : Color(0xFFE0E0E0), // Oscurecer las citas pasadas
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Stack(
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(patients[index]['image']!),
                                backgroundColor: Color(0xFF6A828D),
                              ),
                              title: Text(
                                patients[index]['name']!,
                                style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                              ),
                              trailing: Padding(
                                padding: EdgeInsets.only(right: 16), // Move the container to the left
                                child: GestureDetector(
                                  onTap: () async {
                                    final url = patients[index]['description']!;
                                    if (await canLaunch(url)) {
                                      await launch(url);
                                    } else {
                                      throw 'Could not launch $url';
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4), // Adjusted padding
                                    decoration: BoxDecoration(
                                      color: Color(0xFF40535B),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.videocam, color: Colors.white),
                                        SizedBox(width: 4), // Adjusted spacing
                                        Text(
                                          '${patients[index]['time']} - ${patients[index]['endTime']}',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 8,
                              top: 0,
                              bottom: 0,
                              child: Align(
                                alignment: Alignment.center,
                                child: CircleAvatar(
                                  radius: 12, // Half the size of the original
                                  backgroundColor: Color(0xFF40535B),
                                  child: Center(
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: Icon(Icons.info, color: Colors.white, size: 16),
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AppointmentDetail(
                                              appointmentId: int.parse(patients[index]['appointmentId']!),
                                            ),
                                          ),
                                        );
                                        if (result == true) {
                                          _fetchPatients();
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final now = DateTime.now();
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddAppointmentScreen(
                selectedDate: now,
              ),
            ),
          );

          if (result == true) {
            _fetchPatients(); // Refresca la pantalla si se ha creado una cita
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF6A828D),
      ),
    );
  }
}