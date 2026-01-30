import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../HexColorCode/HexColor.dart';

class  WhiteCircularProgressWidget extends StatelessWidget {
  const WhiteCircularProgressWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child:CupertinoActivityIndicator(
        radius: 20,
        color: HexColor('#0e4ccc'),
      ), // Show progress bar here
    );
  }
}
