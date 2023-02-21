import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

bool flag = false;

class Home extends StatefulWidget {
  List<CameraDescription> cameras;
  Home({required this.cameras});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late CameraController cameraController;
  List<DetectedObject> objects = [];
  CameraImage? img;
  late final objectDetector;
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    cameraController =
        CameraController(widget.cameras[0], ResolutionPreset.medium);
    cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      cameraController.startImageStream((image) => {
            if (flag == false) {img = image, doObjectDetection()}
          });
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });

    // Use DetectionMode.stream when processing camera feed.
// Use DetectionMode.single when processing a single image.
    final mode = DetectionMode.stream;

// Options to configure the detector while using with base model.
    final options = ObjectDetectorOptions(
      mode: mode,
      classifyObjects: true,
      multipleObjects: true,
    );

// // Options to configure the detector while using a local custom model.
//     final options = LocalObjectDetectorOptions(...);
//
// // Options to configure the detector while using a Firebase model.
//     final options = FirebaseObjectDetectorOptions(...);

    objectDetector = ObjectDetector(options: options);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(builder: (context1) {
          double screenWidth = MediaQuery.of(context1).size.width;
          double screenHeight = MediaQuery.of(context1).size.height;
          return Container(
            margin: const EdgeInsets.all(0),
            padding: const EdgeInsets.all(0),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    width: screenWidth,
                    height: screenHeight,
                    child: AspectRatio(
                        aspectRatio: cameraController.value.aspectRatio,
                        child: CameraPreview(cameraController)),
                  ),
                ),
                Positioned(top: 0, left: 0, child: customWidget())
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget customWidget() {
    Size myRequiredSize = Size(cameraController.value.previewSize!.width,
        cameraController.value.previewSize!.height);

    if (!cameraController.value.isInitialized || objects.length == 0) {
      return Text('');
    } else {
      return CustomPaint(
        painter: painting(objects1: objects, cameraSize: myRequiredSize),
      );
    }
  }

  void doObjectDetection() async {
    InputImage inputImage = cameraImageToInputImage();
    objects = await objectDetector.processImage(inputImage);
    print('lenght : ${objects.length}');
    setState(() {
      objects;
      flag = false;
    });
  }

  InputImage cameraImageToInputImage() {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in img!.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();
    final Size imageSize = Size(img!.width.toDouble(), img!.height.toDouble());
    final camera = widget.cameras[0];
    final imageRotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    // if (imageRotation == null) return;

    final inputImageFormat =
        InputImageFormatValue.fromRawValue(img!.format.raw);
    // if (inputImageFormat == null) return null;

    final planeData = img!.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation!,
      inputImageFormat: inputImageFormat!,
      planeData: planeData,
    );

    final inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    return inputImage;
  }
}

class painting extends CustomPainter {
  Size cameraSize;
  List<DetectedObject> objects1;

  painting({required this.objects1, required this.cameraSize});
  @override
  void paint(Canvas canvas, Size size) {
    print('after ${objects1.length}');
    double ScaleX = size.width / cameraSize.width;
    double ScaleY = size.height / cameraSize.height;
    Paint p = Paint();

    p.color = Colors.red;
    p.strokeWidth = 5;
    p.style = PaintingStyle.stroke;
    for (DetectedObject detectedObject in objects1) {
      print('after ${objects1.length}');
      List<Label> labels = detectedObject.labels;
      canvas.drawRect(
          Rect.fromLTRB(
              detectedObject.boundingBox.left * ScaleX,
              detectedObject.boundingBox.top * ScaleY,
              detectedObject.boundingBox.right * ScaleX,
              detectedObject.boundingBox.bottom * ScaleY),
          p);
      for (Label label in labels) {
        TextSpan span = TextSpan(
            text: '${label.text}',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ));
        TextPainter tp = TextPainter(
            text: span,
            textAlign: TextAlign.left,
            textDirection: TextDirection.ltr);
        tp.layout();
        tp.paint(
            canvas,
            Offset(detectedObject.boundingBox.left,
                detectedObject.boundingBox.top));
      }
    }
  }

  @override
  bool shouldRepaint(painting oldDelegate) {
    return true;
    // oldDelegate.cameraSize != cameraSize ||
    //   oldDelegate.objects != objects;
  }
}
