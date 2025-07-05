import 'package:flutter/material.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/iam/domain/services/auth_service.dart';
import 'package:trabajo_moviles_ninjacode/scr/core/utils/usecases/jwt_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/profile_picture_widget.dart';
import '../widgets/profile_field_widget.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/iam/presentation/pages/sign_in.dart';

class PatientProfileScreen extends StatefulWidget {
  @override
  _PatientProfileScreenState createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  bool isEditing = false;
  Future<Map<String, dynamic>>? _patientProfileDetails;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadPatientProfileDetails();
  }

  Future<void> _loadPatientProfileDetails() async {
    final userId = await JwtStorage.getUserId();
    final token = await JwtStorage.getToken();
    if (userId != null && token != null) {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/v1/patient/by-user/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final patientData = json.decode(response.body);
        setState(() {
          _patientProfileDetails = Future.value(patientData);
        });
      } else {
        print('Error fetching patient data: \\${response.statusCode}');
      }
    } else {
      print('User ID or token not found');
    }
  }

  void toggleEditMode() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  Future<void> _logout() async {
    await _authService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignIn()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6A828D),
        title: Text('Patient Profile'),
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: const Color.fromARGB(255, 0, 0, 0)),
                  onPressed: toggleEditMode,
                ),
                SizedBox(width: 8.0),
                FutureBuilder<Map<String, dynamic>>(
                  future: _patientProfileDetails,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Icon(Icons.error);
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Icon(Icons.person);
                    } else {
                      final patientProfile = snapshot.data!;
                      final imageUrl = patientProfile['image'] as String?;
                      return ProfilePictureWidget(
                        isEditing: isEditing,
                        toggleEditMode: toggleEditMode,
                        imageUrl: imageUrl,
                      );
                    }
                  },
                ),
                SizedBox(width: 8.0),
                IconButton(
                  icon: Icon(Icons.logout, color: const Color.fromARGB(255, 0, 0, 0)),
                  onPressed: _logout,
                ),
              ],
            ),
            SizedBox(height: 20.0),
            if (!isEditing) ...[
              FutureBuilder<Map<String, dynamic>>(
                future: _patientProfileDetails,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: \\${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No data found'));
                  } else {
                    final patientProfile = snapshot.data!;
                    return Column(
                      children: [
                        ProfileFieldWidget(label: "Fullname", value: patientProfile['fullName'] ?? ''),
                        ProfileFieldWidget(label: "Birthday", value: patientProfile['birthday'] ?? ''),
                        ProfileFieldWidget(label: "Gender", value: patientProfile['gender'] ?? ''),
                        ProfileFieldWidget(label: "Phone Number", value: patientProfile['phoneNumber'] ?? ''),
                        ProfileFieldWidget(label: "Type of Blood", value: patientProfile['typeOfBlood'] ?? ''),
                      ],
                    );
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}