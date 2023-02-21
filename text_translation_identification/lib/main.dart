import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController textEditingController = TextEditingController();
  late final modelManager;
  dynamic onDeviceTranslator;
  String result = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkTranslate();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          body: Container(
            color: Colors.white30,
            child: Column(
              children: [
                Container(
                  height: 60,
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: Card(
                          color: Colors.red,
                          child: Center(
                            child: Text(
                              'ENGLISH',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Card(
                          color: Colors.red,
                          child: Center(
                            child: Text(
                              'TAMIL',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  child: TextField(
                    controller: textEditingController,
                    maxLength: 100,
                    maxLines: 7,
                  ),
                ),
                Container(
                  height: 60,
                  child: GestureDetector(
                    onTap: translate,
                    child: Card(
                      color: Colors.red,
                      child: Center(
                        child: Text(
                          'TRANSLATE',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.maxFinite,
                    color: Colors.black,
                    child: Center(
                      child: Text(
                        result,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void checkTranslate() async {
    modelManager = OnDeviceTranslatorModelManager();
    print('**********entered checkstate *********');
    final bool isEnglishDownloaded =
        await modelManager.isModelDownloaded(TranslateLanguage.english.bcpCode);
    final bool isTamilDownloaded =
        await modelManager.isModelDownloaded(TranslateLanguage.tamil.bcpCode);

    if (!isEnglishDownloaded) {
      final bool english_package =
          await modelManager.downloadModel(TranslateLanguage.english.bcpCode);
    }
    if (!isTamilDownloaded) {
      final bool tamil_package =
          await modelManager.downloadModel(TranslateLanguage.tamil.bcpCode);
    }
    if (isEnglishDownloaded && isTamilDownloaded) {
      onDeviceTranslator = OnDeviceTranslator(
          sourceLanguage: TranslateLanguage.english,
          targetLanguage: TranslateLanguage.tamil);
    }
  }

  void translate() async {
    final String response =
        await onDeviceTranslator.translateText(textEditingController.text);
    print('**************************** $response********************');
    setState(() {
      result = response;
    });
  }
}
