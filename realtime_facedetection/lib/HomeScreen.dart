import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'main.dart';

bool flag = false;

class HomeScreen extends StatefulWidget {
  List<CameraDescription> cameras;
  HomeScreen({required this.cameras});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CameraImage? img;

  late CameraController cameraController;
  CameraDescription cameraDescription = cameras[0];
  CameraLensDirection cameraLensDirection = CameraLensDirection.back;
  late final faceDetector;
  List<Face> faces = [];
  //initstate

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    CameraInitialiser();
    final options = FaceDetectorOptions();
    faceDetector = FaceDetector(options: options);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(builder: (context) {
          double ActualScreenWidth = MediaQuery.of(context).size.width;
          double ActualScreenHeight = MediaQuery.of(context).size.height;
          return Stack(children: [
            Positioned(
              top: 0,
              left: 0,
              width: ActualScreenWidth,
              height: ActualScreenHeight - 200,
              child: AspectRatio(
                  aspectRatio: cameraController.value.aspectRatio,
                  child: CameraPreview(cameraController)),
            ),
            Positioned(
                top: 0,
                left: 0,
                width: ActualScreenWidth,
                height: ActualScreenHeight - 200,
                child: (!cameraController.value.isInitialized)
                    ? Container(child: Text('hii'))
                    : CustomPaint(
                        painter: painting(
                            cameraPreviewSize: Size(
                                cameraController.value.previewSize!.width,
                                cameraController.value.previewSize!.height),
                            faces: faces),
                      )),
            Positioned(
                bottom: 0,
                height: 200,
                width: ActualScreenWidth,
                child: FloatingActionButton(
                  onPressed: () {},
                  child: Icon(Icons.camera),
                ))
          ]);
        }),
      ),
    );
  }

  void CameraInitialiser() async {
    cameraController =
        CameraController(cameraDescription, ResolutionPreset.high);
    await cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      cameraController.startImageStream((image) => {
            if (flag == false) {flag = true, img = image, DoFaceDetection()}
          });
    });
  }

  void ChangeCameraDirection() async {
    if (cameraLensDirection == CameraLensDirection.back) {
      cameraLensDirection = CameraLensDirection.front;
      cameraDescription = cameras[1];
    } else {
      cameraLensDirection = CameraLensDirection.back;
      cameraDescription = cameras[0];
    }
    await cameraController.stopImageStream();
    await cameraController.dispose();

    setState(() {
      cameraController;
    });
    CameraInitialiser();
  }

  void DoFaceDetection() async {
    InputImage inputImage = getInputImage();
    faces = await faceDetector.processImage(inputImage);
    print(faces.length);
    setState(() {
      faces;
    });
    flag = false;
  }

  InputImage getInputImage() {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in img!.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();
    final Size imageSize = Size(img!.width.toDouble(), img!.height.toDouble());
    final camera = cameraDescription;
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
  List<Face> faces;
  Size cameraPreviewSize;

  painting({required this.faces, required this.cameraPreviewSize});

  @override
  void paint(Canvas canvas, Size size) {
    print('sorry');
    double ScaleX = size.width / cameraPreviewSize.width;
    double ScaleY = size.height / cameraPreviewSize.height;

    Paint p = Paint();
    p.strokeWidth = 2;
    p.color = Colors.red;
    p.style = PaintingStyle.stroke;

    for (Face face in faces) {
      canvas.drawRect(
          Rect.fromLTRB(
              face.boundingBox.left * ScaleX, // pakka

              face.boundingBox.top * ScaleY,
              (cameraPreviewSize.width * ScaleX) -
                  ((face.boundingBox.right) * ScaleX) - //pakka
                  face.boundingBox.left * ScaleX,
              (face.boundingBox.bottom * ScaleY)), //pakka
          p);
    }
  }

  @override
  bool shouldRepaint(painting oldDelegate) {
    return oldDelegate.cameraPreviewSize != cameraPreviewSize ||
        oldDelegate.faces != faces;
  }
}
