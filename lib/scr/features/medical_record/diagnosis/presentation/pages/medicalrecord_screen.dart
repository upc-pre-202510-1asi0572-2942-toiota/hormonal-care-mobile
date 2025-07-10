import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importa la librería intl para formatear fechas
import 'package:flutter_spinbox/flutter_spinbox.dart'; // Importa la librería flutter_spinbox para usar SpinBox
import 'package:flutter/services.dart'; // Importa la librería services para usar FilteringTextInputFormatter
import '../../../medical_prescription/domain/models/patient_model.dart';
import '../../domain/models/medication_model.dart';
import '../../domain/models/prescription_model.dart';
import '../../domain/models/treatment_model.dart';
import '../../domain/services/medicalrecord_service.dart';
import '../../domain/models/medicationpost_model.dart';
import '../../domain/models/prescriptionpost_model.dart';
import '../../domain/models/medicaltype_model.dart';

class MedicalRecordScreen extends StatefulWidget {
  final String patientId;

  const MedicalRecordScreen({required this.patientId});

  @override
  _MedicalRecordScreenState createState() => _MedicalRecordScreenState();
}

class _MedicalRecordScreenState extends State<MedicalRecordScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  late Future<Patient> _patientFuture;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this); // 5 pestañas en el TabBar
    _tabController.addListener(_handleTabSelection); // Añadimos un listener para manejar el cambio de pestañas
    _patientFuture = MedicalRecordService().getPatientById(widget.patientId);
    }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection); // Eliminamos el listener cuando ya no se necesite
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Función para manejar el desplazamiento del TabBar cuando se cambia de pestaña
  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      double tabPosition = _tabController.index.toDouble();
      _scrollController.animateTo(
        tabPosition * 120,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Función para mostrar el menú flotante
  void _showPatientInfo(Patient patient) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(_getImageUrl(patient.image)),
                    backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                    child: patient.image == null || patient.image!.isEmpty
                        ? Icon(Icons.person, size: 50, color: Colors.white)
                        : null,
                  ),
                  SizedBox(height: 15),
                  _buildInfoField('Full name', patient.fullName ?? 'Unknown'),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: _buildInfoField('Gender', patient.gender ?? 'Unknown')),
                      SizedBox(width: 10),
                      Expanded(child: _buildInfoField('Birthday', _formatDate(patient.birthday))),
                    ],
                  ),
                  SizedBox(height: 10),
                  _buildInfoField('Phone number', patient.phoneNumber ?? 'Unknown'),
                  SizedBox(height: 10),
                  _buildInfoField('Type of blood', patient.typeOfBlood ?? ''),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Close'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Función para construir los campos de información
  Widget _buildInfoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // Función para formatear la fecha
  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return 'Unknown';
    final parsedDate = DateTime.parse(date);
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(parsedDate);
  }

  int calculateAge(String? birthday) {
    if (birthday == null) return 0;
    final birthDate = DateTime.parse(birthday);
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Widget _buildPatientHeader(Patient patient) {
    return GestureDetector(
      onTap: () => _showPatientInfo(patient),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF4B5A62),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(_getImageUrl(patient.image)),
                  backgroundColor: Colors.blueGrey[200],
                  child: patient.image == null || patient.image!.isEmpty
                      ? Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.fullName ?? 'Unknown',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Text(
              'Age: ${calculateAge(patient.birthday)}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: Colors.black,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        labelStyle: TextStyle(fontWeight: FontWeight.bold),
        tabs: [
          Tab(text: 'Patient History'),
          Tab(text: 'Diagnosis & Treatments'),
          Tab(text: 'Medical Tests'),
          Tab(text: 'External Reports'),
          Tab(text: 'Consultation History'),
        ],
      ),
    );
  }

  Widget _buildTabBarView(Patient patient) {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildPatientHistoryTab(patient),
          _buildDiagnosisAndTreatmentsTab(patient.id ?? 0), // Usar el medicalRecordId
          _buildMedicalTestsTab(),
          _buildExternalReportsTab(),
          Center(child: Text('Consultation History content')),
        ],
      ),
    );
  }

  Widget _buildPatientHistoryTab(Patient patient) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Text(
          'Personal history:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Text(
          patient.personalHistory ?? '',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 20),
        Text(
          'Family history:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Text(
          patient.familyHistory ?? '',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }


