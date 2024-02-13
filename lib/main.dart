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
  bool _isPickerActive = false;

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
                        if (image == null) return;
                        final extractedData =
                            await extractEmailsAndPhonesFromImage(image);
                        setState(() {
                          _recognizedText = extractedData.join('\n');
                        });
                      },
                      child: const Text('Extract Contacts'),
                    ),
                    const SizedBox(width: 5),
                    ElevatedButton(
                      onPressed: () async {
                        final image = await pickImage();
                        if (image == null) return;
                        final extractedEmails =
                            await extractEmailsFromImage(image);
                        setState(() {
                          _recognizedText = extractedEmails.join('\n');
                        });
                      },
                      child: const Text('Extract Emails'),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                ElevatedButton(
                  onPressed: () async {
                    final image = await pickImage();
                    if (image == null) return;
                    final extractedText = await extractTextFromImage(image);
                    setState(() {
                      _recognizedText = extractedText;
                    });
                  },
                  child: const Text('Image to Text'),
                ),
                const SizedBox(width: 5),
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
    if (_isPickerActive) return null;
    _isPickerActive = true;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    _isPickerActive = false;
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

  Future<List<String>> extractEmailsAndPhonesFromImage(XFile? image) async {
    if (image == null) return ['No image selected'];
    final inputImage = InputImage.fromFilePath(image.path);
    final textDetector = GoogleMlKit.vision.textRecognizer();
    final RecognizedText recognizedText =
        await textDetector.processImage(inputImage);

    final emailRegExp = RegExp(r'\b[\w\.-]+@[\w\.-]+\.\w{2,4}\b');
    final phoneRegExp = RegExp(r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b');
    List<String> contacts = [];

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        final emailMatches = emailRegExp.allMatches(line.text);
        final phoneMatches = phoneRegExp.allMatches(line.text);
        contacts.addAll(emailMatches.map((match) => match.group(0)!));
        contacts.addAll(phoneMatches.map((match) => match.group(0)!));
      }
    }

    textDetector.close();

    return contacts.isEmpty ? ['No contacts detected'] : contacts;
  }

  void clearText() {
    setState(() {
      _recognizedText = null;
    });
  }
}
