import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:realestate/Utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../../baseurl/baseurl.dart';

class TransactionsScreen extends StatefulWidget {
  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  // List<Transaction> transactions = [
  //   Transaction(id: 'ORD123', title: 'Payment A', amount: 50.0, paymentType: 'Wallet', dateTime: DateTime.now(), isCompleted: true),
  //   Transaction(id: 'ORD124', title: 'Payment B', amount: 75.0, paymentType: 'Online', dateTime: DateTime.now().subtract(Duration(days: 1)), isCompleted: true),
  //   Transaction(id: 'ORD125', title: 'Payment C', amount: 100.0, paymentType: 'Wallet', dateTime: DateTime.now().subtract(Duration(days: 2)), isCompleted: true),
  //   Transaction(id: 'ORD126', title: 'Payment D', amount: 150.0, paymentType: 'Online', dateTime: DateTime.now().subtract(Duration(days: 3)), isCompleted: false),
  // ];
  List<dynamic> transactions = [];


  @override
  void initState() {
    super.initState();
    hitViewTransactionList();
  }



  Future<void> hitViewTransactionList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString(
      'token',
    );
    final response = await http.get(
      Uri.parse("${viewTransaction}"),
      headers: {
        'Authorization': 'Bearer $token', // Include your token here
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('transactions')) {
        setState(() {
          transactions = responseData['transactions'];
          print('List :-  $transactions');
        });
      } else {
        throw Exception('Invalid API response: Missing "category" key');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: primaryColor,
        title: Text('View Transactions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: false,
        elevation: 5,

      ),
      body:transactions.isEmpty? Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ): Padding(
        padding: EdgeInsets.all(3.w),
        child: ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return Stack(
              children: [
                Card(
                  elevation: 3,
                  color: Colors.green.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20.r,
                                      backgroundColor: transaction['payment_method'] == 'Payment made using wallet' ? Colors.green : Colors.green,
                                      child: Icon(
                                        transaction['payment_method']  == 'Payment made using wallet' ? Icons.account_balance_wallet : Icons.payment,
                                        color: Colors.white,
                                        size: 20.sp,
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'PAY. ID: ${transaction['payment_id']}',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          'Order ID:${transaction['order_id']}',
                                          style: TextStyle(color: Colors.grey[700], fontSize: 12.sp),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Text(
                                    //   'Amount',
                                    //   style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
                                    // ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        '₹${transaction['amount']}',
                                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),


                              ],
                            ),
                            Divider(color: Colors.grey.shade300),
                            Padding(
                              padding:  EdgeInsets.only(left: 0.sp,right: 0.sp),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [

                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: transaction['payment_method']=='UPI' ? Colors.blueGrey : Colors.blueGrey,
                                    ),
                                    child: Padding(
                                      padding:  EdgeInsets.only(left: 8.sp,right: 8.sp,top: 5.sp,bottom: 5.sp),
                                      child: Text(
                                        transaction['payment_method']=='UPI'?'Online':'Wallet',
                                        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w500,color: Colors.grey.shade50),
                                      ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      // Text(
                                      //   'Date & Time',
                                      //   style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
                                      // ),
                                      Text(
                                        transaction['txn_date'],
                                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),

                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                    decoration: BoxDecoration(
                                      color: transaction['status']=='success' ? Colors.green : Colors.red,
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Text(
                                      transaction['status']=='success' ? 'Success' : 'Failed',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.sp),
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          ],
                        ),

                      ],
                    ),
                  ),
                ),

              ],
            );
          },
        ),
      ),
    );
  }
}
