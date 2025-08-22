import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:number_to_words_english/number_to_words_english.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:realestate/Utils/image.dart';
import 'package:flutter_dash/flutter_dash.dart';
import '../../Utils/string.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;

class InvoicePage extends StatefulWidget {
  final Map<String, dynamic> data;

  const InvoicePage({
    super.key,
    required this.data,
  });

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Builder(builder: (context) {
          return Center(
              child: Text(
            ' Tax Invoice',
            style: TextStyle(
                fontSize: 13.sp,
                color: Colors.black,
                fontWeight: FontWeight.bold),
          ));
        }),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: _generateAndPrintPDF,
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(height: 40, width: 40, child: Image.asset(logo2)),
                    Spacer(),
                    Center(
                      child: Column(
                        children: [
                          Container(
                            height: 20.h, // Use .h for responsive height
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black, // Black color
                                width: 1.sp, // Responsive width
                              ),
                            ),
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.only(left: 8.0, right: 8),
                                child: Text(
                                  'KS ADMISSION',
                                  style: TextStyle(
                                      fontSize: 15.sp,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          Text(
                            'CUET, NEET, and other competitive exam preparations.',
                            style: TextStyle(
                                fontSize: 5.sp,
                                color: Colors.black,
                                fontWeight: FontWeight.normal),
                          )
                        ],
                      ),
                    ),
                    Spacer(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SizedBox(
                        //   child: Text(
                        //     'Contact - ${'+91 95965 47794'}',
                        //     style: TextStyle(
                        //         fontSize: 7,
                        //         color: Colors.black,
                        //         fontWeight: FontWeight.bold),
                        //   ),
                        // ),
                        SizedBox(
                          child: Text(
                            'Email - ${'info@ksadmission.com'}',
                            style: TextStyle(
                                fontSize: 7,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          child: Text(
                            'GSTIN - ${'05COJPP8294L3Z1'}',
                            style: TextStyle(
                                fontSize: 7,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    )
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8.0, bottom: 8),
                  child: Divider(
                    height: 3,
                    thickness: 3,
                    color: Colors.black,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          child: Text(
                            'To : - ${widget.data['user']['name']}',
                            style: TextStyle(
                                fontSize: 7.sp,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Dash(
                          direction: Axis.horizontal,
                          length: 150,
                          dashLength: 5,
                          dashColor: Colors.grey,
                        ),
                        SizedBox(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.data['user']['address']},${widget.data['user']['district']},${widget.data['user']['state']},${widget.data['user']['pin']}',
                                style: TextStyle(
                                    fontSize: 7.sp,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              // Text(
                              //   '${data['user']['state']},${data['user']['pin']}',
                              //   style: TextStyle(
                              //       fontSize: 7.sp,
                              //       color: Colors.black,
                              //       fontWeight: FontWeight.bold),
                              // ),
                            ],
                          ),
                        ),
                        Dash(
                          direction: Axis.horizontal,
                          length: 150,
                          dashLength: 5,
                          dashColor: Colors.grey,
                        ),
                        SizedBox(
                          child: Text(
                            '${'Email:  ${widget.data['user']['email']}'}',
                            style: TextStyle(
                                fontSize: 7.sp,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          child: Text(
                            'INVOICE/BILL NO.: - ${widget.data['bill_no']}',
                            style: TextStyle(
                                fontSize: 7.sp,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Dash(
                          direction: Axis.horizontal,
                          length: 150,
                          dashLength: 5,
                          dashColor: Colors.grey,
                        ),
                        SizedBox(
                          child: Text(
                            '${'DATE : ${DateFormat('dd-MM-yyyy').format(DateTime.parse(widget.data['started_at']) // Parse the string to DateTime
                                )}'}',
                            style: TextStyle(
                                fontSize: 7.sp,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Dash(
                          direction: Axis.horizontal,
                          length: 150,
                          dashLength: 5,
                          dashColor: Colors.grey,
                        ),
                        SizedBox(
                          child: Text(
                            'CONTACT: ${widget.data['user']['contact']}',
                            style: TextStyle(
                                fontSize: 7.sp,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Table(
                  border: TableBorder.all(),
                  columnWidths: {
                    0: FractionColumnWidth(0.06),
                    1: FractionColumnWidth(0.28),
                    2: FractionColumnWidth(0.14),
                    3: FractionColumnWidth(0.1),
                    4: FractionColumnWidth(0.14),
                    5: FractionColumnWidth(0.14),
                    6: FractionColumnWidth(0.15),
                  },
                  children: [
                    // Header Row

                    TableRow(children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                            child: Text('Sl.',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 8))),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                          child: Text('ITEM DESCRIPTION',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 8)),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('HSN/SAC',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 8)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                            child: Text('QTY',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 8))),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                            child: Text('RATE',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 8))),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                            child: Text('GST.%',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 8))),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                            child: Text('AMOUNT',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 8))),
                      ),
                    ]),
                    // Data Row
                    TableRow(children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Container(
                          height: 100.sp,
                          child: Text('1',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 8)),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                              '${widget.data['plan']['category']['name']} ${widget.data['plan']['name'].toUpperCase()}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 8)),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                          child: Text('999293',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 8)),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                          child: Text('1',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 8)),
                        ),
                      ), // Empty cell for consistency
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                          child: Text('${widget.data['plan']['price']}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 8)),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                          child: Text('18',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 8)),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                          child: Text('${widget.data['plan']['pay_amount']}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 8)),
                        ),
                      ),
                    ]),
                  ],
                ),
                Table(
                  border: TableBorder.all(),
                  columnWidths: {
                    0: FractionColumnWidth(0.48),
                    1: FractionColumnWidth(0.1),
                    2: FractionColumnWidth(0.14),
                    3: FractionColumnWidth(0.14),
                    4: FractionColumnWidth(0.15),
                  },
                  children: [
                    // Header Row

                    TableRow(children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Sub Total(₹)',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 8)),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                            child: Text('1',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 8))),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                            child: Text('',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 8))),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                            child: Text('${widget.data['plan']['gst_amount']}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 8))),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(
                            child: Text('${widget.data['plan']['price']}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 8))),
                      ),
                    ]),
                    // Data Row
                  ],
                ),
                Table(
                  border: TableBorder.all(),
                  columnWidths: {
                    0: FractionColumnWidth(0.86),
                    1: FractionColumnWidth(0.15),
                  },
                  children: [
                    // Header Row

                    TableRow(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'In Words: ${NumberToWordsEnglish.convert(int.parse(widget.data['plan']['pay_amount'].toString().split('.')[0]))} Rupees Only',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 6.sp,
                                ),
                              )),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Grand Total(₹)',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 8)),
                          ),
                        ],
                      ),
                      Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              '${double.tryParse(widget.data['plan']['pay_amount'])?.ceil() ?? "0.00"}.00',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 8),
                            ),
                          )),
                    ]),
                    // Data Row
                  ],
                ),
                Table(
                  border: TableBorder.all(),
                  columnWidths: {
                    0: FractionColumnWidth(0.14),
                    1: FractionColumnWidth(0.14),
                    2: FractionColumnWidth(0.14),
                    3: FractionColumnWidth(0.14),
                    4: FractionColumnWidth(0.14),
                    5: FractionColumnWidth(0.14),
                    6: FractionColumnWidth(0.17),
                  },
                  children: [
                    TableRow(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                              child: Text('Description',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 6.sp))),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                            child: Text('Taxable 5%',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 6.sp)),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Taxable 12%',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 6.sp)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                              child: Text('Taxable 18%',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 6.sp))),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                              child: Text('Taxable 28%',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 6.sp))),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                              child: Text('Exempted',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 8))),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                              child: Text('Round Off',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 8))),
                        ),
                      ],
                    ),
                    // New row: Taxable Amt
                    TableRow(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                            child: Text('Taxable Amt',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 6.sp)),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                              child:
                                  Text('---', style: TextStyle(fontSize: 8))),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                              child:
                                  Text('---', style: TextStyle(fontSize: 8))),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                              child: Text('${widget.data['plan']['price']}',
                                  style: TextStyle(fontSize: 8))),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                              child:
                                  Text('---', style: TextStyle(fontSize: 8))),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                              child:
                                  Text('---', style: TextStyle(fontSize: 8))),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              '${((double.tryParse(widget.data['plan']['pay_amount'])?.ceil() ?? 0) - (double.tryParse(widget.data['plan']['pay_amount']) ?? 0)).toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // New row: IGST

                    if (widget.data['user']['state'] != 'Uttarakhand')
                      TableRow(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                              child: Text('IGST',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 6.sp)),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                                child:
                                    Text('0', style: TextStyle(fontSize: 8))),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                                child:
                                    Text('0', style: TextStyle(fontSize: 8))),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                                child: Text(
                                    '${widget.data['plan']['gst_amount']}',
                                    style: TextStyle(fontSize: 8))),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                                child:
                                    Text('0', style: TextStyle(fontSize: 8))),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                                child:
                                    Text('0.0', style: TextStyle(fontSize: 8))),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                                child:
                                    Text('0', style: TextStyle(fontSize: 8))),
                          ),
                        ],
                      ),
                    if (widget.data['user']['state'] == 'Uttarakhand')
                      TableRow(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                              child: Text('CGST',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 6.sp)),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                                child:
                                    Text('0', style: TextStyle(fontSize: 8))),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                                child:
                                    Text('0', style: TextStyle(fontSize: 8))),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                                child: Text(
                              () {
                                try {
                                  return '${(double.parse(widget.data['plan']['gst_amount']) / 2).toStringAsFixed(2)}';
                                } catch (e) {
                                  return 'Invalid amount';
                                }
                              }(),
                              style: TextStyle(fontSize: 8),
                            )),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                                child:
                                    Text('0', style: TextStyle(fontSize: 8))),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                                child:
                                    Text('0.0', style: TextStyle(fontSize: 8))),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                                child:
                                    Text('0', style: TextStyle(fontSize: 8))),
                          ),
                        ],
                      ),
                    if (widget.data['user']['state'] == 'Uttarakhand')
                      TableRow(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                              child: Text('SGST',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 6.sp)),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                                child:
                                    Text('0', style: TextStyle(fontSize: 8))),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                                child:
                                    Text('0', style: TextStyle(fontSize: 8))),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                                child: Text(
                              () {
                                try {
                                  return '${(double.parse(widget.data['plan']['gst_amount']) / 2).toStringAsFixed(2)}';
                                } catch (e) {
                                  return 'Invalid amount';
                                }
                              }(),
                              style: TextStyle(fontSize: 8),
                            )),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                                child:
                                    Text('0', style: TextStyle(fontSize: 8))),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                                child:
                                    Text('0.0', style: TextStyle(fontSize: 8))),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                                child:
                                    Text('0', style: TextStyle(fontSize: 8))),
                          ),
                        ],
                      ),
                  ],
                ),
                Table(
                  border: TableBorder.all(),
                  columnWidths: {
                    0: FractionColumnWidth(1.01),
                  },
                  children: [
                    // Header Row

                    TableRow(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                                '${'BANK: ${'CHAKRATA ROAD - DEHRADUN'}'}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 6.sp)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('${'A/c: ${'094461900001172'}'}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 6.sp)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('${'IFSC CODE: ${'YESB0000944'}'}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 6.sp)),
                          ),
                        ],
                      ),
                    ]),
                    // Data Row
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'E & O.E.',
                  style:
                      TextStyle(fontWeight: FontWeight.normal, fontSize: 16.sp),
                ),
                SizedBox(height: 10),
                Text(
                  'Terms and Conditions:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                    '1. Any cost arising from payment clearings or transaction charges are solely the responsibility of the client and will be charged as such.'),
                Text(
                    '2. The recurring / renewal amount of the Package are subjected to change as per the market rates.'),
                Text('3.'
                    ' All disputes are subject to Dehra Dun Jurisdiction.'),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(''),
                      SizedBox(height: 10.sp),
                      Text(''),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'This is a computer-generated invoice. No signature required.',
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Transform.rotate(
              angle: -0.0, // Angle in radians
              child: Opacity(
                opacity: 0.2, // Adjust the opacity
                child: Image.asset(logo2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateAndPrintPDF() async {
    final pdf = pw.Document();

    // Load the image from assets
    final ByteData data = await rootBundle.load(logo2);
    final Uint8List bytes = data.buffer.asUint8List();
    final pw.MemoryImage image = pw.MemoryImage(bytes);

    final ByteData data1 = await rootBundle.load(rupee);
    final Uint8List bytess = data1.buffer.asUint8List();
    final pw.MemoryImage image1 = pw.MemoryImage(bytess);

    // final jsonString = utf8.decode(data.buffer.asUint8List());
    // final decodedData = json.decode(jsonString) as Map<String, dynamic>;

    // Add a page with the image and opacity effect
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Stack(
              children: [
                pw.Center(
                  child: pw.Opacity(
                      opacity: 0.1, // Adjust opacity between 0.0 to 1.0
                      child: pw.SizedBox(
                        // height: 300.sp,
                        // width: 200.sp,
                        child: pw.Image(
                          image,
                        ),
                      )),
                ),

                // Image without opacity
                // pw.Center(child: pw.Image(image)),

                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Center(
                      child: pw.Padding(
                        padding: pw.EdgeInsets.all(15.sp),
                        child: pw.Text(
                          'Tax Invoice',
                          style: pw.TextStyle(
                              fontSize: 11.sp,
                              color: PdfColor.fromHex('#000000'),
                              fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ),
                    pw.Row(
                      children: [
                        pw.Container(
                          height: 50.sp,
                          width: 50.sp,
                          color: PdfColors.white,
                          child: pw.Image(image),
                        ),
                        pw.Spacer(),
                        pw.Center(
                          child: pw.Column(
                            children: [
                              pw.Container(
                                height: 20.h, // Use .h for responsive height
                                decoration: pw.BoxDecoration(
                                  border: pw.Border.all(
                                    color: PdfColor.fromHex('#000000'),
                                    // Black color
                                    width: 1.sp, // Responsive width
                                  ),
                                ),
                                child: pw.Center(
                                  child: pw.Padding(
                                    padding:
                                        pw.EdgeInsets.only(left: 8.0, right: 8),
                                    child: pw.Text(
                                      'KS ADMISSION',
                                      style: pw.TextStyle(
                                          fontSize: 15.sp,
                                          color: PdfColor.fromHex('#000000'),
                                          fontWeight: pw.FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(8.0),
                                child: pw.Text(
                                  'CUET, NEET, and other competitive exam preparations.',
                                  style: pw.TextStyle(
                                      fontSize: 5.sp,
                                      color: PdfColor.fromHex('#000000'),
                                      fontWeight: pw.FontWeight.normal),
                                ),
                              )
                            ],
                          ),
                        ),
                        pw.Spacer(),
                        pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            // pw.SizedBox(
                            //   child: pw.Text(
                            //     'Contact - ${'+91 95965 47794'}',
                            //     style: pw.TextStyle(
                            //         fontSize: 7,
                            //         color: PdfColor.fromHex('#000000'),
                            //         fontWeight: pw.FontWeight.bold),
                            //   ),
                            // ),
                            pw.SizedBox(
                              child: pw.Text(
                                'Email - ${'info@ksadmission.com'}',
                                style: pw.TextStyle(
                                    fontSize: 7,
                                    color: PdfColor.fromHex('#000000'),
                                    fontWeight: pw.FontWeight.bold),
                              ),
                            ),
                            pw.SizedBox(
                              child: pw.Text(
                                'GSTIN - ${'05COJPP8294L3Z1'}',
                                style: pw.TextStyle(
                                    fontSize: 7,
                                    color: PdfColor.fromHex('#000000'),
                                    fontWeight: pw.FontWeight.bold),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.only(top: 8.0, bottom: 8),
                      child: pw.Divider(
                        height: 3,
                        thickness: 3,
                        color: PdfColor.fromHex('#000000'),
                      ),
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.SizedBox(
                              child: pw.Text(
                                'To : - ${widget.data['user']?['name'] ?? 'N/A'}',
                                style: pw.TextStyle(
                                  fontSize: 7.sp,
                                  color: PdfColor.fromHex('#000000'),
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                            pw.Text(
                                '- - - - - - - - - - - - - - - - - - - - - - - - - - -'),
                            pw.SizedBox(
                              child: pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.start,
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    '${widget.data['user']['address']},${widget.data['user']['district']},${widget.data['user']['state']},${widget.data['user']['pin']}',
                                    style: pw.TextStyle(
                                        fontSize: 7.sp,
                                        color: PdfColor.fromHex('#000000'),
                                        fontWeight: pw.FontWeight.bold),
                                  ),
                                  // Text(
                                  //   '${data['user']['state']},${data['user']['pin']}',
                                  //   style: TextStyle(
                                  //       fontSize: 7.sp,
                                  //       color: Colors.black,
                                  //       fontWeight: FontWeight.bold),
                                  // ),
                                ],
                              ),
                            ),
                            pw.Text(
                                '- - - - - - - - - - - - - - - - - - - - - - - - - - -'),
                            pw.SizedBox(
                              child: pw.Text(
                                '${'Email:  ${widget.data['user']['email']}'}',
                                style: pw.TextStyle(
                                    fontSize: 7.sp,
                                    color: PdfColor.fromHex('#000000'),
                                    fontWeight: pw.FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.SizedBox(
                              child: pw.Text(
                                'INVOICE/BILL NO.: - ${widget.data['bill_no']}',
                                style: pw.TextStyle(
                                    fontSize: 7.sp,
                                    color: PdfColor.fromHex('#000000'),
                                    fontWeight: pw.FontWeight.bold),
                              ),
                            ),
                            pw.Text(
                                '- - - - - - - - - - - - - - - - - - - - - - - - - - -'),
                            pw.SizedBox(
                              child: pw.Text(
                                '${'DATE : ${DateFormat('dd-MM-yyyy').format(DateFormat('yyyy-MM-dd').parse(widget.data['started_at']))}'}',
                                style: pw.TextStyle(
                                    fontSize: 7.sp,
                                    color: PdfColor.fromHex('#000000'),
                                    fontWeight: pw.FontWeight.bold),
                              ),
                            ),
                            pw.Text(
                                '- - - - - - - - - - - - - - - - - - - - - - - - - - -'),
                            pw.SizedBox(
                              child: pw.Text(
                                'CONTACT: ${widget.data['user']['contact']}',
                                style: pw.TextStyle(
                                    fontSize: 7.sp,
                                    color: PdfColor.fromHex('#000000'),
                                    fontWeight: pw.FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(
                      height: 10,
                    ),
                    pw.Table(
                      border: pw.TableBorder.all(),
                      columnWidths: {
                        0: pw.FractionColumnWidth(0.06),
                        1: pw.FractionColumnWidth(0.28),
                        2: pw.FractionColumnWidth(0.14),
                        3: pw.FractionColumnWidth(0.1),
                        4: pw.FractionColumnWidth(0.14),
                        5: pw.FractionColumnWidth(0.14),
                        6: pw.FractionColumnWidth(0.15),
                      },
                      children: [
                        // Header Row

                        pw.TableRow(children: [
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8.0),
                            child: pw.Center(
                                child: pw.Text('Sl.',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 8))),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8.0),
                            child: pw.Center(
                              child: pw.Text('ITEM DESCRIPTION',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 8)),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8.0),
                            child: pw.Text('HSN/SAC',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 8)),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8.0),
                            child: pw.Center(
                                child: pw.Text('QTY',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 8))),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8.0),
                            child: pw.Center(
                                child: pw.Text('RATE',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 8))),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8.0),
                            child: pw.Center(
                                child: pw.Text('GST.%',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 8))),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8.0),
                            child: pw.Center(
                                child: pw.Text('AMOUNT',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 8))),
                          ),
                        ]),
                        // Data Row
                        pw.TableRow(children: [
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8.0),
                            child: pw.Container(
                              height: 60.sp,
                              child: pw.Text('1',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 8)),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8.0),
                            child: pw.Center(
                              child: pw.Text(
                                  '${widget.data['plan']['category']['name']} ${widget.data['plan']['name'].toUpperCase()}',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 8)),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8.0),
                            child: pw.Center(
                              child: pw.Text('999293',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 8)),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8.0),
                            child: pw.Center(
                              child: pw.Text('1',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 8)),
                            ),
                          ), // Empty cell for consistency
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8.0),
                            child: pw.Center(
                              child: pw.Text('${widget.data['plan']['price']}',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 8)),
                            ),
                          ),

                          pw.Padding(
                            padding: pw.EdgeInsets.all(8.0),
                            child: pw.Center(
                              child: pw.Text('18',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 8)),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8.0),
                            child: pw.Center(
                              child: pw.Text(
                                  '${widget.data['plan']['pay_amount']}',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 8)),
                            ),
                          ),
                        ]),
                      ],
                    ),
                    pw.Table(
                      border: pw.TableBorder.all(),
                      columnWidths: {
                        0: pw.FractionColumnWidth(0.48),
                        1: pw.FractionColumnWidth(0.1),
                        2: pw.FractionColumnWidth(0.14),
                        3: pw.FractionColumnWidth(0.14),
                        4: pw.FractionColumnWidth(0.15),
                      },
                      children: [
                        // Header Row

                        pw.TableRow(children: [
                          pw.Align(
                              alignment: pw.Alignment.topRight,
                              child: pw.Padding(
                                padding: pw.EdgeInsets.all(8.0),
                                child: pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.end,
                                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                                  children: [
                                    pw.Text(
                                      'Sub Total',
                                      style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 8,
                                      ),
                                    ),
                                    pw.SizedBox(width: 5), // Adds some spacing

                                    pw.Container(
                                      height: 10,
                                      width: 10,
                                      color: PdfColors.white,
                                      child: pw.Image(image1),
                                    ),
                                  ],
                                ),
                              )),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8.0),
                            child: pw.Center(
                                child: pw.Text('1',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 8))),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8.0),
                            child: pw.Center(
                                child: pw.Text('',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 8))),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8.0),
                            child: pw.Center(
                                child: pw.Text(
                                    '${widget.data['plan']['gst_amount']}',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 8))),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8.0),
                            child: pw.Center(
                                child: pw.Text(
                                    '${widget.data['plan']['price']}',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 8))),
                          ),
                        ]),
                        // Data Row
                      ],
                    ),
                    pw.Table(
                      border: pw.TableBorder.all(),
                      columnWidths: {
                        0: pw.FractionColumnWidth(0.86),
                        1: pw.FractionColumnWidth(0.15),
                      },
                      children: [
                        // Header Rowpw.

                        pw.TableRow(children: [
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Padding(
                                padding: pw.EdgeInsets.all(8.0),
                                child: pw.Text(
                                    'In Words:${NumberToWordsEnglish.convert(int.parse(widget.data['plan']['pay_amount'].toString().split('.')[0]))} Rupees Only',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 6.sp)),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(8.0),
                                child: pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.end,
                                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                                  children: [
                                    pw.Text(
                                      'Grand Total',
                                      style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 8,
                                      ),
                                    ),
                                    pw.SizedBox(width: 5), // Adds some spacing

                                    pw.Container(
                                      height: 10,
                                      width: 10,
                                      color: PdfColors.white,
                                      child: pw.Image(image1),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          pw.Padding(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Center(
                                child: pw.Text(
                                  '${double.tryParse(widget.data['plan']['pay_amount'])?.ceil() ?? "0.00"}.00',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 8),
                                ),
                              )),
                        ]),
                        // Data Row
                      ],
                    ),
                    pw.Table(
                      border: pw.TableBorder.all(),
                      columnWidths: {
                        0: pw.FractionColumnWidth(0.14),
                        1: pw.FractionColumnWidth(0.14),
                        2: pw.FractionColumnWidth(0.14),
                        3: pw.FractionColumnWidth(0.14),
                        4: pw.FractionColumnWidth(0.14),
                        5: pw.FractionColumnWidth(0.14),
                        6: pw.FractionColumnWidth(0.17),
                      },
                      children: [
                        pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Center(
                                  child: pw.Text('Description',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold,
                                          fontSize: 6.sp))),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Center(
                                child: pw.Text('Taxable 5%',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 6.sp)),
                              ),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Text('Taxable 12%',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 6.sp)),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Center(
                                  child: pw.Text('Taxable 18%',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold,
                                          fontSize: 6.sp))),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Center(
                                  child: pw.Text('Taxable 28%',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold,
                                          fontSize: 6.sp))),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Center(
                                  child: pw.Text('Exempted',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold,
                                          fontSize: 8))),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Center(
                                  child: pw.Text('Round Off',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold,
                                          fontSize: 8))),
                            ),
                          ],
                        ),
                        // New row: Taxable Amt
                        pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Center(
                                child: pw.Text('Taxable Amt',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 6.sp)),
                              ),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Center(
                                  child: pw.Text('---',
                                      style: pw.TextStyle(fontSize: 8))),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Center(
                                  child: pw.Text('---',
                                      style: pw.TextStyle(fontSize: 8))),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Center(
                                  child: pw.Text(
                                      '${widget.data['plan']['price']}',
                                      style: pw.TextStyle(fontSize: 8))),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Center(
                                  child: pw.Text('---',
                                      style: pw.TextStyle(fontSize: 8))),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Center(
                                  child: pw.Text('---',
                                      style: pw.TextStyle(fontSize: 8))),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8.0),
                              child: pw.Center(
                                child: pw.Text(
                                  '${((double.tryParse(widget.data['plan']['pay_amount'])?.ceil() ?? 0) - (double.tryParse(widget.data['plan']['pay_amount']) ?? 0)).toStringAsFixed(2)}',
                                  style: pw.TextStyle(fontSize: 8),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // New row: IGSTpw.

                        if (widget.data['user']['state'] != 'Uttarakhand')
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: pw.EdgeInsets.all(8.0),
                                child: pw.Center(
                                  child: pw.Text('IGST',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold,
                                          fontSize: 6.sp)),
                                ),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(8.0),
                                child: pw.Center(
                                    child: pw.Text('0',
                                        style: pw.TextStyle(fontSize: 8))),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(8.0),
                                child: pw.Center(
                                    child: pw.Text('0',
                                        style: pw.TextStyle(fontSize: 8))),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(8.0),
                                child: pw.Center(
                                    child: pw.Text(
                                        '${widget.data['plan']['gst_amount']}',
                                        style: pw.TextStyle(fontSize: 8))),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(8.0),
                                child: pw.Center(
                                    child: pw.Text('0',
                                        style: pw.TextStyle(fontSize: 8))),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(8.0),
                                child: pw.Center(
                                    child: pw.Text('0.0',
                                        style: pw.TextStyle(fontSize: 8))),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(8.0),
                                child: pw.Center(
                                    child: pw.Text('0',
                                        style: pw.TextStyle(fontSize: 8))),
                              ),
                            ],
                          ),
                        if (widget.data['user']['state'] == 'Uttarakhand')
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: pw.EdgeInsets.all(8.0),
                                child: pw.Center(
                                  child: pw.Text('CGST',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold,
                                          fontSize: 6.sp)),
                                ),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(8.0),
                                child: pw.Center(
                                    child: pw.Text('0',
                                        style: pw.TextStyle(fontSize: 8))),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(8.0),
                                child: pw.Center(
                                    child: pw.Text('0',
                                        style: pw.TextStyle(fontSize: 8))),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(8.0),
                                child: pw.Center(
                                    child: pw.Text(
                                  () {
                                    try {
                                      return '${(double.parse(widget.data['plan']['gst_amount']) / 2).toStringAsFixed(2)}';
                                    } catch (e) {
                                      return 'Invalid amount';
                                    }
                                  }(),
                                  style: pw.TextStyle(fontSize: 8),
                                )),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(8.0),
                                child: pw.Center(
                                    child: pw.Text('0',
                                        style: pw.TextStyle(fontSize: 8))),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(8.0),
                                child: pw.Center(
                                    child: pw.Text('0.0',
                                        style: pw.TextStyle(fontSize: 8))),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(8.0),
                                child: pw.Center(
                                    child: pw.Text('0',
                                        style: pw.TextStyle(fontSize: 8))),
                              ),
                            ],
                          ),
                        if (widget.data['user']['state'] == 'Uttarakhand')
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: pw.EdgeInsets.all(8.0),
                                child: pw.Center(
                                  child: pw.Text('SGST',
                                      style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold,
                                          fontSize: 6.sp)),
                                ),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(8.0),
                                child: pw.Center(
                                    child: pw.Text('0',
                                        style: pw.TextStyle(fontSize: 8))),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(8.0),
                                child: pw.Center(
                                    child: pw.Text('0',
                                        style: pw.TextStyle(fontSize: 8))),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(8.0),
                                child: pw.Center(
                                    child: pw.Text(
                                  () {
                                    try {
                                      return '${(double.parse(widget.data['plan']['gst_amount']) / 2).toStringAsFixed(2)}';
                                    } catch (e) {
                                      return 'Invalid amount';
                                    }
                                  }(),
                                  style: pw.TextStyle(fontSize: 8),
                                )),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(8.0),
                                child: pw.Center(
                                    child: pw.Text('0',
                                        style: pw.TextStyle(fontSize: 8))),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(8.0),
                                child: pw.Center(
                                    child: pw.Text('0.0',
                                        style: pw.TextStyle(fontSize: 8))),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(8.0),
                                child: pw.Center(
                                    child: pw.Text('0',
                                        style: pw.TextStyle(fontSize: 8))),
                              ),
                            ],
                          ),
                      ],
                    ),
                    pw.Table(
                      border: pw.TableBorder.all(),
                      columnWidths: {
                        0: pw.FractionColumnWidth(1.01),
                      },
                      children: [
                        // Header Row

                        pw.TableRow(children: [
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Padding(
                                padding: pw.EdgeInsets.all(8.0),
                                child: pw.Text(
                                    '${'BANK: ${'CHAKRATA ROAD - DEHRADUN'}'}',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 6.sp)),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(8.0),
                                child: pw.Text('${'A/c: ${'094461900001172'}'}',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 6.sp)),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(8.0),
                                child: pw.Text(
                                    '${'IFSC CODE: ${'YESB0000944'}'}',
                                    style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                        fontSize: 6.sp)),
                              ),
                            ],
                          ),
                        ]),
                        // Data Row
                      ],
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'E & O.E.',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.normal, fontSize: 10.sp),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Terms and Conditions:',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 8.sp),
                    ),
                    pw.Text(
                      '1. Any cost arising from payment clearings or transaction charges are solely the responsibility of the client and will be charged as such.',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 6.sp),
                    ),
                    pw.Text(
                      '2. The recurring / renewal amount of the Package are subjected to change as per the market rates.',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 6.sp),
                    ),
                    pw.Text(
                      '3.'
                      ' All disputes are subject to Dehradun Jurisdiction.',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 6.sp),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(''),
                          pw.SizedBox(height: 10.sp),
                          pw.Text(''),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 15.sp),
                    pw.Align(
                      alignment: pw.Alignment.center,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(
                            'This is a Computer Generated Invoice. Signature Not Required.',
                            style: pw.TextStyle(
                              fontSize: 8.sp,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    // // Get the directory to store the file
    // final output = await getExternalStorageDirectory();
    // if (output == null) return;
    //
    // // Set the PDF file name
    // final filePath = '${output.path}/custom_pdf_name.pdf';
    //
    // // Write the PDF to the file
    // final file = File(filePath);
    // await file.writeAsBytes(await pdf.save());
    //
    // print('PDF saved at: $filePath');


    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async {
      return pdf.save();
    });
  }
}
