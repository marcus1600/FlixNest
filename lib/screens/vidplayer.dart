import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

/// Stateful widget to fetch and then display video content.
class VideoApp extends StatefulWidget {
  final File fileName;
  final String title;
  
  const VideoApp({super.key, required this.fileName, required this.title});
  @override
  _VideoAppState createState() => _VideoAppState();
}
class _VideoAppState extends State<VideoApp> {
  late VideoPlayerController _controller;
  bool horizontal = true;
  ChewieController? chewieController;
  @override
  void initState() {
    super.initState();
    // _controller = VideoPlayerController.file(widget.something)
    //   ..initialize().then((_) {
    //     // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
    //     setState(() {});
    //   });
    initPlayer(widget.fileName).then((value) {setState(() {
      chewieController=value;
    });});
  }

  Future<ChewieController> initPlayer(File file) async{
    _controller = VideoPlayerController.file(file);
    await _controller.initialize();

    return ChewieController(
      videoPlayerController: _controller,
      autoPlay: true,
      looping: true
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true, 
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: const Color.fromARGB(255, 0, 35, 65),
          title: Text("Video Player",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 23
            ),),),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              horizontal = !horizontal;
            });
          },
          child: 
          Stack(
            children:[
              Center(child: Icon(Icons.screen_rotation,color: Colors.black.withOpacity(.25),size: 30,)),
              Center(
                child: Text(
                  horizontal
                  ?"16:9"
                  :"9:16",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18
                  ),
                ),
              ),
            ]
          ),
        ),
        body: SafeArea(
          child: chewieController!=null
          ?Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[

                Container(
                  height: 
                  horizontal
                  ?MediaQuery.of(context).size.height/3
                  :MediaQuery.of(context).size.height/1.35,
                  child: Chewie(controller: chewieController!),color: Colors.black),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                  child: Text(widget.title,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 0, 35, 65),
                    fontSize: 26,
                    fontWeight: FontWeight.bold,

                  ),),
                ),
                Spacer()
              ]
            ),
          )
          :Center(child: CircularProgressIndicator()),
        ),
      );
  }
  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     home: Scaffold(
  //       body: Center(
  //         child: _controller.value.isInitialized
  //             ? AspectRatio(
  //                 aspectRatio: _controller.value.aspectRatio,
  //                 child: VideoPlayer(_controller),
  //               )
  //             : Container(),
  //       ),
  //       floatingActionButton: FloatingActionButton(
  //         onPressed: () {

  //           setState(() {
  //             _controller.value.isPlaying
  //                 ? _controller.pause()
  //                 : _controller.play();
  //           });
  //         },
  //         child: Icon(
  //           _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    chewieController!.dispose();

  }
}