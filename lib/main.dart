
import 'package:face_detection/face_detection_camera_screen.dart';
import 'package:face_detection/shape_painter.dart';
import 'package:face_detection/still_face_detection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';




Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();



  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ShapePainterScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}



