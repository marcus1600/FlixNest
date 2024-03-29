import 'dart:io';

import 'package:flixnest_v001/screens/login.dart';
import 'package:flixnest_v001/screens/vidplayer.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:toastification/toastification.dart';
import 'package:path/path.dart' as Path;

class MainDash extends StatefulWidget {
  const MainDash({super.key});

  @override
  State<MainDash> createState() => _MainDashState();
}

class _MainDashState extends State<MainDash> {
  File? vid;
  Map filesList  = {};
  bool showUpload = false;
  TextEditingController fileNameController = TextEditingController();
  VideoPlayerController? _videoController;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  
  @override
  void initState() {
    fileNameController.addListener(_listener);
    getPreferences(_prefs).then((value) {
      getItems(value.getString("UID")!).then((value) {
        setState(() {
          // filesList = value;
          for(var items in value){
            filesList.addAll({items:false});
          }
        });
      });
    },);
    showUpload = false;
    super.initState();
  }

  @override dispose(){
    if(_videoController!=null){
      _videoController!.dispose();
    }
    super.dispose();
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

  void showSuccessMessage(String msg){
    toastification.show(
      type: ToastificationType.success,
      style: ToastificationStyle.fillColored,
      context: context,
      title: Text(msg),
      autoCloseDuration: const Duration(seconds: 3),
    );
  }

  

  Future<SharedPreferences> getPreferences(Future<SharedPreferences> prefs) async{

    var pref = await prefs;
    return pref;
  } 

  Future pickVideo() async{
    final vid = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if(vid == null){
      return;
    }
    final imageTemporary = File(vid.path);
    this.vid = imageTemporary;
  }

  Future saveVideo(File? file,String userID,String fileName)async{
    await saveVideoPermanently(file!.path ,userID,fileName).then((value) {
      setState(() {
        getItems(userID).then((value) {
          setState(() {
            filesList.clear();
            for(var items in value){
              filesList.addAll({items:false});
            }
          });
        });
        this.vid = value; 
      });
    });
  }
  
  
  Future<File> saveVideoPermanently(String videoPath,String folderName,String fileName) async{
    final directory = await getApplicationDocumentsDirectory();
    final name = fileName+".mp4";
    final pathCheck = Directory('${directory.path}/$folderName/');
    // print("ITEMS: "+pathCheck.list().length.toString());
    if ((await pathCheck.exists())) {

    } else {
      pathCheck.create();
    }
    final video = File('${directory.path}/$folderName/$name');
    print("THIS IS THE PATH::"+video.path.toString());
    return File(videoPath).copy(video.path);
  }

  Future<List<FileSystemEntity>> getItems(String folderName)async{
    final directory = await getApplicationDocumentsDirectory();
    final pathCheck = Directory('${directory.path}/$folderName/');
    print(pathCheck.list().toList().then((value) {print(value.length.toString());}));
    return pathCheck.listSync();
  }

  Widget videoCard(File file,BuildContext cont,bool expand){
    return Padding(
      padding: const EdgeInsets.fromLTRB(8,4,8,4),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        height: expand
        ?170
        :100,
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      filesList[file] = !expand;
                    });
                    print(file.toString());
                              
                  },
                  child: Ink(
                    height: 100,
                    width: MediaQuery.of(cont).size.width/1.1,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black87,width: .25),
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: Row(
                      children: [
                        Container(
                        width: 100,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color.fromARGB(80, 30, 229, 243),
                              Color.fromARGB(118, 18, 73, 255)
                            ]
                            ),
                          borderRadius: BorderRadius.circular(5)
                        ),
                        child: Center(
                          child: Icon(Icons.video_camera_back_rounded
                          ,size: 75,color: Colors.white,),
                        ),
                        ),
                        Spacer(),
                        Container(
                          height: 100,
                          child: Column(
                            children: [
                              Spacer(),
                              Container(
                                width: 200,
                                child: Center(
                                  child: Text(Path.basename(file.toString().substring(0, file.toString().length-5)),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18.5,
                                    fontWeight: FontWeight.bold
                                  ),),
                                ),
                              ),
                              Spacer()
                      
                            ],
                          ),
                        ),
                        Spacer(),
                  
                  
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.vertical(
                        bottom: Radius.circular(10)),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black,
                              offset: Offset(-.25, .25),
                              spreadRadius: 0,
                              blurRadius: 0),
                          BoxShadow(
                              color: Colors.black,
                              offset: Offset(.25, .25),
                              spreadRadius: 0,
                              blurRadius: 0)
                        ]),
                      height: 65,
                      width: 125,
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Row(
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: 
                                () async{
                                  await Future.delayed(const Duration(milliseconds: 100));
                                  Navigator.push(
                                    cont,
                                    MaterialPageRoute(builder: (cont) =>  VideoApp(title: Path.basename(file.toString().substring(0, file.toString().length-5)),fileName: file,)),
                                  );
                                  
                                },
                                child: Ink(
                                  height: 55,
                                  width: 55,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.green
                                  ),
                                  child: Center(
                                    child: Icon(Icons.play_arrow,color: Colors.white,size: 40,),
                                  ),
                                ),
                              ),
                            ),
                            Spacer(),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: 
                                () {
                                  deleteDialog(file);
                                  // file.delete().then((value){
                                  //   getPreferences(_prefs).then((value) {
                                  //   getItems(value.getString("UID")!).then((value) {
                                  //     setState(() {
                                  //       filesList.clear();
                                  //       for(var items in value){
                                  //         filesList.addAll({items:false});
                                  //       }
                                  //     });
                                  //   });
                                  // },);
                                  // });
                                },
                                child: Ink(
                                  height: 55,
                                  width: 55,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.red
                                  ),
                                  child: Center(
                                    child: Icon(Icons.delete,color: Colors.white,size: 40,),
                                  ),
                                ),
                              ),
                            ),
                        
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> deleteDialog(File file) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.center,
          title: Center(child: const Text('Are you sure you want to delete this video?',textAlign: TextAlign.center,)),
          content: const SingleChildScrollView(
            child: Center(child: Text("This will remove the video from your movie library. You cannot undo this action.",textAlign: TextAlign.center,))
          ),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color>(Color.fromARGB(255, 71, 71, 71))),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Text('Cancel',style: TextStyle(color: Colors.white),),
              ),
              onPressed: () async{
                await Future.delayed(const Duration(milliseconds: 100));
                Navigator.of(context).pop();
              },
            ),
            Spacer(),
            TextButton(
              style: ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color>(Color.fromARGB(255, 255, 0, 0))),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Text('Confirm',style: TextStyle(color: Colors.white),),
              ),
              onPressed: () async{
                file.delete().then((value) async{
                await Future.delayed(const Duration(milliseconds: 100));
                Navigator.of(context).pop();
                  getPreferences(_prefs).then((value) {
                  getItems(value.getString("UID")!).then((value) {
                    setState(() {
                      filesList.clear();
                      for(var items in value){
                        filesList.addAll({items:false});
                      }
                    });
                    showSuccessMessage("Successfully deleted video");
                    
                  });
                },);
                });
              },
            ),
          ],
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.black,
          title: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text("Movie Library",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 23
            ),),
        ),),
        endDrawer: Drawer(
          child: ListView(
            children: [
              DrawerHeader(
                child: Image.asset("assets/icon/flixnest_logo.png",
                  width: MediaQuery.of(context).size.width/3.5,),
                ),
                ListTile(

                  title:  Text('Sign Out',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.w400
                  ),),
                  onTap: () async{
                    var pref = await _prefs;
                    pref.clear();
                    await Future.delayed(const Duration(milliseconds: 100));
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                ),
              
            ],
          ),
      
        ),
        floatingActionButton: FloatingActionButton( 
          child: AnimatedContainer(
            duration: Duration(
              milliseconds: 200,
            ),
            child: !showUpload
            ?Icon(Icons.add)
            :Icon(Icons.close_rounded),
          ),
          onPressed: (){
          // pickVideo().then((value) {setState(() {
          //   print(vid.toString());
          // });});
          setState(() {
            showUpload=!showUpload;
            this.vid = null;
            fileNameController.text = "";
            _videoController = null;
          });
        }),
        body: 
        Stack(
          children: [
            filesList.keys.isEmpty
            ?SafeArea(
              child: Column(
                children: [
                      SizedBox(height: 20),
                      Spacer(flex: 2,),
                      Center(
                        child: Text(
                          textAlign: TextAlign.center,
                          "YOU HAVE NO VIDEO FILES IN YOUR LIBRARY",
                          style: TextStyle(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 24
                      ),
                        ),
                      ),
                      Spacer(flex: 3,),
                ],
              ),
            )
            :SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      for(var items in filesList.keys)
                      videoCard(items,context,filesList[items]),
                      // Text(filesList[i].toString())
                      Container(
                      color: Colors.white,
                      height: 80,
                      // width: MediaQuery.of(cont).size.width/1.2,
                    ),
                    ],
                  ),
                ),
              ),
            ),
          showUpload
          ?Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.75)
            ),
            child: Center(
              child: Container(
                padding: EdgeInsets.all(10),
                height: MediaQuery.of(context).size.height/2,
                width: MediaQuery.of(context).size.width/1.25,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width/1.5,
                      child: TextField(
                        controller: fileNameController,
                        readOnly: 
                        vid == null
                        ?true
                        :false,
                        decoration: InputDecoration(
                          hintText: "Title",
                          contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                          suffixText: ".mp4"
                        ),
                      ),
                    ),
                    Container(
                      child: 
                      _videoController != null
                      ?Stack(
                        children:[ 
                          Container(
                            height: MediaQuery.of(context).size.height/4,
                            width: MediaQuery.of(context).size.width/1.5,
                            child: VideoPlayer(_videoController!),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () { 
                                pickVideo().then((value) {
                                setState(() {
                                  print("LUNES:"+vid.toString());
                                  fileNameController.text = Path.basename(vid.toString().replaceAll(".mp4'", '').trim());
                                  _videoController = VideoPlayerController.file(vid!
                                  )
                                  ..initialize().then((_) {
                                    setState(() {});  //when your thumbnail will show.
                                  });
                                });});
                              },
                              child: Ink(
                                height: MediaQuery.of(context).size.height/4,
                                width: MediaQuery.of(context).size.width/1.5,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(.35)
                                ),
                                child: Icon(Icons.fingerprint_sharp,
                                size: 50,
                                color:Colors.white.withOpacity(.5),),
                              ),
                            ),
                          ),
                        ]
                      )
                      :Material(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () {
                            pickVideo().then((value) {
                              setState(() {
                                print("LUNES:"+vid.toString());
                                fileNameController.text = Path.basename(vid.toString().replaceAll(".mp4'", '').trim());
                                _videoController = VideoPlayerController.file(vid!
                                )
                                ..initialize().then((_) {
                                  setState(() {});  //when your thumbnail will show.
                                });
                              });});
                          },
                          child: Ink(
                            decoration: BoxDecoration(
                              
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(15),
                            ),
                            height: 
                            MediaQuery.of(context).size.height/4,
                            width: MediaQuery.of(context).size.width/1.5,
                            child: Center(
                              child: Stack(
                                children: [
                                  Center(child: Icon(Icons.fingerprint_sharp,
                                size: 50,
                                color:Colors.black.withOpacity(.5),),),
                                  Center(
                                    child: Text(
                                      "Choose a video"
                                      ,style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16
                                      ),
                                    ),
                                  ),
                                ]
                              ),
                            ),
                          ),
                        ),
                      )
                    ),
                    ElevatedButton(
                      onPressed: 
                      vid==null || fileNameController.text.isEmpty
                      ?null
                      :()async{
                        bool exists = false;
                        for(var item in filesList.keys){
                          if(fileNameController.text == Path.basename(item.toString().replaceAll(".mp4'", '').trim())){
                            exists = true;
                            break;
                          }else{
                            exists = false;
                          }
                        }
                        if(exists){
                          showErrorMessage("Video name already exists");
                        }else{
                          await _prefs.then((value){
                            saveVideo(vid,value.getString("UID")!,fileNameController.text)
                          .then((value) async{
                            Future.delayed(Duration(milliseconds: 100),);
                            setState(() {
                              showUpload=!showUpload;
                              this.vid = null;
                              fileNameController.text = "";
                              _videoController = null;
                            });
                            showSuccessMessage("Successfully added video to library");
                          });
                          });

                        }
                        
                      },
                     child:Text("Upload"))
      
                  ],
                ),
              ),
            ),
          )
          :Container()
        ],)
        
      ),
    );
  }
  _listener(){

    if(fileNameController.text.isEmpty){
      print("EMPTY");
      setState(() {
        
      });
    }else{
      setState(() {
        
      });
    }
}
  

  
}