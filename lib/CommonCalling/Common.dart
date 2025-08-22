import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Auth/auth_service.dart';

import '../HomePage/home_page.dart';
import '../LoginPage/login_page.dart';
import '../Utils/color.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CommonMethod {
  // logout
  Future<void> showProgressBar(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ColorSelect.buttonColor),
          ), // Progress bar widget
        );
      },
    );
  }

  // login
  Future<void> login(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ColorSelect.buttonColor),
          ),
        );
      },
    );
  }

  void _navigateToHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Homepage(initialIndex: 0)),
    );
  }
}
