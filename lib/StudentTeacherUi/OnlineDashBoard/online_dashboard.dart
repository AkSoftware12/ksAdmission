import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:secure_content/secure_content.dart';

import '../../HexColorCode/HexColor.dart';
import '../../HomePage/home_page.dart';
import '../live_class.dart';
import '../my_appointment.dart';
import '../student_teacher_list.dart';
// import '../../HomePage/home_page.dart';
// import '../../Utils/app_colors.dart';

class OnlineDashBoard extends StatefulWidget {
  const OnlineDashBoard({super.key});

  @override
  State<OnlineDashBoard> createState() => _YearpageState();
}

class _YearpageState extends State<OnlineDashBoard> {
  int _selectedIndex = 0;

  final List<int> _tabHistory = [0]; // ✅ start tab

  final List<String> _titles = ["Teachers", "Live Class", "History"];
  final List<String> _subTitles = [
    "Find your teachers 👨‍🏫",
    "Join your live class 🔴",
    "See your history 📚",
  ];


  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;

      // ✅ history maintain
      _tabHistory.add(index);

      // (optional) same tab repeated ho to avoid duplicates:
      // if (_tabHistory.isEmpty || _tabHistory.last != index) _tabHistory.add(index);
    });
  }

  Future<bool> _onWillPop() async {
    if (_tabHistory.length > 1) {
      setState(() {
        _tabHistory.removeLast();
        _selectedIndex = _tabHistory.last;
      });
      return false;
    }

    // ✅ when already on 0 -> pop to previous screen (no app exit)
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    return false; // ✅ still prevent app exit
  }


  Widget _getPage(int page) {
    switch (page) {
      case 0:
        return TeacherListScreen();
      case 1:
        return LiveClassScreen();
      case 2:
        return HistoryAppointmentScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SecureWidget(
      isSecure: true,
      builder: (context, onInit, onDispose) => Scaffold(
        backgroundColor: HexColor('#010071'),
        appBar: AppBar(
          elevation: 0,
          centerTitle: false,
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF010071),
                  Color(0xFF0A1AFF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
          ),
          title: Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _onWillPop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back, size: 25, color: Colors.white),
                ),
              ),

              const SizedBox(width: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _titles[_selectedIndex], // ✅ dynamic
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _subTitles[_selectedIndex], // ✅ dynamic
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_none_rounded),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotificationList()),
                  );
                },
              ),
            ),
          ],
        ),
        body: _getPage(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
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
          backgroundColor: HexColor('#010071'),
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: GoogleFonts.radioCanada(
            textStyle: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.normal,
            ),
          ),
          unselectedLabelStyle: GoogleFonts.radioCanada(
            textStyle: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.normal,
            ),
          ),
          showUnselectedLabels: true,
          onTap: _onItemTapped, // ✅ history wala
        ),
      ),
    );
  }
}
