import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseInitializer().initialize();
  runApp(const MyApp());
}

class FirebaseInitializer {
  static final FirebaseInitializer _instance = FirebaseInitializer._internal();

  factory FirebaseInitializer() {
    return _instance;
  }

  FirebaseInitializer._internal();

  Future<void> initialize() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyCupZIwdmDUPZxmhBq7oNT3S2AB9Pb7zew',
          appId: '1:469675020584:ios:1c94087aec0e28c9a6401d',
          messagingSenderId: '469675020584',
          projectId: 'testing-5aefe',
          storageBucket: "testing-5aefe.appspot.com",
        ),
      );
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: UploadImage(),
    );
  }
}

class UploadImage extends StatefulWidget {
  const UploadImage({super.key});

  @override
  State<UploadImage> createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage> {
  final ImagePicker _imagePicker = ImagePicker();
  String? imageUrl;

  Future<void> pickImage() async {
    try {
      XFile? res = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (res != null) {
        File imageFile = File(res.path);
        print(imageFile);
        await uploadImageToFirebase(imageFile);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to upload image: $e'),
        ),
      );
    }
  }

  Future<void> uploadImageToFirebase(File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;
      Reference storageRef =
          FirebaseStorage.instance.ref().child('uploads/$fileName');
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      setState(() {
        imageUrl = downloadUrl;
      });
      print('Image URL: $imageUrl');
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error uploading image: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Image'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: pickImage,
              child: Text('Pick and Upload Image'),
            ),
            imageUrl != null ? Image.network(imageUrl!) : Container(),
          ],
        ),
      ),
    );
  }
}
