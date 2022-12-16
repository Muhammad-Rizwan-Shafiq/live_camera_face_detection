import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class StillFaceDetection extends StatefulWidget {
  const StillFaceDetection({Key? key}) : super(key: key);

  @override
  State<StillFaceDetection> createState() => _StillFaceDetectionState();
}

class _StillFaceDetectionState extends State<StillFaceDetection> {
  List<CameraDescription>? cameras; //list out the camera available
  CameraController? controller; //controller for camera
  XFile? image;

  List<Face>? faces;
  var _image;
  FaceDetector? faceDetector;
  String result = '';

  @override
  void initState() {
    loadCamera();
    faceDetector = GoogleMlKit.vision.faceDetector(FaceDetectorOptions(
        enableClassification: true,
        minFaceSize: 0.1,
        performanceMode: FaceDetectorMode.fast),);
    super.initState();
  }

  loadCamera() async {
    cameras = await availableCameras();
    if (cameras != null) {
      controller = CameraController(cameras![1], ResolutionPreset.max);
      //cameras[0] = first camera, change to 1 to another camera

      controller!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    } else {
      print("NO any camera found");
    }
  }


  //TODO face detection code
  doFaceDetection() async {

    File file = File( image!.path );
    final inputImage = InputImage.fromFile(file);
    faces = await faceDetector!.processImage(inputImage);
    // print(faces!.length.toString()+"----------------------- faces found");

    if(faces!.length>0){

      if(faces![0].rightEyeOpenProbability! > 0.8 && faces![0].leftEyeOpenProbability! > 0.8) {
        setState(() {
          result= "Face found";
        });
      }



    }
    else{
      setState(() {
        result="No face found";
      });
    }


  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Live Camera Preview"),
        backgroundColor: Colors.redAccent,
      ),
      body: SingleChildScrollView(
        child: Container(
            child: Column(children: [
          controller == null
              ? Center(child: Text("Loading Camera..."))
              : !controller!.value.isInitialized
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Stack(
            alignment: Alignment.center,
                    children: [
                      CameraPreview(controller!),
                      Image.asset("assets/images/recog.png",height: 200,width: 200,fit: BoxFit.contain,),
                    ],
                  ),

          Text(result),
          Container(
            //show captured image
            padding: EdgeInsets.all(30),
            child: image == null
                ? Text("No image captured")
                : Image.file(
                    File(image!.path),
                    height: 300,
                  ),
            //display captured image
          )
        ])),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            if (controller != null) {
              //check if contrller is not null
              if (controller!.value.isInitialized) {
                //check if controller is initialized
                image = await controller!.takePicture();
                doFaceDetection();//capture image
                setState(() {
                  //update UI
                });

              }
            }
          } catch (e) {
            print(e); //show error
          }
        },
        child: Icon(Icons.camera),
      ),
    );
  }
}
