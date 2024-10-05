import 'package:flutter/cupertino.dart';

import '../app_store/app_store.dart';
import '../model/repository/repository.dart';
import '../routes/name_routes.dart';
import '../utils/common_toast.dart';


class LogInProvider with ChangeNotifier{
  final _appRepository = AppRepository();


  bool _isLoading = false;
  bool get isLoading => _isLoading;
  setLoading(bool value){
    _isLoading = value;
    notifyListeners();
  }

  Future<void> useLogIn(dynamic data, BuildContext context)async{
    setLoading(true);
    _appRepository.userLogIn(data).then((value){

      if(value['token'] ==''){
        // commonToast("Something went wrong");
      }else{
        Navigator.pushNamed(context, RouteName.homepage);
      }

      print(value['token']);
      AppStore().setUserToken(value['token']);
      setLoading(false);

    }).onError((error, stackTrace){
      commonToast("Something went wrong");
      print(error);
      setLoading(false);
    });
  }

}