import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:secure_content/secure_content.dart';
import '../../Utils/app_colors.dart';
import '../live_class.dart';
import '../my_appointment.dart';
import '../student_teacher_list.dart';

class OnlineDashBoard extends StatefulWidget {


  const OnlineDashBoard(
      {super.key,
      });

  @override
  State<OnlineDashBoard> createState() => _YearpageState();
}

class _YearpageState extends State<OnlineDashBoard> {
  int _selectedIndex = 0;

  String combination ='';
  List<dynamic> banner = [];


  TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black);

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  void initState() {
    super.initState();
  }

  _getPage(int page) {
    switch (page) {
      case 0:
        return TeacherListScreen(

        );
      case 1:
        return LiveClassScreen(


        );
      case 2:
        return HistoryAppointmentScreen(

        );
      default:
        return Container();
    }
  }



  @override
  Widget build(BuildContext context) {
    return  SecureWidget(
      isSecure: true,
      builder: (context, onInit, onDispose) =>     Scaffold(
        backgroundColor: primaryColor,
        // appBar: AppBar(
        //   backgroundColor: primaryColor,
        //   iconTheme: IconThemeData(color: Colors.white),
        //   automaticallyImplyLeading: true,
        //   title: Text(
        //     'Online DashBoard',
        //     style: GoogleFonts.radioCanada(
        //       textStyle: TextStyle(
        //         fontSize: 15.sp,
        //         fontWeight: FontWeight.normal,
        //         color: Colors.white,
        //       ),
        //     ),
        //   ),
        //
        //
        // ),
        body: Center(
          child: _getPage(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(

          items: const <BottomNavigationBarItem>[
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.calendar_month),
            //   label: 'Previous Papers',
            // ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Teachers',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.live_tv_outlined),
              label: 'Live Class',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_edu),
              label: 'History',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          backgroundColor: primaryColor,
          type: BottomNavigationBarType.fixed,  // Ensures all items are shown

          selectedLabelStyle: GoogleFonts.radioCanada(
            textStyle: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
          unselectedLabelStyle: GoogleFonts.radioCanada(
            textStyle: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
          showUnselectedLabels: true,
          // Add this line to show unselected labels

          onTap: _onItemTapped,
        ),
        // floatingActionButton: Padding(
        //   padding: const EdgeInsets.only(top: 00.0),
        //   child: Container(
        //     height: 70,
        //     width: 70,
        //     child: FloatingActionButton(
        //       backgroundColor: Colors.purple,
        //
        //       onPressed: () {
        //         Navigator.push(
        //           context,
        //           MaterialPageRoute(builder: (context) => ChatScreen()),
        //         );
        //       },
        //       child: Image.asset(
        //         'assets/Animation2.gif',  // Provide the path to your image here
        //         fit: BoxFit.fill,  // Ensure the image fits well inside the button
        //       ),
        //       shape: CircleBorder(), // This makes the FAB circular
        //
        //     ),
        //   ),
        // ),

      ),
    );

  }
}
