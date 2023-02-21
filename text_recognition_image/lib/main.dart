import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ImagePicker imagePicker = ImagePicker();
  File? image;
  String result = '';
  String retrivedData = '';

  late final TextRecognizer textRecognizer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
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
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    image != null
                        ? Expanded(
                            child: Container(
                              child: Image.file(image!),
                            ),
                          )
                        : Icon(
                            Icons.image,
                            size: 250,
                          ),
                    ElevatedButton(
                        onPressed: pickImage,
                        onLongPress: captureImage,
                        child: Text('PRESS /LONG'))
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Text(' Retrived Data : $retrivedData')),
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
      image = File(xFile.path);

      doTextRecognition();

      setState(() {
        image;
      });
    }
  }

  void captureImage() async {
    XFile? xFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (xFile != null) {
      image = File(xFile.path);
      doTextRecognition();
      setState(() {
        image;
      });
    }
  }

  void doTextRecognition() async {
    InputImage inputImage = InputImage.fromFile(image!);

    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);
    // result = recognizedText.text;
    // print('${result}');
    result = '';
    List<TextBlock> blocks = recognizedText.blocks;
    for (TextBlock block in blocks) {
      List<TextLine> lines = block.lines;
      for (TextLine line in lines) {
        List<TextElement> elements = line.elements;
        for (TextElement element in elements) {
          result = result + element.text;
          result = result + '\n';
        }
        result = result + '\n';
      }
      result = result + '\n';
    }
    print(result);
    setState(() {
      retrivedData = '${result}';
    });
  }
}
