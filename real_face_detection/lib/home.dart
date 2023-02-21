import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'main.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

bool flag = false;

class Home extends StatefulWidget {
  List<CameraDescription> cameras;
  Home({required this.cameras});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Face> faces = [];
  late CameraController cameraController;
  CameraImage? img;
  late final faceDetector;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final options = FaceDetectorOptions();
    faceDetector = FaceDetector(options: options);

    cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      cameraController.startImageStream((image) => {
            if (flag == false) {img = image, doFaceDection(), flag = true}
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
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            double sizedWidth = MediaQuery.of(context).size.width;
            double sizedHeight = MediaQuery.of(context).size.height;

            return Stack(
              children: [
                Positioned(
                    top: 0,
                    left: 0,
                    width: sizedWidth,
                    height: sizedHeight - 200,
                    child: SizedBox(child: CameraPreview(cameraController))),
                cameraController.value.isInitialized || faces.length == null
                    ? Positioned(
                        top: 0,
                        left: 0,
                        width: sizedWidth,
                        height: sizedHeight - 200,
                        child: SizedBox(
                          child: cameraController.value.isInitialized &&
                                  faces.length != 0
                              ? CustomPaint(
                                  painter: painting(
                                      cameraLensDirection:
                                          CameraLensDirection.back,
                                      faces: faces,
                                      camera_preview_size: Size(
                                          cameraController
                                              .value.previewSize!.width,
                                          cameraController
                                              .value.previewSize!.height)),
                                )
                              : null,
                        ))
                    : Container(),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    width: sizedWidth,
                    height: 200,
                    child: Container(
                      color: Colors.red,
                      width: 20,
                      height: 20,
                      child: RawMaterialButton(
                        // constraints: BoxConstraints(maxHeight: 10, maxWidth: 10),
                        shape: CircleBorder(),
                        fillColor: Colors.white,
                        onPressed: () {},
                        child: Icon(Icons.camera),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  doFaceDection() async {
    InputImage inputImage = cameraImageToInputImage();
    faces = await faceDetector.processImage(inputImage);
    print(faces.length);
    setState(() {
      faces;
    });
    flag = false;
  }

  InputImage cameraImageToInputImage() {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in img!.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();
    final Size imageSize = Size(img!.width.toDouble(), img!.height.toDouble());
    final camera = cameras[0];
    final imgRotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    final inputImageformat =
        InputImageFormatValue.fromRawValue(img!.format.raw);
    final planeData = img!.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
            bytesPerRow: plane.bytesPerRow,
            height: plane.height,
            width: plane.width);
      },
    ).toList();
    final inputImageData = InputImageData(
        size: imageSize,
        imageRotation: imgRotation!,
        inputImageFormat: inputImageformat!,
        planeData: planeData);
    final inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    return inputImage;
  }
}

class painting extends CustomPainter {
  CameraLensDirection cameraLensDirection;
  List<Face> faces;
  Size camera_preview_size;
  painting(
      {required this.cameraLensDirection,
      required this.faces,
      required this.camera_preview_size});

  @override
  void paint(Canvas canvas, Size size) {
    double ScaleX = size.width / camera_preview_size.width;
    double ScaleY = size.height / camera_preview_size.height;
    Paint p = Paint();
    p.style = PaintingStyle.stroke;
    p.color = Colors.red;
    p.strokeWidth = 2;
    for (Face face in faces) {
      canvas.drawRect(
          Rect.fromLTRB(
              (camera_preview_size.width - face.boundingBox.left) * ScaleX,
              face.boundingBox.top * ScaleY,
              (camera_preview_size.width - face.boundingBox.right) * ScaleX,
              face.boundingBox.bottom * ScaleY),
          p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    throw UnimplementedError();
  }
}
//
//   rotateCamera() {
//     if (cameraLensDirection == CameraLensDirection.back) {
//       cameraLensDirection = CameraLensDirection.front;
//       cameraController.pausePreview();
//
//       CameraController(widget.cameras[1], ResolutionPreset.medium);
//     } else {
//       cameraLensDirection = CameraLensDirection.back;
//       cameraController.pausePreview();
//
//       CameraController(widget.cameras[0], ResolutionPreset.medium);
//     }
//     cameraController.initialize();
//   }
// }
