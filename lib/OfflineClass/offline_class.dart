
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import '../AddAddress/add_address.dart';
import '../HexColorCode/HexColor.dart';
import '../HomePage/home_page.dart';
import '../Plan/plan.dart';
import '../Utils/app_colors.dart';
import '../baseurl/baseurl.dart';
import '../YoutubPlayer/youtube_players.dart';


class VideoData {
  final String title;
  final String url;
  final String image;


  VideoData( {
    required this.title,
    required this.url,
    required this.image,

  });
}
class OfflineClass extends StatefulWidget {
  final String title;
  final bool isLocked; // Declare variable to receive value
  const OfflineClass({super.key, required this.title, required this.isLocked,});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<OfflineClass> with SingleTickerProviderStateMixin {
  late TabController _tabController;



  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(
            color: Colors.white
        ),
        title: Text('${widget.title}',style: TextStyle(color: Colors.white),),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab( text: "Video"),
            Tab( text: "Offline Package"),
          ],
          labelColor: Colors.white, // Selected tab color
          unselectedLabelColor: Colors.grey,

          indicatorColor: Colors.white, // Underline color

        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          OfflineDataTab(isLocked: widget.isLocked,), // First Tab (Offline)
          OfflinePlanScreen(),   // Second Tab (Notes)
        ],
      ),
    );
  }
}



class OfflineDataTab extends StatefulWidget {
  final bool isLocked; // Declare variable to receive value

  const OfflineDataTab({super.key, required this.isLocked, });

  @override
  State<OfflineDataTab> createState() => _OfflineDataTabState();
}

class _OfflineDataTabState extends State<OfflineDataTab> {
  bool _isLoading = false;
  List<dynamic> videoList = [];

  Future<void> fetchVideoData() async {
    setState(() {
      _isLoading = true;
    });

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final Uri uri = Uri.parse(getlecture);
    final Map<String, String> headers = {'Authorization': 'Bearer $token'};
    final response = await http.get(uri, headers: headers);

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);