Widget _buildDiagnosisAndTreatmentsTab(int medicalRecordId) {
  print('medicalrecordid: $medicalRecordId');
  return FutureBuilder<List<Medication>>(
    future: MedicalRecordService().getMedicationsByRecordId(medicalRecordId),
    builder: (context, medicationSnapshot) {
      if (medicationSnapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      } else if (medicationSnapshot.hasError) {
        return Center(child: Text('Error: ${medicationSnapshot.error}'));
      } else {
        final medications = medicationSnapshot.data ?? [];

        return FutureBuilder<List<Prescription>>(
          future: MedicalRecordService().getPrescriptionsByRecordId(medicalRecordId),
            builder: (context, prescriptionSnapshot) {
              if (prescriptionSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (prescriptionSnapshot.hasError) {
                return Center(child: Text('Error: ${prescriptionSnapshot.error}'));
              } else {
                final prescriptions = prescriptionSnapshot.data ?? [];

              return FutureBuilder<List<Treatment>>(
                future: MedicalRecordService().getTreatmentsByRecordId(medicalRecordId),
                builder: (context, treatmentSnapshot) {
                  if (treatmentSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    final treatments = treatmentSnapshot.data ?? [];

                    return ListView(
                      padding: EdgeInsets.all(16),
                      children: [
                        // Diagnosis Section
                        Container(
                          padding: EdgeInsets.all(16),
                          margin: EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Diagnosis',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              if (prescriptions.isEmpty)
                                Center(child: Text('No prescriptions found')),
                              ...prescriptions.map((prescription) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        _formatDate(prescription.prescriptionDate),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      prescription.notes,
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    SizedBox(height: 20),
                                  ],
                                );
                              }).toList(),
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => _AddPrescriptionDialog(medicalRecordId),
                                    );
                                  },
                                  child: Text('Add Diagnosis'),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Medication Section
                        Container(
                          padding: EdgeInsets.all(16),
                          margin: EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Medication',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Medication',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Concentration',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Unit',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Frequency',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              if (medications.isEmpty)
                                Center(child: Text('No medications found')),
                              ...medications.map((medication) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        medication.drugName,
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        medication.quantity,
                                        style: TextStyle(fontSize: 14),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        medication.concentration,
                                        style: TextStyle(fontSize: 14),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        medication.frequency,
                                        style: TextStyle(fontSize: 14),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                              SizedBox(height: 20),
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => _AddMedicationDialog(medicalRecordId),
                                    );
                                  },
                                  child: Text('Add Medication'),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Treatment Section
                        Container(
                          padding: EdgeInsets.all(16),
                          margin: EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Treatment',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              if (treatments.isEmpty && !treatmentSnapshot.hasError)
                                Center(child: Text('No treatments found')),
                              ...treatments.map((treatment) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      treatment.description,
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    SizedBox(height: 10),
                                  ],
                                );
                              }).toList(),
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => _AddTreatmentDialog(medicalRecordId),
                                    );
                                  },
                                  child: Text('Add Treatment'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                },
              );
            }
          },
        );
      }
    },
  );
}

  Widget _AddMedicationDialog(int medicalRecordId) {
    final _formKey = GlobalKey<FormState>();
    final _medicationPost = MedicationPost(
      medicalRecordId: medicalRecordId,
      medicalTypeId: 0,
      prescriptionId: 0,
      name: '',
      amount: 0,
      unitQ: '',
      value: 0,
      unit: '',
      timesPerDay: 0,
      timePeriod: '',
    );
    Future<List<MedicalType>> _medicalTypesFuture() async {
      return await MedicalRecordService().fetchMedicalTypes();
    }

    Future<List<Prescription>> _fetchPrescriptions() async {
      return await MedicalRecordService().getPrescriptionsByRecordId(medicalRecordId);
    }
  

    
    return AlertDialog(
  title: Text('Add Diagnosis'),
  content: Form(
    key: _formKey,
    child: SingleChildScrollView(
      child: Column(
        children: [
          FutureBuilder<List<MedicalType>>(
  future: _medicalTypesFuture(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    } else if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    } else {
      final medicalTypes = snapshot.data ?? [];
      return DropdownButtonFormField<int>(
        decoration: InputDecoration(
          labelText: 'Medical Type',
          border: OutlineInputBorder(),
        ),
        items: medicalTypes.asMap().entries.map((entry) {
          int index = entry.key;
          MedicalType type = entry.value;
          return DropdownMenuItem<int>(
            value: index + 1, // Sumar 1 al índice
            child: Text(type.typeName),
          );
        }).toList(),
        onChanged: (value) {
          _medicationPost.medicalTypeId = value!;
        },
      );
    }
  },
),
          SizedBox(height: 10),
          FutureBuilder<List<Prescription>>(
            future: _fetchPrescriptions(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final prescriptions = snapshot.data ?? [];
                return Container(
                  width: double.infinity,
                  child: DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: 'Prescription',
                      border: OutlineInputBorder(),
                    ),
                    isExpanded: true, // Usar el ancho completo
                    items: prescriptions.map((prescription) {
                      final formattedDate = DateFormat('yyyy-MM-dd').format(
                        DateTime.parse(prescription.prescriptionDate),
                      );
                      return DropdownMenuItem<int>(
                        value: prescription.id,
                        child: Row(
                          children: [
                            // Usar Flexible para el texto de las notas y limitar su overflow
                            Flexible(
                              child: Text(
                                prescription.notes,
                                overflow: TextOverflow.ellipsis, // Recorta si es muy largo
                                softWrap: false,
                              ),
                            ),
                            SizedBox(width: 8), // Separación entre texto y fecha
                            // Mostrar fecha completa sin overflow
                            Text(
                              formattedDate,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      _medicationPost.prescriptionId = value!;
                    },
                  ),
                );
              }
            },
          ),
          SizedBox(height: 10),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
            onSaved: (value) => _medicationPost.name = value!,
          ),
          SizedBox(height: 10),
          SpinBox(
            min: 0,
            value: 0,
            decoration: InputDecoration(
              labelText: 'Amount',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => _medicationPost.amount = value.toInt(),
          ),
          SizedBox(height: 10),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Unit Quantity',
              border: OutlineInputBorder(),
            ),
            onSaved: (value) => _medicationPost.unitQ = value!,
          ),
          SizedBox(height: 10),
          SpinBox(
            min: 0,
            value: 0,
            decoration: InputDecoration(
              labelText: 'Value',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => _medicationPost.value = value.toInt(),
          ),
          SizedBox(height: 10),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Unit',
              border: OutlineInputBorder(),
            ),
            onSaved: (value) => _medicationPost.unit = value!,
          ),
          SizedBox(height: 10),
          SpinBox(
            min: 0,
            value: 0,
            decoration: InputDecoration(
              labelText: 'Times Per Day',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => _medicationPost.timesPerDay = value.toInt(),
          ),
          SizedBox(height: 10),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Time Period',
              border: OutlineInputBorder(),
            ),
            onSaved: (value) => _medicationPost.timePeriod = value!,
          ),
        ],
      ),
    ),
  ),
  actions: [
    TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: Text('Cancel'),
    ),
    ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();
          try {
            final response = await MedicalRecordService().addMedication(_medicationPost);
            if (response.statusCode == 200 || response.statusCode == 201) {
              Navigator.of(context).pop();
              setState(() {}); // Recargar la sección de medicamentos
            } else {
              throw Exception('Error posting medication');
            }
          } catch (e) {
            print(e);
          }
        }
      },
      child: Text('Submit'),
    ),
  ],
);

  }



    Widget _AddPrescriptionDialog(int medicalRecordId) {
    final _formKey = GlobalKey<FormState>();
    final _prescriptionPost = PrescriptionPost(
      medicalRecordId: medicalRecordId,
      prescriptionDate: '',
      notes: '',
    );

    TextEditingController _dateController = TextEditingController();

    Future<void> _submitPrescriptionForm() async {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        try {
          final response = await MedicalRecordService().addPrescription(_prescriptionPost);
          print('Response status: ${response.statusCode}');
          if (response.statusCode == 200 || response.statusCode == 201) {
            Navigator.of(context).pop();
            setState(() {}); // Recargar la sección de prescripciones
          } else {
            print('Error posting prescription: ${response.body}');
            throw Exception('Error posting prescription');
          }
        } catch (e) {
          print(e);
        }
      }
    }

    Future<void> _selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (picked != null) {
        setState(() {
          _prescriptionPost.prescriptionDate = DateFormat('yyyy-MM-dd').format(picked);
          _dateController.text = _prescriptionPost.prescriptionDate;
        });
      }
    }

    return AlertDialog(
      title: Text('Add Prescription'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: 'Prescription Date',
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (value) => _prescriptionPost.prescriptionDate = value!,
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _prescriptionPost.notes = value!,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitPrescriptionForm,
          child: Text('Submit'),
        ),
      ],
    );
  }

