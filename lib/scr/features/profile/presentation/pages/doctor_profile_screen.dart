import 'package:flutter/material.dart';
import 'package:trabajo_moviles_ninjacode/scr/core/utils/usecases/jwt_storage.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/iam/domain/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/profile_picture_widget.dart';
import '../widgets/profile_field_widget.dart';
import '../widgets/logout_button_widget.dart';
import '../widgets/edit_mode_doctor_widget.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/profile/data/data_sources/remote/doctor_service.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/profile/data/data_sources/remote/profile_service.dart';
import 'dart:io';
import 'package:trabajo_moviles_ninjacode/scr/features/iam/presentation/pages/sign_in.dart';

class DoctorProfileScreen extends StatefulWidget {
  @override
  _DoctorProfileScreenState createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  bool isEditing = false;
  Future<Map<String, dynamic>>? _doctorProfileDetails;
  final AuthService _authService = AuthService();
  int? _doctorId;

  @override
  void initState() {
    super.initState();
    _loadDoctorProfileDetails();
  }

  Future<void> _loadDoctorProfileDetails() async {
    final userId = await JwtStorage.getUserId();
    final token = await JwtStorage.getToken();
    if (userId != null && token != null) {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/v1/doctor/by-user/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final doctorData = json.decode(response.body);
        setState(() {
          _doctorProfileDetails = Future.value(doctorData);
          _doctorId = doctorData['id'];
        });
      } else {
        print('Error fetching doctor data: \\${response.statusCode}');
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6D46B8),
        title: Text('Profile'),
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
                  icon: Icon(Icons.edit, color: Colors.black),
                  onPressed: toggleEditMode,
                ),
                SizedBox(width: 8.0),
                FutureBuilder<Map<String, dynamic>>(
                  future: _doctorProfileDetails,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Icon(Icons.error);
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Icon(Icons.person);
                    } else {
                      final doctorProfile = snapshot.data!;
                      final imageUrl = doctorProfile['image'] as String?;
                      return ProfilePictureWidget(
                        isEditing: isEditing,
                        toggleEditMode: toggleEditMode,
                        imageUrl: imageUrl,
                        borderColor: Color(0xFF6D46B8),
                        onImageSelected: (File imageFile) async {
                          final token = await JwtStorage.getToken();
                          final profileId = await JwtStorage.getProfileId();
                          if (token != null && profileId != null) {
                            final response = await ProfileService().uploadProfileImage(
                              profileId: profileId,
                              imageFile: imageFile,
                              token: token,
                            );
                            if (response.statusCode == 200) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Imagen actualizada correctamente')),
                              );
                              _loadDoctorProfileDetails();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error al actualizar imagen: \\${response.statusCode}')),
                              );
                            }
                          }
                        },
                      );
                    }
                  },
                ),
                SizedBox(width: 8.0),
                IconButton(
                  icon: Icon(Icons.logout, color: Colors.black),
                  onPressed: _showLogoutDialog,
                ),
              ],
            ),
            SizedBox(height: 20.0),
            if (!isEditing) ...[
              FutureBuilder<Map<String, dynamic>>(
                future: _doctorProfileDetails,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: \\${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No data found'));
                  } else {
                    final doctorProfile = snapshot.data!;
                    return Column(
                      children: [
                        ProfileFieldWidget(label: "Name", value: doctorProfile['fullName'] ?? ''),
                        ProfileFieldWidget(label: "Gender", value: doctorProfile['gender'] ?? ''),
                        ProfileFieldWidget(label: "Phone", value: doctorProfile['phoneNumber'] ?? ''),
                        ProfileFieldWidget(label: "Birthday", value: doctorProfile['birthday'] ?? ''),
                        ProfileFieldWidget(label: "Medical License Number", value: doctorProfile['professionalIdentificationNumber']?.toString() ?? ''),
                        ProfileFieldWidget(label: "Subspecialty", value: doctorProfile['subSpecialty'] ?? ''),
                      ],
                    );
                  }
                },
              ),
            ],
            if (isEditing) ...[
              FutureBuilder<Map<String, dynamic>>(
                future: _doctorProfileDetails,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: \\${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No data found'));
                  } else {
                    final doctorProfile = snapshot.data!;
                    return EditModeDoctorWidget(
                      doctorProfile: doctorProfile,
                      onCancel: toggleEditMode,
                      onSave: (updatedProfile) async {
                        final userId = await JwtStorage.getUserId();
                        final token = await JwtStorage.getToken();
                        print('DEBUG TOKEN: ' + (token ?? 'NULL'));
                        print('DEBUG updatedProfile: ' + json.encode(updatedProfile));
                        if (userId != null && token != null && _doctorId != null) {
                          if (updatedProfile['birthday'] != null && updatedProfile['birthday'].toString().length >= 10) {
                            updatedProfile['birthday'] = updatedProfile['birthday'].toString().substring(0, 10);
                          }
                          final response = await DoctorService().updateDoctor(
                            doctorId: _doctorId!,
                            data: updatedProfile,
                            token: token,
                          );
                          print('DEBUG PUT status: ' + response.statusCode.toString());
                          print('DEBUG PUT body: ' + response.body);
                          if (response.statusCode == 200) {
                            toggleEditMode();
                            _loadDoctorProfileDetails();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error updating profile: \\${response.statusCode}')),
                            );
                          }
                        }
                      },
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