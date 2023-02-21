import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:camera/camera.dart';

late List<CameraDescription> cameras ;
void main() async  {
  WidgetsFlutterBinding.ensureInitialized();
  try{
    cameras = await availableCameras();
  }catch(e){

  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  dynamic image;
  //File? _image;
  //ImagePicker imagePicker = ImagePicker();
  late final faceDetector;
  late List<Face> faces;
  // late int Width;
  // late int Height;
  CameraController cameraController = CameraController(cameras[0], ResolutionPreset.medium);

  @override
  void initState() {
    final options = FaceDetectorOptions();
    faceDetector = FaceDetector(options: options);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> stackChildren = [];
    stackChildren.add(
      Positioned(
          top: 0,
          left:0,
          width: ,
          child: CameraPreview(cameraController))
    );
    return MaterialApp(
        home: Scaffold(
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        child: Stack(
          children: stackChildren,
        ),
      ),
    ));
  }

  //face_detection_image(image: image, Width: Width, Height: Height, faces: faces),
  //
  // void PickImage() async {
  //   XFile? xFile = await imagePicker.pickImage(source: ImageSource.gallery);
  //   if (xFile != null) {
  //     _image = File(xFile.path);
  //     faceDetection();
  //     setState(() {
  //       image = null;
  //     });
  //   }
  // }
  //
  // void CaptureImage() async {
  //   XFile? xFile = await imagePicker.pickImage(source: ImageSource.camera);
  //
  //   if (xFile != null) {
  //     _image = File(xFile.path);
  //
  //     faceDetection();
  //   }
  // }

  // void faceDetection() async {
  //   final InputImage inputImage = InputImage.fromFile(_image!);
  //   faces = await faceDetector.processImage(inputImage);
  //   doRectanleBox();
  // }
  //
  // void doRectanleBox() async {
  //   image = await _image?.readAsBytes();
  //   var decodedImage = await decodeImageFromList(image);
  //
  //   image = await decodeImageFromList(image);
  //   Width = decodedImage.width;
  //   Height = decodedImage.height;
  //
  //   setState(() {
  //     image;
  //   });
  // }
}

// class face_detection_image extends StatelessWidget {
//   const face_detection_image({
//     super.key,
//     required this.image,
//     required this.Width,
//     required this.Height,
//     required this.faces,
//   });
//
//   final var image;
//   final int Width;
//   final int Height;
//   final List<Face> faces;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Container(
//               margin: EdgeInsets.only(top: 300),
//               child: image != null
//                   ? Center(
//                       child: FittedBox(
//                         fit: BoxFit.contain,
//                         child: SizedBox(
//                           width: Width.toDouble(),
//                           height: Height.toDouble(),
//                           child: CustomPaint(
//                             painter: painting(image: image, faces: faces),
//                           ),
//                         ),
//                       ),
//                     )
//                   : Center(
//                       child: Icon(
//                         Icons.image,
//                         size: 300,
//                       ),
//                     ),
//             ),
//             ElevatedButton(
//                 onPressed: PickImage,
//                 onLongPress: CaptureImage,
//                 child: Text('PRESS'))
//           ],
//         ),
//       ),
//     );
//   }
// }
// );

//
// class painting extends CustomPainter {
//   List<Face> faces;
//   dynamic image;
//
//   painting({required this.image, required this.faces});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint p = Paint();
//     p.strokeWidth = 1;
//     p.color = Colors.red;
//     p.style = PaintingStyle.stroke;
//     if (image != null) {
//       canvas.drawImage(image, Offset.zero, Paint());
//       for (Face face in faces) {
//         canvas.drawRect(face.boundingBox, p);
//       }
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     // TODO: implement shouldRepaint
//     throw UnimplementedError();
//   }
// }
