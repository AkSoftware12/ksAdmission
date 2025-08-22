import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

class NEETCalendar extends StatefulWidget {
  const NEETCalendar({super.key});

  @override
  State<NEETCalendar> createState() => _NEETCalendarState();
}

class _NEETCalendarState extends State<NEETCalendar> {
  final List<String> daysOfWeek = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
  DateTime selectedDate = DateTime.now();
  List<dynamic> popups = [];
  DateTime? lastTap;

  @override
  void initState() {
    super.initState();
    _fetchPopups();
  }

  Future<void> _fetchPopups() async {
    try {
      final response = await http.get(Uri.parse('https://apiweb.ksadmission.in/api/popupimage'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          popups = data['popups'];
        });
        for (var popup in popups) {
          if (popup['image_urls'] != null) {
            precacheImage(NetworkImage(popup['image_urls']), context);
          }
        }
      } else {
        print('Failed to fetch popups: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching popups: $e');
    }
  }

  void _onDateTap(String imageUrl) {
    final now = DateTime.now();
    if (lastTap == null || now.difference(lastTap!).inMilliseconds > 500) {
      lastTap = now;
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(20),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.sp),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => Center(child: CircularProgressIndicator(
                      color: Colors.pink,
                    )),
                    errorWidget: (context, url, error) => Text('Failed to load image'),
                  ),
                ),
                Positioned(
                  top: 10.sp,
                  right: 10.sp,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: EdgeInsets.all(8.sp),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalDays = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;

    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            child: Opacity(
              opacity: 0.9,
              child: Image.asset(
                'assets/3.png',
                fit: BoxFit.fitHeight,
              ),
            ),
          ),
          Container(
            height: 100.sp,
            child: Center(
              child: Row(
                children: [
                  SizedBox(width: 20.sp),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back, size: 25.sp, color: Colors.black),
                  ),
                  SizedBox(width: 10.sp),
                ],
              ),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.yellow[700]!, width: 4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(Icons.arrow_back_ios, color: Colors.black),
                                onPressed: () {
                                  setState(() {
                                    selectedDate = DateTime(selectedDate.year, selectedDate.month - 1);
                                  });
                                },
                              ),
                              Text(
                                '${_getMonthName(selectedDate.month)} ${selectedDate.year}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.arrow_forward_ios, color: Colors.black),
                                onPressed: () {
                                  setState(() {
                                    selectedDate = DateTime(selectedDate.year, selectedDate.month + 1);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        Table(
                          border: TableBorder.all(color: Colors.grey),
                          children: [
                            TableRow(
                              children: daysOfWeek.map((day) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    day,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                                  ),
                                );
                              }).toList(),
                            ),
                            ..._buildCalendarRows(totalDays),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<TableRow> _buildCalendarRows(int totalDays) {
    List<TableRow> rows = [];
    DateTime firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    int startWeekday = firstDayOfMonth.weekday % 7;
    DateTime now = DateTime.now();

    List<Widget> cells = [];

    for (int i = 0; i < startWeekday; i++) {
      cells.add(const Padding(
        padding: EdgeInsets.all(8.0),
        child: SizedBox.shrink(),
      ));
    }

    for (int day = 1; day <= totalDays; day++) {
      DateTime thisDate = DateTime(selectedDate.year, selectedDate.month, day);
      bool isToday = thisDate.day == now.day &&
          thisDate.month == now.month &&
          thisDate.year == now.year;
      bool isFutureDate = thisDate.isAfter(DateTime(now.year, now.month, now.day));

      String? imageUrl;
      String formattedDate = '${thisDate.year}-${thisDate.month.toString().padLeft(2, '0')}-${thisDate.day.toString().padLeft(2, '0')}';
      var popup = popups.firstWhere(
            (popup) => popup['date'] == formattedDate,
        orElse: () => null,
      );
      if (popup != null) {
        imageUrl = popup['image_urls'];
      }

      Widget dateCell = Container(
        decoration: isToday
            ? BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8),
        )
            : null,
        child: Center(
          child: Text(
            day.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: isFutureDate
                  ? Colors.grey // Grey out future dates for visual feedback
                  : thisDate.weekday == DateTime.sunday
                  ? Colors.red
                  : Colors.black,
            ),
          ),
        ),
      );

      if (imageUrl != null && !isFutureDate) {
        dateCell = GestureDetector(
          onTap: () => _onDateTap(imageUrl!),
          child: dateCell,
        );
      }

      cells.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: dateCell,
      ));
    }

    while (cells.length % 7 != 0) {
      cells.add(const Padding(
        padding: EdgeInsets.all(8.0),
        child: SizedBox.shrink(),
      ));
    }

    for (int i = 0; i < cells.length; i += 7) {
      rows.add(TableRow(
        children: cells.sublist(i, i + 7),
      ));
    }

    return rows;
  }

  String _getMonthName(int month) {
    const List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}