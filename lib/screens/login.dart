import 'dart:async';
import 'dart:io';
import 'package:flixnest_v001/screens/dashboard.dart';
import 'package:flixnest_v001/screens/register.dart';
import 'package:flixnest_v001/utilities/userDB.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  var passVibility = false;
  bool permissed = false; 

  @override
  void initState() {
    getPermission().then((value) {
      if(value.isGranted){
        setState(() {
          permissed = true;
        });
      }else{
        setState(() {
          permissed = false;
        });
      }
    });
    passVibility = false;
    super.initState();
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("DID CHANGE");
  }
  
  Future<PermissionStatus> getPermission() async {
    await Permission.storage.request();
    var status = await Permission.storage.status;
    return status;
  } 

  void showErrorMessage(String error){
    toastification.show(
      type: ToastificationType.error,
      style: ToastificationStyle.fillColored,
      context: context,
      title: Text(error),
      autoCloseDuration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:SafeArea(
        child: Stack(
          children:[
            Container(
            padding: const EdgeInsets.all(20),
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(), 
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/icon/flixnest_logo.png",
                          width: MediaQuery.of(context).size.width/1.25),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      child: TextField(
                        maxLength: 16,
                        controller: usernameController,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: InputDecoration(
                        counterText: "",
                          hintText: "Enter your username",
                          labelText: "Username",
                          prefixIcon: Icon(Icons.assignment_ind_outlined),
                          border: OutlineInputBorder()
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    Container(
                      child: TextField(
                        maxLength: 16,
                        controller: passwordController,
                        obscureText: passVibility
                        ?false
                        :true,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: InputDecoration(
                        counterText: "",
                          hintText: "Enter your password",
                          labelText: "Password",
                          prefixIcon: Icon(Icons.lock_person_outlined),
                          suffixIcon: IconButton(
                            onPressed: (){
                              setState(() {
                                passVibility = !passVibility;
                              });
                            }, 
                            icon: Icon(
                              passVibility
                              ?Icons.visibility
                              :Icons.visibility_off
                              )),
                          border: OutlineInputBorder()
                          
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 30,),
                    InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () async{
                        final SharedPreferences prefs = await _prefs;
                        var exists = false;
                        if(usernameController.text.trim().isEmpty||passwordController.text.trim().isEmpty){
                          showErrorMessage("Username or password field cannot be empty");
                        }else{
                          await UserDB().fetchAll().then((list){
                            for(var item in list){
                              if(item.userName==usernameController.text.trim()){
                                exists=true;
                                break;
                              }
                              else{
                                exists=false;
                              }
                            }
                            if(exists){
                              UserDB().fetchByUserName(usernameController.text.trim()).then((value) {
                                if(passwordController.text.trim() == value.password){
                                  prefs.setString("UID", value.userID.toString()).then((value) async{
                                    print("USERID: "+prefs.get("UID").toString());
                                    
                                    await Future.delayed(const Duration(milliseconds: 100));
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => const MainDash()),
                                    );
                                  });
                                }else{
                                  showErrorMessage("Incorrect password");
                                }
                              });
                            }else{
                              showErrorMessage("Account doesn't exist");
                            }
                          });
                        }
                        
                      },
                      child: Ink(
                        width: double.maxFinite,
                        height: 50,
                        decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color.fromARGB(255, 30, 229, 243),
                            Color.fromARGB(255, 18, 73, 255)]
                          )
                      ),
                        child: const Center(
                          child: Text("LOGIN",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                          )),
                      ),
                      ),
                    ),
                    SizedBox(height: 25,),
                    // Padding(
                    //   padding: const EdgeInsets.only(left: 7, right: 7),
                    //   child: Container(
                    //     decoration: BoxDecoration(
                    //       border: Border(bottom: BorderSide(width: .5,color: Colors.black54))
                    //     ),
                    //   ),
                    // ),
                    
                    Divider(),
                    SizedBox(height: 5,),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Not registered yet?",
                          style: TextStyle(
                            color: Colors.black54
                          ),),
                          SizedBox(width: 5,),
                          TextButton(
                            onPressed: ()async{
                              await Future.delayed(const Duration(milliseconds: 100));
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const RegisterPage()),
                              );
                            },
                             child: Text("Create an account"))
                        ],
                      ),
                    ),
                    const Spacer(flex: 3,),
                  ],
                ),
              ),
            ),
          ),
          permissed
          ?Container()
          :Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.75)
              ),
              child: Center(
          child: Container(
            padding: EdgeInsets.all(10),
            height: MediaQuery.of(context).size.height/3,
            width: MediaQuery.of(context).size.width/1.25,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Text("Permission(s) Required",
                style: TextStyle(
                  fontSize: 17.5,
                  fontWeight: FontWeight.bold,
                ),),
                Padding(
                  padding: const EdgeInsets.only(left: 5,right: 5),
                  child: Divider(),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(left: 5,right: 5),
                  child: Text("The application requires storage permissions to properly function.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16
                  ),),
                ),
                Spacer(flex: 3,),
                Divider(),
                IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(

                        child: Text("Exit"),
                        onPressed: (){
                          exit(0);
                      },),
                      VerticalDivider(color: Colors.grey,thickness: 1,),
                      TextButton(
                        child: Text("Open Settings"),
                        onPressed: ()async{
                          await openAppSettings();
                      },),
                    ],
                  ),
                )

              ],
            ),
          ),
        ),
            ),
          ]
        ),
      ),
    );
  }

  
  

}