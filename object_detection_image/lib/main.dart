import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  File? _image;
  dynamic image;
  late Size sizeSize;
  ImagePicker imagePicker = ImagePicker();
  late final objectDetector;
  late List<DetectedObject> objects;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // Use DetectionMode.single when processing a single image.
    final mode = DetectionMode.single;

// Options to configure the detector while using with base model.
    final options = ObjectDetectorOptions(
        mode: mode, multipleObjects: true, classifyObjects: true);

// // Options to configure the detector while using a local custom model.
//     final options = LocalObjectDetectorOptions(...);

// Options to configure the detector while using a Firebase model.
    //   final options = FirebaseObjectDetectorOptions(...);

    objectDetector = ObjectDetector(options: options);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              flex: 4,
              child: image != null
                  ? Center(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: sizeSize.width,
                          height: sizeSize.height,
                          child: CustomPaint(
                            size: Size.zero,
                            painter:
                                painting(imageFile1: image, objects: objects),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      child: Icon(
                        Icons.image,
                        size: 400,
                      ),
                    )),
          Expanded(
            flex: 1,
            child: Container(
              child: Center(
                child: ElevatedButton(
                  onPressed: pickImage,
                  onLongPress: captureImage,
                  child: Text('PRESS/LONG'),
                ),
              ),
            ),
          )
        ],
      )),
    );
  }

  void pickImage() async {
    XFile? xFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (xFile != null) {
      _image = File(xFile.path);
      doObjectDetection();
    }
    setState(() {
      image = null;
    });
  }

  void captureImage() async {
    XFile? xFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (xFile != null) {
      _image = File(xFile.path);
      doObjectDetection();
    }
  }

  doPerfectImage() async {
    var gg = await decodeImageFromList(_image!.readAsBytesSync());
    sizeSize = Size(gg.width.toDouble(), gg.height.toDouble());
    image = await _image?.readAsBytes();
    image = await decodeImageFromList(image);
    setState(() {
      image;
    });
  }

  doObjectDetection() async {
    InputImage inputImage = InputImage.fromFile(_image!);
    objects = await objectDetector.processImage(inputImage);

    for (DetectedObject detectedObject in objects) {
      final rect = detectedObject.boundingBox;
      final trackingId = detectedObject.trackingId;
    }

    doPerfectImage();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}

class painting extends CustomPainter {
  dynamic imageFile1;
  List<DetectedObject> objects;

  painting({required this.imageFile1, required this.objects});

  @override
  void paint(Canvas canvas, Size size) {
    Paint p = Paint();
    p.style = PaintingStyle.stroke;
    p.color = Colors.red;
    p.strokeWidth = 10;

    if (imageFile1 != null) {
      canvas.drawImage(imageFile1, Offset.zero, Paint());

      for (DetectedObject detectedObject in objects) {
        canvas.drawRect(detectedObject.boundingBox, p);
        dynamic list = detectedObject.labels;
        for (Label label in list) {
          TextSpan span = TextSpan(
              text: label.text,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ));
          TextPainter tp = TextPainter(
              text: span,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left);
          tp.layout();
          tp.paint(
              canvas,
              Offset(detectedObject.boundingBox.left,
                  detectedObject.boundingBox.top));
        }
      }
    }
  }

  @override
  bool shouldRepaint(painting oldDelegate) {
    return true;
    // oldDelegate.imageFile1 != imageFile1 ||
    //   oldDelegate.objects != objects;
  }
}
