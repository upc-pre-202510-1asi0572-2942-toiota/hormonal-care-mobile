import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/appointment/data/data_sources/remote/medical_appointment_api.dart';
import 'dart:math';

class JitsiMeetingLinkGenerator {
  static const String _baseUrl = 'https://meet.jit.si/';

  static String generateMeetingLink({String? roomPrefix}) {
    final String randomString = _generateRandomString(10);
    final String roomName = roomPrefix != null ? '$roomPrefix-$randomString' : randomString;
    return '$_baseUrl$roomName';
  }

  static String _generateRandomString(int length) {
    const String chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final Random random = Random();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }
}

class AddAppointmentScreen extends StatefulWidget {
  final DateTime selectedDate;

  const AddAppointmentScreen({Key? key, required this.selectedDate}) : super(key: key);

  @override
  _AddAppointmentScreenState createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  final MedicalAppointmentApi _appointmentService = MedicalAppointmentApi();
  List<Map<String, dynamic>> _patients = [];
  int? _selectedPatientId;
  Color _selectedColor = Color(0xFF039BE5); // Default color

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  final List<Map<String, dynamic>> _colors = [
    {'name': 'Rojo Tomate', 'color': Color(0xFFD50000)},
    {'name': 'Rosa Chicle', 'color': Color(0xFFE67C73)},
    {'name': 'Mandarina', 'color': Color(0xFFF4511E)},
    {'name': 'Amarillo Huevo', 'color': Color(0xFFF6BF26)},
    {'name': 'Verde Esmeralda', 'color': Color(0xFF33B679)},
    {'name': 'Verde Musgo', 'color': Color(0xFF0B8043)},
    {'name': 'Azul Turquesa', 'color': Color(0xFF039BE5)},
    {'name': 'Azul Arándano', 'color': Color(0xFF3F51B5)},
    {'name': 'Lavanda', 'color': Color(0xFF7986CB)},
    {'name': 'Morado Intenso', 'color': Color(0xFF8E24AA)},
    {'name': 'Grafito', 'color': Color(0xFF616161)},
  ];

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _dateController.text = '${widget.selectedDate.year}-${widget.selectedDate.month.toString().padLeft(2, '0')}-${widget.selectedDate.day.toString().padLeft(2, '0')}';
    _startTimeController.text = '${widget.selectedDate.hour.toString().padLeft(2, '0')}:${widget.selectedDate.minute.toString().padLeft(2, '0')}';
    _endTimeController.text = '${widget.selectedDate.add(Duration(hours: 1)).hour.toString().padLeft(2, '0')}:${widget.selectedDate.add(Duration(minutes: 0)).minute.toString().padLeft(2, '0')}';
  }

  Future<void> _loadPatients() async {
    try {
      final patients = await _appointmentService.fetchPatients();
      setState(() {
        _patients = patients;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load patients: $e')),
      );
    }
  }

  Future<void> _createAppointment(Map<String, dynamic> appointmentData) async {
    try {
      final success = await _appointmentService.createMedicalAppointment(appointmentData);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appointment created successfully!')),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create appointment')),
        );
      }
    } catch (e) {
      print('Error creating appointment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create appointment: $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != widget.selectedDate) {
      setState(() {
        _dateController.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Appointment',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF6D46B8),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(
                controller: _titleController,
                labelText: 'Title',
                icon: Icons.title,
              ),
              SizedBox(height: 16),
              _buildDateField(
                controller: _dateController,
                labelText: 'Date',
                icon: Icons.calendar_today,
                onTap: () => _selectDate(context),
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _startTimeController,
                labelText: 'Start Time (HH:MM)',
                icon: Icons.access_time,
                keyboardType: TextInputType.number,
                inputFormatters: [TimeTextInputFormatter()],
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _endTimeController,
                labelText: 'End Time (HH:MM)',
                icon: Icons.access_time,
                keyboardType: TextInputType.number,
                inputFormatters: [TimeTextInputFormatter()],
              ),
              SizedBox(height: 16),
              // Lista de pacientes con foto y nombre
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Select Patient', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    ..._patients.map((patient) => ListTile(
                          leading: patient['image'] != null && patient['image'].toString().isNotEmpty
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(patient['image']),
                                )
                              : CircleAvatar(child: Icon(Icons.person)),
                          title: Text(patient['fullName'] ?? ''),
                          selected: _selectedPatientId == patient['id'],
                          onTap: () {
                            setState(() {
                              _selectedPatientId = patient['id'];
                            });
                          },
                          trailing: _selectedPatientId == patient['id']
                              ? Icon(Icons.check, color: Colors.green)
                              : null,
                        )),
                  ],
                ),
              ),
              SizedBox(height: 16),
              _buildDropdown<Color>(
                value: _selectedColor,
                items: _colors.map((color) {
                  return DropdownMenuItem<Color>(
                    value: color['color'],
                    child: Row(
                      children: [
                        CircleAvatar(backgroundColor: color['color'], radius: 10),
                        SizedBox(width: 10),
                        Text(color['name']),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedColor = value!;
                  });
                },
                labelText: 'Choose a Color',
                icon: Icons.color_lens,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final String title = _titleController.text;
                  final DateTime selectedDate = DateTime.parse(_dateController.text);
                  final DateTime startTime = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    int.parse(_startTimeController.text.split(':')[0]),
                    int.parse(_startTimeController.text.split(':')[1]),
                  );
                  final DateTime endTime = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    int.parse(_endTimeController.text.split(':')[0]),
                    int.parse(_endTimeController.text.split(':')[1]),
                  );

                  if (_selectedPatientId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please choose a patient')),
                    );
                    return;
                  }

                  final String meetingLink = JitsiMeetingLinkGenerator.generateMeetingLink(roomPrefix: title);

                  final appointmentData = {
                    'eventDate': selectedDate.toIso8601String().split('T')[0],
                    'startTime': _startTimeController.text, // Formato HH:MM
                    'endTime': _endTimeController.text, // Formato HH:MM
                    'title': title,
                    'description': meetingLink, // Save generated meeting link
                    'doctorId': await _appointmentService.getDoctorId(),
                    'patientId': _selectedPatientId,
                    'color': _selectedColor.value.toRadixString(16), // Save color as hex string
                  };

                  await _createAppointment(appointmentData);
                },
                child: Text(
                  'Add Appointment',
                  style: TextStyle(color: Colors.white, fontSize: 18), // Aumenta el tamaño del texto
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6D46B8), // Color de fondo
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16), // Aumenta el padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // Bordes redondeados
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: labelText,
                border: InputBorder.none,
              ),
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: labelText,
                border: InputBorder.none,
              ),
              readOnly: true,
              onTap: onTap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required String labelText,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          SizedBox(width: 10),
          Expanded(
            child: DropdownButtonFormField<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              decoration: InputDecoration(
                labelText: labelText,
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TimeTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text.length == 4 && !text.contains(':')) {
      final formattedText = '${text.substring(0, 2)}:${text.substring(2)}';
      return newValue.copyWith(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    }
    return newValue;
  }
}