Widget _AddTreatmentDialog(int medicalRecordId) {
  final _formKey = GlobalKey<FormState>();
  final _treatment = Treatment(
    description: '',
    medicalRecordId: medicalRecordId,
  );

  Future<void> _submitTreatmentForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        final response = await MedicalRecordService().addTreatment(_treatment);
        print('Response status: ${response.statusCode}');
        if (response.statusCode == 200 || response.statusCode == 201) {
          Navigator.of(context).pop();
          setState(() {}); // Recargar la sección de tratamientos
        } else {
          print('Error posting treatment: ${response.body}');
          throw Exception('Error posting treatment');
        }
      } catch (e) {
        print(e);
      }
    }
  }

  return AlertDialog(
    title: Text('Add Treatment'),
    content: Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              onSaved: (value) => _treatment.description = value!,
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text('Cancel'),
      ),
      ElevatedButton(
        onPressed: _submitTreatmentForm,
        child: Text('Submit'),
      ),
    ],
  );
}









  Widget _buildMedicalTestsTab() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildTestItem('Fasting Glucose Test', '18/04/24'),
        _buildTestItem('OGTT', '18/04/24'),
        _buildTestItem('ACTH test', '18/04/24'),
      ],
    );
  }

  Widget _buildTestItem(String testName, String date) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            testName,
            style: TextStyle(fontSize: 16),
          ),
          Row(
            children: [
              Text(
                date,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(width: 10),
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(Icons.download, size: 24, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExternalReportsTab() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildReportItem('18/04/24'),
        _buildReportItem('18/04/24'),
        _buildReportItem('22/04/24'),
        _buildReportItem('18/04/24'),
      ],
    );
  }

  Widget _buildReportItem(String date) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            date,
            style: TextStyle(fontSize: 16),
          ),
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(Icons.download, size: 24, color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6A828D),
        title: Text('Medical record'),
      ),
      body: FutureBuilder<Patient>(
        future: _patientFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data found'));
          } else {
            final patient = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPatientHeader(patient),
                  SizedBox(height: 20),
                  _buildTabBar(),
                  SizedBox(height: 20),
                  _buildTabBarView(patient),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  // Función para obtener la URL de la imagen
  String _getImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return '';
    }
    if (!imageUrl.startsWith('http')) {
      return 'https://$imageUrl';
    }
    return imageUrl;
  }
}