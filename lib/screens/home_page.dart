import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

final firebaseAuthInstance = FirebaseAuth.instance;
final firebaseFirestore = FirebaseFirestore.instance;
final firebaseStoreinstance = FirebaseFirestore.instance;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _pickedFile;
  String _imageUrl = '';

  late FirebaseAuth auth;
  late FirebaseStorage firebaseStorage;

  @override
  void initState() {
    super.initState();
    _getUserImage();
    auth = FirebaseAuth.instance;
    firebaseStorage = FirebaseStorage.instance;
  }

  void _pickImage() async {
    final image = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50, maxWidth: 150);

    if (image != null) {
      setState(() {
        _pickedFile = File(image.path);
      });
    }
  }

  void _upload() async {
    final user = auth.currentUser;
    final storageRef =
        firebaseStorage.ref().child("images").child("${user!.uid}.jpg");

    await storageRef.putFile(_pickedFile!);

    final url = await storageRef.getDownloadURL();

    final document = firebaseFirestore.collection("users").doc(user!.uid);

    await document.update({"imageUrl": url});
  }

  void _getUserImage() async {
    print("GetUserImage");
    final user = firebaseAuthInstance.currentUser;
    final document = firebaseFirestore.collection("users").doc(user!.uid);
    final documentSnapshot = await document.get();

    setState(() {
      _imageUrl = documentSnapshot.get("imageUrl");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Firebase Denemesi"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("LoginPage"),
            SizedBox(
              height: 50,
            ),
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey,
              foregroundImage:
                  _pickedFile != null ? FileImage(_pickedFile!) : null,
            ),
            SizedBox(
              height: 50,
            ),
            TextButton(
                onPressed: () {
                  _pickImage();
                },
                child: const Text("Resim Seç")),
            SizedBox(
              height: 50,
            ),
            ElevatedButton(
                onPressed: () {
                  _upload();
                },
                child: const Text("Yükle")),
            SizedBox(
              height: 50,
            ),
            ElevatedButton(
                onPressed: () {
                  userSignOut();
                },
                child: Text("Çıkış yap")),
          ],
        ),
      ),
    );
  }

  void userSignOut() async {
    try {
      await FirebaseAuth.instance.signOut();

      print("Çıkış yapıldı.");
      /*      Navigator.of(context)
          .push(MaterialPageRoute(builder: (ctx) => LoginPageAnimate())); */ // StreamBuilder kontrol edip kullanıcı yoksa duruuma göre yön veriyor
    } catch (e) {
      print("Çıkış yaparken bir hata oluştu: $e");
    }
  }
}
