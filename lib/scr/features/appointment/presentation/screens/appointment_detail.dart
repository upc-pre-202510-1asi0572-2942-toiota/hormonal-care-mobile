import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/appointment/data/data_sources/remote/medical_appointment_api.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/appointment/presentation/screens/edit_appointment.dart';
import 'package:url_launcher/url_launcher.dart';

class AppointmentDetail extends StatefulWidget {
  final int appointmentId;

  const AppointmentDetail({Key? key, required this.appointmentId}) : super(key: key);

  @override
  _AppointmentDetailState createState() => _AppointmentDetailState();
}

class _AppointmentDetailState extends State<AppointmentDetail> {
  final MedicalAppointmentApi _appointmentService = MedicalAppointmentApi();
  Map<String, dynamic>? _appointmentDetails;
  Map<String, dynamic>? _patientDetails;

  @override
  void initState() {
    super.initState();
    _loadAppointmentDetails();
  }

  Future<void> _loadAppointmentDetails() async {
    try {
      final appointmentDetails = await _appointmentService.fetchAppointmentDetails(widget.appointmentId);
      final patientDetails = await _appointmentService.fetchPatientDetails(appointmentDetails['patientId']);
      setState(() {
        _appointmentDetails = appointmentDetails;
        _patientDetails = patientDetails;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load appointment details: $e')),
      );
    }
  }

  Future<void> _deleteAppointment() async {
    try {
      final success = await _appointmentService.deleteMedicalAppointment((widget.appointmentId).toString());
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appointment deleted successfully!')),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete appointment')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete appointment: $e')),
      );
    }
  }

  String _formatDate(String date, String startTime, String endTime) {
    final DateTime parsedDate = DateTime.parse(date);
    final DateFormat dateFormatter = DateFormat('EEEE, d \'de\' MMM.', 'es_ES');
    final DateFormat timeFormatter = DateFormat('h:mm a', 'es_ES');
    final DateTime parsedStartTime = DateTime.parse('$date $startTime');
    final DateTime parsedEndTime = DateTime.parse('$date $endTime');
    return '${dateFormatter.format(parsedDate)} ${timeFormatter.format(parsedStartTime)} - ${timeFormatter.format(parsedEndTime)}';
  }

  @override
  Widget build(BuildContext context) {
    if (_appointmentDetails == null || _patientDetails == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF6D46B8),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            'Appointment Detail',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6D46B8),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Appointment Detail',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Color(0xFF6D46B8),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                width: MediaQuery.of(context).size.width * 0.8, // Adjust width to be 80% of screen width
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      backgroundImage: _patientDetails!['image'] != null
                          ? NetworkImage(_patientDetails!['image'])
                          : null,
                      radius: 20,
                      backgroundColor: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      _patientDetails!['fullName'],
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(int.parse(_appointmentDetails!['color'].startsWith('0x') ? _appointmentDetails!['color'] : '0x${_appointmentDetails!['color']}')),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _appointmentDetails!['title'],
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Text(
                _formatDate(_appointmentDetails!['eventDate'], _appointmentDetails!['startTime'], _appointmentDetails!['endTime']),
                style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 8),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _appointmentDetails!['description']));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Meeting link copied to clipboard')),
                        );
                      },
                      icon: Icon(Icons.copy, color: Colors.blue),
                      label: Text(
                        'Copy Link',
                        style: TextStyle(color: Colors.blue),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final url = _appointmentDetails!['description'];
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Could not launch $url')),
                          );
                        }
                      },
                      icon: Icon(Icons.link, color: Colors.blue),
                      label: Text(
                        'Join Meeting',
                        style: TextStyle(color: Colors.blue),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Spacer(), // Pushes the buttons to the bottom
                        Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _deleteAppointment,
                      icon: Icon(Icons.delete, color: Colors.white),
                      label: Text('Delete', style: TextStyle(color: Colors.white, fontSize: 18)), // Aumenta el tamaño del texto
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 16), // Aumenta el padding vertical
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16), // Espacio entre los botones
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditAppointmentScreen(
                              appointmentDetails: _appointmentDetails!,
                              patientDetails: _patientDetails!,
                            ),
                          ),
                        );
            
                        if (result == true) {
                          Navigator.of(context).pop(true); // Return true to indicate success
                        }
                      },
                      icon: Icon(Icons.edit, color: Colors.white),
                      label: Text('Edit', style: TextStyle(color: Colors.white, fontSize: 18)), // Aumenta el tamaño del texto
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6D46B8),
                        padding: EdgeInsets.symmetric(vertical: 16), // Aumenta el padding vertical
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}