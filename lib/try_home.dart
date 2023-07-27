import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tflite/flutter_tflite.dart';

class TryHome extends StatefulWidget {
  const TryHome({super.key});

  @override
  State<TryHome> createState() => _TryHomeState();
}

class _TryHomeState extends State<TryHome> {
  late File imageFile;

  /// Get from Camera
  _getFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
    detect_image(imageFile);
  }

  /// Get from gallery
  _getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
    detect_image(imageFile);
  }

  void initState() {
    super.initState();
    loadmodel();
  }

  detect_image(File image) async {
    var prediction = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 4,
        threshold: 0.01,
        imageMean: 127.5,
        imageStd: 127.5);

    setState(() {
      _loading = false;
      _predictions = prediction!;
      print(_predictions);
    });
  }

  bool _loading = true;
  final imagePicker = ImagePicker();
  List _predictions = [];

  loadmodel() async {
    await Tflite.loadModel(
        model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
  }

  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 300,
            decoration:
                const BoxDecoration(color: Color.fromARGB(255, 243, 241, 241)),
            width: double.infinity,
            child: Image.asset(
              'assets/mask.png',width: size.width*0.01,
              color: Colors.red,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "Try our Face Mask Detection model",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () {
              _getFromGallery();
            },
            child: Container(
              height: 50,
              width: 300,
              decoration: const BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: const Center(
                  child: Text(
                'Check with Image',
                style: TextStyle(color: Colors.white),
              )),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          GestureDetector(
            onTap: () {
              _getFromCamera();
            },
            child: Container(
              height: 50,
              width: 300,
              decoration: const BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: const Center(
                  child: Text(
                'Check with Camera',
                style: TextStyle(color: Colors.white),
              )),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          _loading == false
              ? Column(
                  children: [
                    SizedBox(
                      height: 250,
                      width: 250,
                      child: Image.file(imageFile),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      _predictions[0]['label'].toString().substring(1),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text('Confidence ${_predictions[0]['confidence'].toString().substring(2, 4)}%'),
                  ],
                )
              : const Icon(Icons.error_outline),
        ],
      ),
    );
  }
}
