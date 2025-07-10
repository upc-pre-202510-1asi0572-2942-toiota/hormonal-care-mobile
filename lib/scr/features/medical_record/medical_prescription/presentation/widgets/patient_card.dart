import 'package:flutter/material.dart';
import '../../domain/models/patient_model.dart';
import '../../../diagnosis/presentation/pages/medicalrecord_screen.dart'; // Importa la pantalla de historial médico

class PatientCard extends StatelessWidget {
  final Patient patient;

  const PatientCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFAEBBC3), // Fondo de cada tarjeta de paciente
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calcular el tamaño del CircleAvatar como un porcentaje del ancho del contenedor
            double avatarRadius = constraints.maxWidth * 0.4; // 20% del ancho del contenedor

            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: avatarRadius,
                    backgroundImage: NetworkImage(_getImageUrl(patient.image)),
                    backgroundColor: Color(0xFF40535B),
                    child: patient.image == null || patient.image!.isEmpty
                        ? Icon(Icons.person, size: avatarRadius, color: Colors.white)
                        : null,
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    patient.fullName ?? 'Unknown', // Mostrar el nombre completo del paciente
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color.fromARGB(255, 0, 0, 0),
                      fontSize: avatarRadius / 4,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.0), // Botón de historial médico
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MedicalRecordScreen(patientId: patient.id?.toString() ?? ''),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF40535B), // Color gris oscuro del botón
                      foregroundColor: Colors.white, // Texto del botón en blanco
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(avatarRadius / 8),
                      ),
                      fixedSize: Size(avatarRadius * 2.4, avatarRadius / 2), // Tamaño fijo del botón (ancho, alto)
                      textStyle: TextStyle(
                        fontSize: avatarRadius / 5, // Tamaño del texto del botón
                      ),
                    ),
                    child: Text('Medical record'),
                  ),
                  SizedBox(height: 5.0),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

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