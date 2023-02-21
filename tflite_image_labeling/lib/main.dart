import 'dart:io' as io;
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ImagePicker imagePicker = ImagePicker();
  io.File? image;
  String result = '';
  late final imageLabeler;
  late final modelPath;
  @override
  void initState() {
    createmodel();
  }

  void createmodel() async {
    modelPath = await _getModel('assets/ml/fruit.tflite');
    final options = LocalLabelerOptions(modelPath: modelPath);
    imageLabeler = ImageLabeler(options: options);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          child: Column(
            children: [
              Expanded(
                flex: 5,
                child: image != null
                    ? Container(
                        margin: EdgeInsets.all(20),
                        child: Image.file(image!),
                      )
                    : Container(
                        child: Icon(
                          Icons.image,
                          size: 250,
                        ),
                      ),
              ),
              Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: pickImage,
                    child: Text('PRESS'),
                  )),
              Expanded(
                flex: 4,
                child: Container(
                  child: Text(result),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void pickImage() async {
    XFile? xFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (xFile != null) {
      image = io.File(xFile.path);
    }
    doImageLabeling();
    setState(() {
      image;
    });
  }

  void doImageLabeling() async {
    InputImage inputImage = InputImage.fromFile(image!);
    final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);
    result = '';
    for (ImageLabel label in labels) {
      result = result + label.label + '\n';
    }
    setState(() {
      result;
    });
  }

  Future<String> _getModel(String assetPath) async {
    if (io.Platform.isAndroid) {
      return 'flutter_assets/$assetPath';
    }
    final path = '${(await getApplicationSupportDirectory()).path}/$assetPath';
    await io.Directory(dirname(path)).create(recursive: true);
    final file = io.File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(assetPath);
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return file.path;
  }
}
