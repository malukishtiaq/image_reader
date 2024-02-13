import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _recognizedText;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Text Recognition Demo'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final image = await pickImage();
                        final extractedText = await extractTextFromImage(image);
                        setState(() {
                          _recognizedText = extractedText;
                        });
                      },
                      child: const Text('Image to Text'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () async {
                        final image = await pickImage();
                        final extractedEmails =
                            await extractEmailsFromImage(image);
                        setState(() {
                          _recognizedText = extractedEmails.join('\n');
                        });
                      },
                      child: const Text('Extract Emails'),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Text(_recognizedText ?? 'No text detected'),
                ElevatedButton(
                  onPressed: clearText,
                  child: const Text('Clear Text'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<XFile?> pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    return image;
  }

  Future<String> extractTextFromImage(XFile? image) async {
    if (image == null) return 'No image selected';
    final inputImage = InputImage.fromFilePath(image.path);
    final textDetector = GoogleMlKit.vision.textRecognizer();
    final RecognizedText recognizedText =
        await textDetector.processImage(inputImage);

    String allText = '';

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        allText += '${line.text}\n';
      }
    }

    textDetector.close();
    return allText;
  }

  Future<List<String>> extractEmailsFromImage(XFile? image) async {
    if (image == null) return ['No image selected'];
    final inputImage = InputImage.fromFilePath(image.path);
    final textDetector = GoogleMlKit.vision.textRecognizer();
    final RecognizedText recognizedText =
        await textDetector.processImage(inputImage);

    final emailRegExp = RegExp(r'\b[\w\.-]+@[\w\.-]+\.\w{2,4}\b');
    List<String> emails = [];

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        final emailMatches = emailRegExp.allMatches(line.text);
        for (var match in emailMatches) {
          emails.add(match.group(0)!);
        }
      }
    }

    textDetector.close();

    return emails.isEmpty ? ['No email addresses detected'] : emails;
  }

  void clearText() {
    setState(() {
      _recognizedText = null;
    });
  }
}
