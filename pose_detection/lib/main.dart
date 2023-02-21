import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  dynamic _image;
  File? image;
  late final ImagePicker imagePicker;
  late final poseDetector;
  Size? size_image;
  late List<Pose> poses_outer;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imagePicker = ImagePicker();
    final options = PoseDetectorOptions(
        model: PoseDetectionModel.base, mode: PoseDetectionMode.single);
    poseDetector = PoseDetector(options: options);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Expanded(
              flex: 3,
              child: _image != null
                  ? Center(
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          width: size_image?.width,
                          height: size_image?.height,
                          child: CustomPaint(
                            size: Size.zero,
                            painter:
                                painting(poses: poses_outer, image: _image),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      child: Icon(
                        Icons.image,
                        size: 300,
                      ),
                    ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                child: Center(
                  child: ElevatedButton(
                      onPressed: pickImage,
                      onLongPress: captureImage,
                      child: Text('PRESS/LONG')),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void pickImage() async {
    print('*********entered pick image *********');
    XFile? xFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (xFile != null) {
      image = File(xFile.path);

      doPoseDetection();
    }
  }

  void captureImage() async {
    XFile? xFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (xFile != null) {
      image = File(xFile.path);
    }
    doPoseDetection();
  }

  void doPoseDetection() async {
    // print('*********entered do detection image*********');

    final InputImage inputImage = InputImage.fromFile(image!);
    //  print('*********entered do detection image0*********');

    final List<Pose> poses = await poseDetector.processImage(inputImage);
    //   print(poses.length);
    //    print('*********entered do detection image*********1');
    doPerfectImage();
    //    print('*********entered do detection image*********2');
    setState(() {
      poses_outer = poses;
    });

    //  print('*********entered do detection imagegg*********');
  }

  void doPerfectImage() async {
    //  print('*********entered perfect image************');

    _image = await image?.readAsBytes();
    var decodedImage = await decodeImageFromList(image!.readAsBytesSync());
    size_image =
        Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());
    _image = await decodeImageFromList(_image);
    setState(() {
      _image;
      print('set perfect  image');
    });
  }
}

class painting extends CustomPainter {
  dynamic image;
  List<Pose> poses;
  painting({required this.image, required this.poses});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.color = Colors.green;
    paint.strokeWidth = 4;
    paint.style = PaintingStyle.stroke;
    canvas.drawImage(image, Offset.zero, Paint());

    for (Pose pose in poses) {
      Map<PoseLandmarkType, PoseLandmark> poseLandMark = pose.landmarks;
      poseLandMark.forEach((key, value) {
        canvas.drawCircle(Offset(value.x, value.y), 1, paint);
      });

      canvas.drawLine(paintedline(PoseLandmarkType.leftElbow, pose),
          paintedline(PoseLandmarkType.leftWrist, pose), paint);
      canvas.drawLine(paintedline(PoseLandmarkType.leftElbow, pose),
          paintedline(PoseLandmarkType.leftShoulder, pose), paint);
      canvas.drawLine(paintedline(PoseLandmarkType.leftShoulder, pose),
          paintedline(PoseLandmarkType.leftHip, pose), paint);
      canvas.drawLine(paintedline(PoseLandmarkType.leftHip, pose),
          paintedline(PoseLandmarkType.leftKnee, pose), paint);
      canvas.drawLine(paintedline(PoseLandmarkType.leftAnkle, pose),
          paintedline(PoseLandmarkType.leftKnee, pose), paint);
      canvas.drawLine(paintedline(PoseLandmarkType.leftFootIndex, pose),
          paintedline(PoseLandmarkType.leftAnkle, pose), paint);

      canvas.drawLine(paintedline(PoseLandmarkType.rightElbow, pose),
          paintedline(PoseLandmarkType.rightWrist, pose), paint);
      canvas.drawLine(paintedline(PoseLandmarkType.rightElbow, pose),
          paintedline(PoseLandmarkType.rightShoulder, pose), paint);
      canvas.drawLine(paintedline(PoseLandmarkType.rightShoulder, pose),
          paintedline(PoseLandmarkType.rightHip, pose), paint);
      canvas.drawLine(paintedline(PoseLandmarkType.rightHip, pose),
          paintedline(PoseLandmarkType.rightKnee, pose), paint);
      canvas.drawLine(paintedline(PoseLandmarkType.rightAnkle, pose),
          paintedline(PoseLandmarkType.rightKnee, pose), paint);
      canvas.drawLine(paintedline(PoseLandmarkType.rightFootIndex, pose),
          paintedline(PoseLandmarkType.rightAnkle, pose), paint);
    }
  }

  Offset paintedline(PoseLandmarkType type1, Pose pos) {
    return Offset(pos.landmarks[type1]!.x, pos.landmarks[type1]!.y);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}
