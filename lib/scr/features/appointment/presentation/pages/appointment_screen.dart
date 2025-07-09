import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/appointment/data/data_sources/remote/medical_appointment_api.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/appointment/presentation/screens/add_appointment.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/appointment/presentation/screens/appointment_detail.dart';

class AppointmentScreen extends StatefulWidget {
  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final List<Meeting> _meetings = <Meeting>[];
  final MedicalAppointmentApi _appointmentService = MedicalAppointmentApi();
  late MeetingDataSource calendarDataSource;
  CalendarView _calendarView = CalendarView.week;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
    calendarDataSource = MeetingDataSource(_meetings);
  }

  Future<void> _loadAppointments() async {
    try {
      final appointments = await _appointmentService.fetchAllAppointments();
      final List<Meeting> loadedMeetings = appointments.map<Meeting>((appointment) {
        final startTime = DateTime.parse('${appointment['eventDate']}T${appointment['startTime']}:00');
        final endTime = DateTime.parse('${appointment['eventDate']}T${appointment['endTime']}:00');
        final colorValue = appointment['color'] ?? '0xFF039BE5';
        final color = Color(int.parse(colorValue.startsWith('0x') ? colorValue : '0x$colorValue'));

        return Meeting(
          appointment['title'],
          startTime,
          endTime,
          color,
          false,
          appointment['description'],
          appointment['id'].toString(),
        );
      }).toList();

      setState(() {
        calendarDataSource.updateMeetings(loadedMeetings); // Usa el método de actualización
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading appointments: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load appointments: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onCalendarViewChanged(CalendarView newView) {
    if (_calendarView != newView) {
      debugPrint('Changing view from $_calendarView to $newView');
      setState(() {
        _calendarView = newView;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calendar',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF6D46B8),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF6D46B8),
              ),
              child: Text(
                'Calendar Views',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.view_day),
              title: Text('Day'),
              onTap: () {
                _onCalendarViewChanged(CalendarView.day);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.view_week),
              title: Text('Week'),
              onTap: () {
                _onCalendarViewChanged(CalendarView.week);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.view_agenda),
              title: Text('Month Agenda View'),
              onTap: () {
                _onCalendarViewChanged(CalendarView.month);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SfCalendar(
                key: ValueKey(_calendarView), // Clave única para forzar reconstrucción
                view: _calendarView,
                dataSource: calendarDataSource,
                initialDisplayDate: DateTime.now(),
                monthViewSettings: MonthViewSettings(showAgenda: true),
                onTap: _calendarView == CalendarView.month ? null : _calendarTapped,
              ),
            ),
    );
  }

  void _calendarTapped(CalendarTapDetails details) async {
    if (details.targetElement == CalendarElement.calendarCell) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddAppointmentScreen(selectedDate: details.date!),
        ),
      );

      if (result == true) {
        _loadAppointments();
      }
    } else if (details.targetElement == CalendarElement.appointment) {
      final appointment = details.appointments!.first;
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AppointmentDetail(appointmentId: int.parse(appointment.id)),
        ),
      );

      if (result == true) {
        _loadAppointments();
      }
    }
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  void updateMeetings(List<Meeting> newMeetings) {
    // Notifica la eliminación de las citas anteriores
    notifyListeners(CalendarDataSourceAction.remove, appointments!);

    // Actualiza las citas
    appointments!.clear();
    appointments!.addAll(newMeetings);

    // Notifica la adición de las nuevas citas
    notifyListeners(CalendarDataSourceAction.add, appointments!);
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }

  @override
  String getNotes(int index) {
    return appointments![index].description;
  }
}

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay, this.description, this.id);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
  String description;
  String id;
}