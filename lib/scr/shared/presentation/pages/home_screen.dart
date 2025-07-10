import 'package:flutter/material.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/appointment/presentation/pages/patients_list_screen.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/medical_record/medical_prescription/presentation/pages/patients_list_screen.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/medical_record/medical_prescription/presentation/pages/medical_prescription_screen.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/appointment/presentation/pages/appointment_screen.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/notifications/presentation/pages/notification_screen.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/profile/presentation/pages/doctor_profile_screen.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/profile/presentation/pages/patient_profile_screen.dart';
import 'package:trabajo_moviles_ninjacode/scr/core/utils/usecases/jwt_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? role;
  int? doctorId;

  List<Widget> _widgetOptions = [];

  @override
  void initState() {
    super.initState();
    _loadRoleAndDoctorId();
  }

  Future<void> _loadRoleAndDoctorId() async {
    final storedRole = await JwtStorage.getRole();
    final storedDoctorId = await JwtStorage.getDoctorId();

    setState(() {
      role = storedRole;
      doctorId = storedDoctorId;

      _widgetOptions = [
        HomePatientsScreen(doctorId: doctorId ?? 0),
        PatientsListScreen(doctorId: doctorId ?? 0),
        AppointmentScreen(),
        // NotificationScreen(doctorId: doctorId ?? 0),
        role == 'ROLE_DOCTOR' ? DoctorProfileScreen() : PatientProfileScreen(),
      ];
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.isNotEmpty
          ? _widgetOptions[_selectedIndex]
          : Center(child: CircularProgressIndicator()),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Color(0xFF6D46B8),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          border: Border(
            top: BorderSide(
              color: Colors.white,
              width: 4,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: SizedBox(
            height: 72,
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Color(0xFF6D46B8),
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home, size: 28),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.groups, size: 28),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today, size: 28),
                  label: '',
                ),
                // BottomNavigationBarItem(
                //   icon: Icon(Icons.notifications, size: 28),
                //   label: '',
                // ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person, size: 28),
                  label: '',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white.withOpacity(0.7),
              showSelectedLabels: false,
              showUnselectedLabels: false,
              onTap: _onItemTapped,
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }
}