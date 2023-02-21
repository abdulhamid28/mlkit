import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

List<Container> list = [];
void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late InputImage inputImage;
  late final ImageLabelerOptions options;
  late final imageLabeler;

  File? image_path;
  ImagePicker imagePicker = ImagePicker();

  void galleryPick() async {
    XFile? xFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (xFile != null) {
      image_path = File(xFile.path);
      imageLabeling();
      setState(() {
        image_path;
      });
    }
  }

  void capturePick() async {
    XFile? xFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (xFile != null) {
      image_path = File(xFile.path);

      imageLabeling();
      setState(() {
        image_path;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    options = ImageLabelerOptions(confidenceThreshold: 0.5);
    imageLabeler = ImageLabeler(options: options);
  }

  void imageLabeling() async {
    inputImage = InputImage.fromFile(image_path!);
    final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);
    list = [];
    for (ImageLabel label in labels) {
      final String text = label.label;
      final int index = label.index;
      final double confidence = label.confidence;
      Container tnt = Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [Text(text), Text(confidence.toStringAsFixed(2))],
        ),
      );

      list.add(tnt);
    }
    setState(() {
      list;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Container> value = list;
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                image_path != null
                    ? Image.file(image_path!)
                    : Icon(
                        Icons.image,
                        size: 200,
                      ),
                ElevatedButton(
                  onPressed: galleryPick,
                  onLongPress: capturePick,
                  child: Text('PRESS/LONG'),
                ),
                Column(
                  children: list,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
