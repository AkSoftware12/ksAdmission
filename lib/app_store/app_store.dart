import 'package:shared_preferences/shared_preferences.dart';

class AppStore{

  setUserToken(String value)async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString('user_token', value);
  }

  Future<String>getUserToken()async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? userToken = sp.getString('user_token');
    return userToken??"";
  }


  removeToken()async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.remove('user_token');
  }
}