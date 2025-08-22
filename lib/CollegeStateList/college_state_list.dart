import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:realestate/constants/color_constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'college_list.dart';

class CollegeState {
  final String name;
  final String colleges;
  final IconData icon;

  CollegeState(this.name, this.colleges, this.icon);
}

class CollegeGridScreen extends StatefulWidget {
  const CollegeGridScreen({super.key});

  @override
  State<CollegeGridScreen> createState() => _CollegeGridScreenState();
}

class _CollegeGridScreenState extends State<CollegeGridScreen> {

  List collegeStates = []; // Declare a list to hold API data


  @override
  void initState() {
    super.initState();
    fetchAssignmentsData();
  }


  Future<void> fetchAssignmentsData() async {


    final response = await http.get(
      Uri.parse('https://ksadmission.in/api/states'),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      setState(() {
        collegeStates = jsonResponse['data']; // Update state with fetched data
      });
    } else {
      // _showLoginDialog();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: ColorConstants.primaryColor,
      appBar: AppBar(
        backgroundColor: ColorConstants.primaryColor,
        iconTheme: IconThemeData(color: Colors.white),

        title: const Text("Universities in India",style: TextStyle(
          color: Colors.white
        ),),
      ),
      body:(collegeStates.isNotEmpty)?
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
          ),
          itemCount: collegeStates.length,
          itemBuilder: (context, index) {
            final collegeState = collegeStates[index];
            return GestureDetector(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return CollegeListScreen(id: collegeState['id'], state: collegeState['name'].toString(),);
                    },
                  ),
                );
              },
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 30.sp,
                          width: 40.sp,
                          child: Image.asset('assets/president.png')),
                      const SizedBox(height: 10),
                      Text(
                        collegeState['name'].toString(),
                        style:  TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      // Text(
                      //   collegeState.colleges,
                      //   style: const TextStyle(
                      //     fontSize: 16,
                      //     color: Colors.grey,
                      //   ),
                      //   textAlign: TextAlign.center,
                      // ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ):Center(child: CircularProgressIndicator())
    );
  }
}
