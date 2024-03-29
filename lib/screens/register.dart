import 'package:flixnest_v001/utilities/userDB.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:uuid/uuid.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController fullnameControler = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmpassController = TextEditingController();
  var uuid = const Uuid();
  
  var passVibility = false;

  @override
  void initState() {
    super.initState();
    passVibility = false;
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

  Future<void> _showMyDialog(BuildContext cont) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: const Text('Account Created!')),
          content: const SingleChildScrollView(
            child: Icon(Icons.check_circle_outline_outlined,color: Colors.green,size: 100,)
          ),
          actions: <Widget>[
            Center(
              child: TextButton(
                style: ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color>(Color.fromARGB(255, 0, 0, 0))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Text('Continue',style: TextStyle(color: Colors.white),),
                ),
                onPressed: () async{
                  await Future.delayed(const Duration(milliseconds: 100));
                  Navigator.of(context).pop();
                  Navigator.of(cont).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:SafeArea(
        child: Container(
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
                  Text("Registration",
                  style: TextStyle(
                    fontSize: 30
                  )),
                  Container(
                    height: 2,
                    width: MediaQuery.of(context).size.width/4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2000),
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color.fromARGB(255, 30, 229, 243),
                          Color.fromARGB(255, 18, 73, 255)]
                        )
                    ),
                  ),
                  SizedBox(height: 40,),
                  Container(
                    child: TextField(
                      textCapitalization: TextCapitalization.words,
                      controller: fullnameControler,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: InputDecoration(
                        hintText: "Enter your name",
                        labelText: "Full Name",
                        prefixIcon: Icon(Icons.person_outline_rounded),
                        border: OutlineInputBorder()
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  Container(
                    child: TextField(
                        maxLength: 16,
                      controller: usernameController,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: InputDecoration(
                        counterText: "Minimum 4 characters",
                        counterStyle: TextStyle(color: Colors.deepPurple,fontWeight: FontWeight.w500),
                        hintText: "Enter your Username",
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
                        counterText:"",
                        hintText: "Enter your password",
                        labelText: "Password",
                        prefixIcon: Icon(Icons.lock_person_outlined),
                        
                        border: OutlineInputBorder()
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  Container(
                    child: TextField(
                        maxLength: 16,
                        
                      controller: confirmpassController,
                      obscureText: passVibility
                      ?false
                      :true,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: InputDecoration(
                        counterText: "Minimum 6 characters",
                        counterStyle: TextStyle(color: Colors.deepPurple,fontWeight: FontWeight.w500),
                        hintText: "Enter your password",
                        labelText: "Confirm Password",
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
                      var tempID = uuid.v4();
                      var exists = false;
                      if(fullnameControler.text.trim().isEmpty||usernameController.text.trim().isEmpty||passwordController.text.trim().isEmpty||confirmpassController.text.trim().isEmpty){
                        showErrorMessage("Fields cannot be empty");
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
                          showErrorMessage("Username already taken");
                        }else{
                          if(usernameController.text.trim().length<4||passwordController.text.trim().length<6){
                            showErrorMessage("Invalid character requirements");
                          }else{
                            if(passwordController.text.trim()==confirmpassController.text.trim()){
                              UserDB().create(userID:tempID,fullName:  fullnameControler.text.trim(), userName: usernameController.text.trim(), password: passwordController.text.trim())
                              .then((value){UserDB().fetchByUserName(usernameController.text.trim()).then((value) {
                                _showMyDialog(context);
                              });});
                            }else{
                              showErrorMessage("Password fields need to match");
                            }

                          }
                          
                          
                        }
                        });
                        
                      }
                    }
                    ,
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
                        child: Text("REGISTER",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                        )),
                    ),
                    ),
                  ),
                  SizedBox(height: 25,),
                  
                  Divider(),
                  SizedBox(height: 5,),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account?",
                        style: TextStyle(
                          color: Colors.black54
                        ),),
                        SizedBox(width: 5,),
                        TextButton(
                          onPressed: ()async{
                            await Future.delayed(const Duration(milliseconds: 100));
                            Navigator.pop(context
                            );
                          },
                           child: Text("Login account"))
                      ],
                    ),
                  ),
                  const Spacer(flex: 3,),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}