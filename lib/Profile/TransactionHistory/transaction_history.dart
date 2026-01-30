import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:realestate/CommonCalling/progressbarPrimari.dart';
import 'package:realestate/Utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../../HomePage/home_page.dart';
import '../../baseurl/baseurl.dart';

class TransactionsScreen extends StatefulWidget {
  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {

  List<dynamic> transactions = [];
  bool isLoading = true;


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
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);

        throw Exception('Invalid API response: Missing "category" key');
      }
    } else {
      setState(() => isLoading = false);

      throw Exception('Failed to load data');

    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
        title:Row(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: (){
                Navigator.of(context).pop();

              },
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

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Transactions',
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
                    "Track your wallet & online payments",
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
            )


          ],

        ),

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
          ? PrimaryCircularProgressWidget()
          : transactions.isEmpty
          ? _emptyState()
          : ListView.builder(
        padding: EdgeInsets.fromLTRB(5.w, 5.h, 5.w, 5.h),
        itemCount: transactions.length,
        reverse: true,
        itemBuilder: (context, index) {
          final t = transactions[index];
          return _transactionCard(t);
        },
      ),
    );
  }



  Widget _transactionCard(Map<String, dynamic> t) {
    final String status = (t['status'] ?? '').toString().toLowerCase();
    final bool success = status == 'success';

    final String methodRaw = (t['payment_method'] ?? '').toString();
    final bool isWallet = methodRaw.contains('wallet') || methodRaw.toLowerCase() == 'wallet';
    final bool isUpi = methodRaw.toLowerCase().contains('upi');

    final Color statusColor = success ? const Color(0xFF16A34A) : const Color(0xFFEF4444);
    final Color methodColor = isWallet ? const Color(0xFF0EA5E9) : const Color(0xFF6366F1);

    final IconData icon = isWallet ? Icons.account_balance_wallet_rounded : Icons.payments_rounded;

    final String paymentId = (t['payment_id'] ?? '—').toString();
    final String orderId = (t['order_id'] ?? '—').toString();
    final String amount = (t['amount'] ?? '0').toString();
    final String txnDate = (t['txn_date'] ?? '').toString();

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.r),
        color: Colors.white,
        border: Border.all(color: Colors.blue.shade100,width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(5.w),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 44.w,
                  width: 44.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14.r),
                    gradient: LinearGradient(
                      colors: [
                        methodColor.withOpacity(0.18),
                        methodColor.withOpacity(0.06),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(icon, color: methodColor, size: 22.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PAY ID: $paymentId',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Order ID: $orderId',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '₹$amount',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 5.h),
            Container(
              height: 1,
              color: const Color(0xFFF1F5F9),
            ),
            SizedBox(height: 5.h),

            Row(
              children: [
                _chip(
                  text: isWallet ? 'Wallet' : (isUpi ? 'UPI' : 'Online'),
                  color: methodColor,
                  icon: isWallet ? Icons.account_balance_wallet_rounded : Icons.language_rounded,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.schedule_rounded, size: 16.sp, color: const Color(0xFF64748B)),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          txnDate.isEmpty ? '—' : txnDate,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: statusColor.withOpacity(0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        success ? Icons.verified_rounded : Icons.cancel_rounded,
                        size: 14.sp,
                        color: statusColor,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        success ? 'Success' : 'Failed',
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w800,
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
    );
  }

  Widget _chip({required String text, required Color color, required IconData icon}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withOpacity(0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(22.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 72.w,
              width: 72.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0A1AFF).withOpacity(0.10),
              ),
              child: Icon(Icons.receipt_long_rounded, size: 34.sp, color: const Color(0xFF0A1AFF)),
            ),
            SizedBox(height: 12.h),
            Text(
              'No transactions found',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
            ),
            SizedBox(height: 6.h),
            Text(
              'Your recent payments will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w500, color: const Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}