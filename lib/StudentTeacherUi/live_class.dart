import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Utils/app_colors.dart';


// Appointment Model
class Appointment {
  final String doctorName;
  final String specialization;
  final String qualification;
  final String description;
  final String status;
  final String appointmentDate;
  final String appointmentTime;
  final String appointmentId;
  final bool isOnline;
  final String imageUrl;

  Appointment({
    required this.doctorName,
    required this.specialization,
    required this.qualification,
    required this.description,
    required this.status,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.appointmentId,
    required this.isOnline,
    required this.imageUrl,
  });
}

// Dummy Data
List<Appointment> appointments = [
  Appointment(
    doctorName: "Dr. Abrina Riser",
    specialization: "Cardiologist Surgeon",
    qualification: "BPT, MS",
    description: "Specialized in Quantum Mechanics & Thermodynamics.",
    status: "Pending",
    appointmentDate: "22 Feb 2024",
    appointmentTime: "09:45 PM",
    appointmentId: "145875AB",
    isOnline: false,
    imageUrl: "https://img.freepik.com/free-photo/portrait-female-teacher-holding-notepad-green_140725-149622.jpg",
  ),
  Appointment(
    doctorName: "Dr. Imran Syaher",
    specialization: "Senior Dentist Surgeon",
    qualification: "MD, MS, MBBS",
    description: "Expert in Algebra & Geometry with 10 years of experience.",
    status: "Cancelled",
    appointmentDate: "22 Feb 2024",
    appointmentTime: "09:45 PM",
    appointmentId: "145875AB",
    isOnline: false,
    imageUrl: "https://www.venkateshwaragroup.in/vgiblog/wp-content/uploads/2022/09/Untitled-design-2-1.jpg",
  ),
  Appointment(
    doctorName: "Dr. Joseph Brostito",
    specialization: "Senior General Surgeon",
    qualification: "MD, MS, MBBS",
    description: "Specialized in Quantum Mechanics & Thermodynamics.",
    status: "Completed",
    appointmentDate: "22 Feb 2024",
    appointmentTime: "08:45 AM",
    appointmentId: "318655E",
    isOnline: true,
    imageUrl: "https://img.freepik.com/free-photo/portrait-female-teacher-holding-notepad-green_140725-149622.jpg",
  ),
  Appointment(
    doctorName: "Dr. Abrina Riser",
    specialization: "Cardiologist Surgeon",
    qualification: "BPT, MS",
    description: "Specialized in Quantum Mechanics & Thermodynamics.",
    status: "Pending",
    appointmentDate: "22 Feb 2024",
    appointmentTime: "09:45 PM",
    appointmentId: "145875AB",
    isOnline: false,
    imageUrl: "https://img.freepik.com/free-photo/portrait-female-teacher-holding-notepad-green_140725-149622.jpg",
  ),
  Appointment(
    doctorName: "Dr. Imran Syaher",
    specialization: "Senior Dentist Surgeon",
    qualification: "MD, MS, MBBS",
    description: "Expert in Algebra & Geometry with 10 years of experience.",
    status: "Cancelled",
    appointmentDate: "22 Feb 2024",
    appointmentTime: "09:45 PM",
    appointmentId: "145875AB",
    isOnline: false,
    imageUrl: "https://www.venkateshwaragroup.in/vgiblog/wp-content/uploads/2022/09/Untitled-design-2-1.jpg",
  ),
  Appointment(
    doctorName: "Dr. Joseph Brostito",
    specialization: "Senior General Surgeon",
    qualification: "MD, MS, MBBS",
    description: "Specialized in Quantum Mechanics & Thermodynamics.",
    status: "Completed",
    appointmentDate: "22 Feb 2024",
    appointmentTime: "08:45 AM",
    appointmentId: "318655E",
    isOnline: true,
    imageUrl: "https://img.freepik.com/free-photo/portrait-female-teacher-holding-notepad-green_140725-149622.jpg",
  ),
];

// Appointment Screen
class LiveClassScreen extends StatelessWidget {
  const LiveClassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,

      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65),
        child: Column(
          children: [
            AppBar(
              elevation: 4,
              centerTitle: true,
              iconTheme: IconThemeData(color: Colors.white),
              title: Text(
                "Live Class",
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              flexibleSpace: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [homepageColor,primaryColor],
                    begin: Alignment.topCenter,  // Horizontal gradient starts from left
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              actions: [

              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
              ),
            ),
            Container(
              height: 0,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, homepageColor],
                ),
              ),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(5.0),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          return AppointmentCard(appointment: appointments[index]);
        },
      ),
    );
  }
}

// Appointment Card Widget
class AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  AppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            appointment.imageUrl,
            width: 100,
            height: 180,
            fit: BoxFit.cover,
          ),
        ),

      ),
    );
  }
}
