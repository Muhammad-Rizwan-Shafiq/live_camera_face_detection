import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectionCameraScreen extends StatefulWidget {
  const FaceDetectionCameraScreen({Key? key}) : super(key: key);

  @override
  State<FaceDetectionCameraScreen> createState() => _FaceDetectionCameraScreenState();
}

class _FaceDetectionCameraScreenState extends State<FaceDetectionCameraScreen> {


  dynamic create() async{
    var a;
    await Future.delayed(Duration(seconds: 1));
    return a;
  }

  bool isBusy = false;
  FaceDetector? detector;
  Size? size;
  List<Face> faces=[];

  CameraLensDirection camDirec = CameraLensDirection.front;
  CameraImage? img;

  List<CameraDescription>? cameras; //list out the camera available
  CameraController? controller; //controller for camera
  XFile? image; //for caputred image

  @override
  void initState() {
    loadCamera();
    super.initState();
  }

  loadCamera() async {
    cameras = await availableCameras();
    if(cameras != null){
      controller = CameraController(cameras![1], ResolutionPreset.max);
      //cameras[0] = first camera, change to 1 to another camera
      detector = GoogleMlKit.vision.faceDetector();


      controller!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        controller?.startImageStream((image) => {
          if (!isBusy) {
            isBusy = true,
            img = image,
            doFaceDetectionOnFrame(image)}
        });
        setState(() {});
      });
    }else{
      print("NO any camera found");
    }
  }


  InputImage getInputImage(){

    final WriteBuffer allBytes = WriteBuffer();
    for (var plane in img!.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(img!.width.toDouble(), img!.height.toDouble());



    final planeData = img!.planes.map(
          (var plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: InputImageRotation.rotation0deg,
      inputImageFormat: InputImageFormat.nv21,
      planeData: planeData,
    );

    final inputImage = InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
    return inputImage;
  }

  //TODO face detection on a frame
  dynamic _scanResults;
  doFaceDetectionOnFrame(CameraImage img) async {
    InputImage inputImage = getInputImage();
    faces = await detector!.processImage(inputImage);


    setState(() {
      _scanResults = faces;
print("hogaya--------------->>>><>>><<>><>><><>><><><><><<><>><");


    });
  }


  //Show rectangles around detected faces
  Widget buildResult(){
    if (_scanResults == null ||
        controller == null ||
        !controller!.value.isInitialized) {
      return Text('');
    }

    final Size imageSize = Size(
      controller!.value.previewSize!.height,
      controller!.value.previewSize!.width,
    );
    isBusy = false;
    CustomPainter painter = FaceDetectorPainter(imageSize, _scanResults,camDirec);
    return CustomPaint(
      painter: painter,
    );
  }








  @override
  Widget build(BuildContext context) {
    List<Widget> stackChildren = [];
    size = MediaQuery.of(context).size;
    if(controller != null) {
      stackChildren.add(
       Stack(
         children: [
           CameraPreview(controller!),
           IgnorePointer(
             child: new ClipPath(
               clipper: new InvertedCircleClipper(),
               child: new Container(
                 color: new Color.fromRGBO(0, 0, 0, 0.5),
               ),
             ),
           )
         ],
       ),

      );


    }



    return Scaffold(
      appBar: AppBar(
        title: Text("Live Camera Preview"),
        backgroundColor: Colors.redAccent,
      ),
      body: Container(
          margin: EdgeInsets.only(top: 0),
          color: Colors.black,
          child: Stack(
            children: stackChildren,
          )),



    );
  }
}


class InvertedCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return new Path()
      ..addOval(new Rect.fromCircle(
          center: new Offset(size.width / 2, size.height / 2),
          radius: size.width * 0.45))
      ..addRect(new Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}


class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(this.absoluteImageSize, this.faces,this.camDire2);

  final Size absoluteImageSize;
  final List<Face> faces;
  CameraLensDirection camDire2;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;


    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.red;

    for (Face face in faces) {

      canvas.drawRect(
        Rect.fromLTRB(
          camDire2 == CameraLensDirection.front?(absoluteImageSize.width-face.boundingBox.right) * scaleX:face.boundingBox.left * scaleX,
          face.boundingBox.top * scaleY,
          camDire2 == CameraLensDirection.front?(absoluteImageSize.width-face.boundingBox.left) * scaleX:face.boundingBox.right * scaleX,
          face.boundingBox.bottom * scaleY,
        ),
        paint,
      );
    }

  }






  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.faces != faces;
  }}