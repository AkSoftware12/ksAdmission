import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_store/app_store.dart';
import '../model/services/api_response.dart';
import '../routes/name_routes.dart';
import '../utils/app_colors.dart';
import '../view_model/user_list_provider.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  UserListProvider userListProvider = UserListProvider();

  @override
  void initState() {
    userListProvider.fetchUserList();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: primaryColor,
        title: Text("Home Screen", style: TextStyle(color: whiteColor)),
        actions: [
          IconButton(onPressed: (){
            AppStore().removeToken();
            Navigator.pushReplacementNamed(context, RouteName.logInScreen,
                arguments: {'title': 'LogIn'}
            );
          },
              icon: Icon(Icons.logout, color: whiteColor,))
        ],
      ),

      body: ChangeNotifierProvider(
          create: (BuildContext context)=> userListProvider,
      child: Consumer<UserListProvider>(builder: (context, value, _){
        switch(value.userList.status){

          case Status.loading:
            return Center(child: CircularProgressIndicator(color: primaryColor,),);
          case Status.error:
            return Center(child: Text(value.userList.message.toString()),);

          case Status.complete:
            return ListView.builder(
              itemCount: value.userList.data!.data!.length,
                itemBuilder: (context, index){
                final data = value.userList.data!.data![index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(data.avatar.toString()),
                    ),
                    title: Text(data.firstName.toString()),
                    subtitle: Text(data.email.toString()),
                  ),
                );
                });

          default:
        }
        return const SizedBox();
      }),
      ),
    );
  }
}
