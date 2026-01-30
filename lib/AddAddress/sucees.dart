import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../HomePage/home_page.dart';
import '../Themes/colors.dart';
import '../Utils/app_colors.dart';



class SuccesOrderPlaced extends StatelessWidget {
  const SuccesOrderPlaced({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body:
      SingleChildScrollView(
        child:
        Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(0.0),
              child: Center(
                child: Image.asset(
                  'assets/order_placed.jpeg',

                  alignment: Alignment.center,
                ),
              ),
            ),
            Text(
                'Your Order has been Successfully ',
                textAlign: TextAlign.center,
                style: Theme
                    .of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(  fontWeight: FontWeight.bold,fontSize: 35.sp, color: Colors.green,)
            ),
            SizedBox(
              height: 10.sp,
            ),
            Text(
              '\n\nThanks for choosing us for delivering your needs.'
                  // '\n\nYou can check your order status in my order section.'
                  '',
              textAlign: TextAlign.center,
              overflow: TextOverflow.fade,
              style: Theme
                  .of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(color: kDisabledColor),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0,vertical: 50),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ), backgroundColor: primaryColor,
                      padding: EdgeInsets.symmetric(
                          horizontal: 50, vertical: 20),
                      textStyle: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w400)),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(context,
                        MaterialPageRoute(builder: (context) {
                          return Homepage(initialIndex: 0,);
                        }), (Route<dynamic> route) => false);},

                  child: Text("Go To Home",style: TextStyle(color: Colors.white),)
              ),
            )
          ],
        ),
      ),
    );
  }

}

