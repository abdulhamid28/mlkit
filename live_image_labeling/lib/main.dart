import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

late List<CameraDescription> cameras;

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

late CameraController cameraController;
@override
void initState() {
  cameraController = CameraController(cameras[0], ResolutionPreset.medium);
  cameraController.initialize().then((_) => {
  if (!mounted) {
      return;
  }
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
class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
