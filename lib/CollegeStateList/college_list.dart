import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:realestate/Utils/app_colors.dart';
import '../CommonCalling/data_not_found.dart';
import '../CommonCalling/progressbarWhite.dart';
import 'college_detail_screen.dart';

class CollegeListScreen extends StatefulWidget {
  final int? id;
  final String state;

  const CollegeListScreen({super.key, required this.id, required this.state});

  @override
  State<CollegeListScreen> createState() => _CollegeListScreenState();
}

class _CollegeListScreenState extends State<CollegeListScreen> {
  bool isLoading = false;
  List<dynamic> collegeStates = []; // Declare a list to hold API college

  @override
  void initState() {
    super.initState();
    postWithQueryParams();
  }

  Future<void> postWithQueryParams() async {
    setState(() {
      isLoading = true; // Show progress bar
    });

    try {
      // Construct the URL with query parameters
      final url = Uri.parse(
          'https://ksadmission.in/api/universitywithstates?state_id=${widget.id}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          // Specify the content type if needed
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        // Safely check if the 'college' key exists and is a List
        if (jsonResponse.containsKey('data') &&
            jsonResponse['data'] is List) {
          setState(() {
            collegeStates = jsonResponse['data'];
            isLoading = false; // Stop progress bar
          });
        } else {
          setState(() {
            collegeStates = []; // Default to an empty list if 'college' is null
            isLoading = false; // Stop progress bar
          });
          if (kDebugMode) {
            print('College key is missing or not a list.');
          }
        }
      } else {
        if (kDebugMode) {
          print('Failed to fetch college. Status Code: ${response.statusCode}');
        }
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred: $e');
      }
      setState(() {
        isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Top Universities in ${widget.state}',
          style: TextStyle(color: Colors.white, fontSize: 16.sp),
        ),
      ),
      body: isLoading
          ? WhiteCircularProgressWidget()
          : collegeStates.isEmpty
              ? Center(child: DataNotFoundWidget())
              : ListView.builder(
                  itemCount: collegeStates.length,
                  itemBuilder: (context, index) {
                    final college = collegeStates[index];
                    return Card(
                      margin: EdgeInsets.all(8),
                      color: Colors.grey.shade200,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(10), // Rounded corners
                            child: CachedNetworkImage(
                              imageUrl: college["picture_urls"].toString(),
                              height: 200.sp,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  Center(child: CircularProgressIndicator()),
                              // Loading indicator
                              errorWidget: (context, url, error) => SizedBox(
                                height: 200,
                                width: double.infinity,
                                child: Image.asset(
                                  'assets/No_Image_Available.jpg',
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  college["university_name"].toString(),
                                  maxLines: 2,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        "State:  ${widget.state} ${'/'} ${college["country"].toString()}"),
                                    Text(
                                        "Univ Grade: ${college["university_grade"].toString().toUpperCase() }"),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        "University Type: ${college["university_type"] == 1 ? 'Government' : college["university_type"] == 2 ? 'Private' : 'N/A'}"),
                                    Text(
                                        "Estd. Year: ${college["established_year"] ?? 'N/A'}"),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Specialization: ${'Research'}"),
                                    Text(
                                        "NIRF Rank: ${college["nirfRank"] ?? 'N/A'}"),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        "Fees: ${' ₹ ${college["min_fees"] ?? 'N/A'} - ${college["max_fees"] ?? 'N/A'}'}"),
                                    Text(
                                        "Medium: ${college["medium"].toString().toUpperCase()}"),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            final TextEditingController nameController = TextEditingController(text: 'Enter Your name ');
                                            final TextEditingController contactController = TextEditingController(text: '+91');

                                            return AlertDialog(
                                              title: Text('Edit Contact Details'),
                                              content: Card(
                                                elevation: 4,
                                                margin: EdgeInsets.all(0),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      TextFormField(
                                                        controller: nameController,
                                                        decoration: InputDecoration(
                                                          labelText: 'Name',
                                                          border: OutlineInputBorder(),
                                                        ),
                                                      ),
                                                      SizedBox(height: 16),
                                                      TextFormField(
                                                        controller: contactController,
                                                        decoration: InputDecoration(
                                                          labelText: 'Contact Number',
                                                          border: OutlineInputBorder(),
                                                        ),
                                                        keyboardType: TextInputType.phone,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(),
                                                  child: Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    String updatedName = nameController.text;
                                                    String updatedContact = contactController.text;
                                                    // You can handle the updated values here
                                                    if (kDebugMode) {
                                                      print('Updated Name: $updatedName');
                                                    }
                                                    if (kDebugMode) {
                                                      print('Updated Contact: $updatedContact');
                                                    }
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('Ok'),
                                                ),
                                              ],
                                            );
                                          },
                                        );


                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                      ),
                                      child: Text(
                                        'APPLY NOW',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CollegeDetailScreen(
                                              data: collegeStates[index],
                                              state: widget.state,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'VIEW DETAILS',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
