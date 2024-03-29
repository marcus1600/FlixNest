// ignore_for_file: must_be_immutable

import 'package:flixnest_v001/screens/dashboard.dart';
import 'package:flixnest_v001/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const FlNest(),
    );
  }
}

class FlNest extends StatefulWidget {
  const FlNest({super.key});

  @override
  State<FlNest> createState() => _FlNestState();
}

class _FlNestState extends State<FlNest> {
  
  String? UID;
  @override
  void initState() {
    super.initState();
    getPrefs().then((value) {
      setState(() {
        UID = value.getString("UID").toString();
        
        print("STARTED  :"+UID!);
      });
    });
  }
  

  Future<SharedPreferences> getPrefs()async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs;
  }

  @override
  Widget build(BuildContext context) {
    
    return 
    UID == "null"
    ?LoginPage()
    :MainDash();
    
    // return const StorageDenied();
  }
}

