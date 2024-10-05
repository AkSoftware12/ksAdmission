import 'package:flutter/material.dart';

import '../app_store/app_store.dart';
import '../routes/name_routes.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String token="";

  _getToken(){
    AppStore().getUserToken().then((value){
      setState(() {token = value;});
      print("userToken: $token");
    });
  }

  @override
  void initState() {
    _getToken();
    Future.delayed(const Duration(seconds: 3),(){
      if(token ==""){
        Navigator.pushReplacementNamed(context, RouteName.logInScreen,
            arguments: {'title': 'LogIn'}
        );
      }else{
        Navigator.pushNamed(context, RouteName.homepage);
      }


    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Center(
        child: SizedBox(
          height: 200,width: 200,
          child: Image.asset("assets/splash_screen_image.png"),
        ),
      ),
    );
  }
}