      if (jsonData.containsKey('lectures')) {
        setState(() {
          videoList = jsonData['lectures'];
        });
      } else {
        throw Exception('Invalid API response: Missing "lectures" key');
      }
    } else {
      throw Exception('Failed to load video data');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchVideoData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.5,
        ),
        itemCount: videoList.length,
        itemBuilder: (context, index) {
          // 📌 Updated Logic for Unlocking
          bool isUnlocked = widget.isLocked == false || index == 0;




          return GestureDetector(
            onTap: () {
              if (isUnlocked) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoPlayer(
                      url: videoList[index]['video_url'].toString(),
                      title: videoList[index]['title'].toString(),
                      videoId: videoList[index]['id'],
                      videoStatus: "unlocked",
                    ),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlanScreen(appBar: 'Upgrade Plan'),
                  ),
                );
              }
            },
            child: Stack(
              children: [
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      '${baseUrlImage}${videoList[index]['thumbnail'].toString()}',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // 🔒 Show Lock Overlay if Video is Locked
                if (!isUnlocked)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(Icons.lock, color: Colors.white, size: 40),
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






class OfflinePlanScreen extends StatefulWidget {
  const OfflinePlanScreen({super.key});

  @override
  State<OfflinePlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<OfflinePlanScreen> {
  String subsid = "0";
  String planId = "";
  Razorpay _razorpay = new Razorpay();
  var publicKey = '';
  var razorPayKey = '';
  double totalAmount = 0.0;
  double newtotalAmount = 0.0;
  dynamic currency = '';

  Set<String> selectedVendorIds = Set<String>();
  // List<String> selectedIds = '';

  bool visiblity = false;
  String promocode = '';

  bool razor = false;
  bool paystack = false;

  var showDialogBox = false;

  int radioId = -1;

  var setProgressText = 'Proceeding to placed order please wait!....';

  var showPaymentDialog = false;

  double walletAmount = 0.0;
  double walletUsedAmount = 0.0;
  bool isFetch = false;

  bool iswallet = false;
  bool isCoupon = false;

  double coupAmount = 0.0;

  bool isDataLoading = true;






  List<dynamic> allPlan = [];

  Future<void> hitPlan() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('token'); // Assuming 'token' is stored in SharedPreferences

    try {
      final response = await http.get(
        Uri.parse(offlineplan),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {

        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey('plans')) {
          setState(() {
            allPlan = responseData['plans'];
            print(allPlan);
          });
        } else {
          throw Exception('Invalid API response: Missing "plans" key');
        }



        // Successful response
        print('Response data: ${response.body}');
      } else {
        // Handle other status codes
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    hitPlan();
  }

  Future<void> createPlan() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: primaryColor,
              ),
              // SizedBox(width: 16.0),
              // Text("Logging in..."),
            ],
          ),
        );
      },
    );

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString(
      'id',
    );
    final String? token = prefs.getString(
      'token',
    );

    Map<String, dynamic> responseData = {
      "plan_id": planId,
      "subject_id": userId.toString(),
    };
    try {
      // Send the POST request with headers (including token) and responseData
      final response = await http.post(
        Uri.parse(planCreateOffline),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Add the token here
        },
        body: json.encode(responseData),
      );

      // Check the response status and handle it accordingly
      if (response.statusCode == 200) {
        print("Data sent successfully: ${response.body}");
        final Map<String, dynamic> jsonData = json.decode(response.body);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Homepage(
              initialIndex: 0,
            ),
          ),
        );
      } else {
        print("Failed to send data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error occurred: $e");
    }
  }

  void razorPay(keyRazorPay, amount) async {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    Timer(Duration(seconds: 2), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var options = {
        'key': '${keyRazorPay}',
        'amount': amount,
        'name': '${prefs.getString('data')}',
        'description': 'Subscription',
        'prefill': {
          'contact': '${prefs.getString('user_phone')}',
          'email': '${prefs.getString('user_email')}'
        },
        'external': {
          'wallets': ['paytm']
        }
      };

      try {
        _razorpay.open(options);
      } catch (e) {
        debugPrint(e.toString());
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 0.sp),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: allPlan.length,
                itemBuilder: (context, index) => Padding(
                  padding: EdgeInsets.all(5.sp),
                  child: GestureDetector(
                    onTap: () {
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Container(
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xff16222a), Color(0xff3a6073)],
                                  stops: [0, 1],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(
                                  color: HexColor('#ABB7B7'),
                                  width: 1.sp,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          height: 35.sp,
                                          width: 35.sp,
                                          child: Image.network(allPlan[index]
                                          ['image_url'].toString(),color: HexColor(allPlan[index]['color'].toString()),),
                                        ),
                                        SizedBox(
                                          width: 10.sp,
                                        ),
                                        Center(
                                          child: Padding(
                                            padding: EdgeInsets.only(top: 0.sp),
                                            child: Text(
                                              '${allPlan[index]['category']['name']}',
                                              style: TextStyle(
                                                  fontSize: 20.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: HexColor(allPlan[index]['color'].toString())),
                                            ),
                                          ),
                                        ),
                                        Spacer(),

                                      ],
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          height: 3.sp,
                                          width: 35.sp,
                                        ),
                                        SizedBox(
                                          width: 10.sp,
                                        ),
                                        Center(
                                          child: Padding(
                                            padding: EdgeInsets.only(top: 0.sp),
                                            child: Text(
                                              '${allPlan[index]['name'].toString()}',
                                              style: TextStyle(
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: HexColor(allPlan[index]['color'].toString())),
                                            ),
                                          ),
                                        ),
                                        Spacer(),
                                        // Text('${'₹ '}${allPlan[index]['price']}',
                                        //   style: TextStyle(
                                        //       fontSize: 30.sp,
                                        //       fontWeight: FontWeight.bold,
                                        //       color: Colors.orange
                                        //   ),
                                        //
                                        // )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 20.sp,
                                    ),
                                    Text(
                                      '${'✔️ '}${ allPlan[index]['desc'].toString()}',
                                      style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.normal,
                                          color:  HexColor(allPlan[index]['color'].toString())),
                                    ),


                                      Padding(
                                        padding:  EdgeInsets.only(top: 18.sp),
                                        child: Center(
                                          child: SizedBox(
                                            height: 40.sp,
                                            width: 150.sp,
                                            child: Center(
                                              child: Padding(
                                                padding: const EdgeInsets.all(0.0),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      // subsid = planlist[i].planId.toString();
                                                      planId = allPlan[index]['id'].toString();
                                                    });

                                                    // openCheckout(
                                                    //   'rzp_live_GdwjggtHsxB9f8',
                                                    //   double.parse( allPlan[index]['price'].toString()) * 100,
                                                    // );

                                                    // createPlan();


                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            AddAddress(
                                                              categoryId: allPlan[index]['category']['id'],
                                                              price: allPlan[index]['price_without_gst'].toString(),
                                                              planId: allPlan[index]['id'],
                                                              isSubject: allPlan[index]['is_subject_wise'],),
                                                      ),
                                                    );

                                                  },
                                                  child: Card(
                                                    elevation: 4,
                                                    color:  HexColor(allPlan[index]['color'].toString()),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          5.sp),
                                                    ),
                                                    child: Center(
                                                        child: Text(
                                                          'Continue',
                                                          style: TextStyle(
                                                              fontSize: 15.sp,
                                                              fontWeight:
                                                              FontWeight.normal,
                                                              color: Colors.white),
                                                        )),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child:   Container(
                                height: 70.sp,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xff16222a), Color(0xff3a6073)],
                                    stops: [0, 1],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 1.sp,
                                  ),
                                  borderRadius: BorderRadius.circular(8.sp),
                                ),
                                child: Padding(
                                  padding:  EdgeInsets.only(top: 10.sp),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [

                                      Container(
                                        width: 150.sp,
                                        child: Center(
                                          child: Container(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: [
                                                Center(
                                                  child: SizedBox(
                                                    height: 60.sp,
                                                    child: Center(
                                                      child: Padding(
                                                          padding:
                                                          const EdgeInsets.all(8.0),
                                                          child: Row(
                                                            children: [
                                                              SizedBox(
                                                                height: 30.sp,
                                                                width: 30.sp,
                                                                child: Image.network(allPlan[index]
                                                                ['image_url'].toString(),color: HexColor(allPlan[index]['color'].toString()),),
                                                              ),
                                                              SizedBox(
                                                                width: 10.sp,
                                                              ),
                                                              Text(
                                                                '${allPlan[index]['category']['name'].toString()}',
                                                                style: TextStyle(
                                                                    fontSize: 16.sp,
                                                                    fontWeight: FontWeight.bold,
                                                                    color: HexColor(allPlan[index]['color'].toString())),
                                                              ),
                                                            ],
                                                          )),
                                                    ),
                                                  ),
                                                ),

                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 80.sp,
                                        width: 1.sp,
                                        color: Colors.grey,
                                      ),

                                      Container(
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding:  EdgeInsets.only(right: 5.sp),
                                              child: Center(
                                                child: SizedBox(
                                                  height: 60.sp,
                                                  child: Center(
                                                    child: Padding(
                                                        padding:
                                                        const EdgeInsets.all(8.0),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              '${'₹ '}${allPlan[index]['price_without_gst']}',
                                                              style: TextStyle(
                                                                  fontSize: 25.sp,
                                                                  fontWeight: FontWeight.bold,
                                                                  color:Colors.white),
                                                            ),
                                                            // Text(
                                                            //   '${' + '}${'18% GST'}',
                                                            //   style: TextStyle(
                                                            //       fontSize: 7.sp,
                                                            //       fontWeight: FontWeight.bold,
                                                            //       color:Colors.white),
                                                            // ),
                                                          ],
                                                        )),
                                                  ),
                                                ),
                                              ),
                                            ),

                                          ],
                                        ),
                                      ),


                                    ],
                                  ),
                                ),
                              ),

                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child:   Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.sp),
                                ),
                                child:  Padding(
                                  padding:  EdgeInsets.all(3.sp),
                                  child: Text(
                                    '${allPlan[index]['name'].toString()}',
                                    style: TextStyle(
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.bold,
                                        color: HexColor(allPlan[index]['color'].toString())),
                                  ),
                                ),
                              ),

                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }




  void openCheckout(keyRazorPay, amount) async {
    razorPay(keyRazorPay, amount);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // SubscriptionAPI();

    createPlan();

  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      showDialogBox = false;
    });
    Fluttertoast.showToast(msg: "ERROR: " + response.message.toString());
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "ERROR: " + response.toString());
  }
}
