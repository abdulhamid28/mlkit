import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

late List<CameraDescription> cam_desc;
bool flag = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cam_desc = await availableCameras();
  } on CameraException catch (e) {}
  runApp(myApp());
}

class myApp extends StatefulWidget {
  const myApp({Key? key}) : super(key: key);
  @override
  State<myApp> createState() => _myAppState();
}

class _myAppState extends State<myApp> {
  // FOR LIVE CAMERA FOOTAGE
  late ImageLabelerOptions options;
  late CameraController controller;
  late final imageLabeler;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    options = ImageLabelerOptions(confidenceThreshold: 0.5);
    imageLabeler = ImageLabeler(options: options);

    controller = CameraController(cam_desc[0], ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      controller.startImageStream((image) => {
            if (flag == false)
              {
                img = image,
                flag = true,
                imagelabeling() // funtion called
              }
          });

      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            print('**ERROR**');
            break;
          default:
            // Handle other errors here.
            print('**ERROR**');
            break;
        }
      }
    });
  }

  late CameraImage? img;
  List<Container> list = [];

  InputImage cameraImageToInputImage() {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in img!.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();
    final Size imageSize = Size(img!.width.toDouble(), img!.height.toDouble());
    final camera = cam_desc[0];
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

  void imagelabeling() async {
    InputImage inputImaged = cameraImageToInputImage();
    final List<ImageLabel> labels =
        await imageLabeler.processImage(inputImaged);
    list = [];
    for (ImageLabel label in labels) {
      final String text = label.label;
      final double confidence = label.confidence;

      Container tnt = Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [Text(text), Text(confidence.toStringAsFixed(2))],
        ),
      );
      Duration duration = Duration(milliseconds: 200);
      Future.delayed(duration);
      flag = false;
      list.add(tnt);
    }
    setState(() {
      list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Container(
              height: 500,
              width: 500,
              child: CameraPreview(
                controller,
              ),
            ),
            SingleChildScrollView(
              child: Column(
                children: list,
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    super.dispose();
  }
}

// FOR PICKING AND CAPTURE
// File? image;
// ImagePicker picker = ImagePicker();
//
// void pickImage() async {
//   XFile? xfile = await picker.pickImage(source: ImageSource.gallery);
//   if (xfile != null) {
//     setState(() {
//       image = File(xfile.path);
//     });
//   }
// }
//
// void captureImage() async {
//   XFile? xfile = await picker.pickImage(source: ImageSource.camera);
//   if (xfile != null) {
//     setState(() {
//       image = File(xfile.path);
//     });
//   }
// }

// Center(
//   child: Column(
//     mainAxisAlignment: MainAxisAlignment.center,
//     children: [
//       image != null
//           ? Image.file(
//               image!,
//               height: 150,
//               width: 100,
//             )
//           : Icon(
//               Icons.image,
//               size: 100,
//             ),
//       ElevatedButton(
//           onPressed: () {
//             pickImage();
//           },
//           onLongPress: () {
//             captureImage();
//           },
//           child: Text('PRESS/LONG'))
//     ],
//   ),
// ),
