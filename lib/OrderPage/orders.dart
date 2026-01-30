import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../CommonCalling/data_not_found.dart';
import '../CommonCalling/progressbarPrimari.dart';
import '../CommonCalling/progressbarWhite.dart';
import '../HomePage/home_page.dart';
import '../Utils/textSize.dart';
import '../baseurl/baseurl.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  bool isLoading = false;


  List<dynamic> doubtlist = [];


  @override
  void initState() {
    super.initState();
    hitDoubtList();
  }


  Future<void> hitDoubtList() async {
    setState(() => isLoading = true);

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(offlinePlanstatus),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        setState(() {
          doubtlist = responseData['data'] ?? []; // ✅ null safe
        });
      } else {
        setState(() => doubtlist = []);
      }
    } catch (e) {
      setState(() => doubtlist = []);
    }

    setState(() => isLoading = false);
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF010071), Color(0xFF0A1AFF)],
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
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  size: 25,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Orders',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "Track your offline plan orders & approvals",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
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



      body: isLoading
          ?const PrimaryCircularProgressWidget()
          : doubtlist.isEmpty
          ? const Center(child: DataNotFoundWidget())
          : ListView.builder(
        itemCount: doubtlist.length,
        itemBuilder: (BuildContext context, int index) {
          final item = doubtlist[index];
          final plan = item['plan'] ?? {};

          return Container(
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: EdgeInsets.all(3.sp),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(0.sp),
                  child: SizedBox(
                    height: 40.sp,
                    width: 40.sp,
                    child: Image.asset('assets/business-plan.png'),
                  ),
                ),
                title: Text(
                  (plan['name'] ?? '').toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: TextSizes.textsmall,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (plan['plan_desc'] ?? '').toString(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontSize: TextSizes.textsmall,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    Text(
                      (item['entry_date'] ?? '').toString(),
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontSize: TextSizes.textsmall,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      ' ₹ ${(plan['price'] ?? '0').toString()}',
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontSize: TextSizes.textmedium,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      ' ${(item['status_text'] ?? '').toString()}',
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontSize: TextSizes.textsmall2,
                          color: (item['status_text'] == 'Accepted')
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),


    );
  }
}
