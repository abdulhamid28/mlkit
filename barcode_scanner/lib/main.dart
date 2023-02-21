import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:camera/camera.dart';

late List<CameraDescription> cameras;
bool flag = false;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } catch (e) {}
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late CameraImage img;
  late CameraController cameraController;
  late final List<BarcodeFormat> formats;
  late final barcodeScanner;
  String type = '*';
  String value = '*';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    List<BarcodeFormat> formats = [BarcodeFormat.all];

    barcodeScanner = BarcodeScanner(formats: formats);
    cameraController = CameraController(cameras[0], ResolutionPreset.max);
    cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      cameraController.startImageStream((image) => {
            if (flag == false)
              {
                img = image,
                flag = true,
                barCodeDecoder(),
              }
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

  // void pickImage() async {
  //   ImagePicker imagePicker = ImagePicker();
  //   XFile? xfile = await imagePicker.pickImage(source: ImageSource.gallery);
  //   if (xfile != null) {
  //     image = File(xfile.path);
  //     inputImage = InputImage.fromFile(image!);
  //     barCodeDecoder();
  //     setState(() {
  //       image;
  //     });
  //   }
  // }

  void barCodeDecoder() async {
    InputImage inputImage = cameraImageToInputImage();

    final List<Barcode> barcodes =
        await barcodeScanner.processImage(inputImage);
    for (Barcode barcode in barcodes) {
      final BarcodeType type = barcode.type;
      BarcodeWifi barcodeWifi = barcode.value as BarcodeWifi;
      value = barcodeWifi.password!;
      if (value != null) {
        setState(() {
          value;
        });
      }
    }
    flag = false;
  }

  // void captureImage() async {
  //   ImagePicker imagePicker = ImagePicker();
  //   XFile? xfile = await imagePicker.pickImage(source: ImageSource.camera);
  //   if (xfile != null) {
  //     image = File(xfile.path);
  //     inputImage = InputImage.fromFile(image!);
  //     barCodeDecoder();
  //     setState(() {
  //       image;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Container(
            width: 350,
            height: double.maxFinite,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    height: 300,
                    width: 300,
                    child: CameraPreview(cameraController)),
                Text(value != null ? value : 'no output')
              ],
            ),
          ),
        ),
      ),
    );
  }
}
