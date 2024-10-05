
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '';
import '../view/home_screen.dart';
import '../view/login_screen.dart';
import '../view/splash_screen.dart';
import '../view_model/login_provider.dart';
import 'name_routes.dart';

class Routes{

  static Route<dynamic> generateRoute(RouteSettings settings){

    switch(settings.name){

      case RouteName.splashScreen:
        return MaterialPageRoute(builder: (context)=> const SplashScreen());


      case RouteName.logInScreen:
        final args = settings.arguments as Map;
        return MaterialPageRoute(builder: (context)=>
            ChangeNotifierProvider(
                create: (BuildContext context) => LogInProvider(),
                child: LogInScreen(args:  args)));


      case RouteName.homepage:
        return MaterialPageRoute(builder: (context)=>  HomeScreen());



      default:
        return MaterialPageRoute(builder: (context){
          return const Scaffold(body: Center(child: Text("Something went wrong."),),);
        });
    }
  }
}

class SongsDeatilsList {
}