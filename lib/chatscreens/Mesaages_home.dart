import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

final firebaseAuthInstance = FirebaseAuth.instance;
final firebaseStorageInstance = FirebaseStorage.instance;
final firebaseFireStore = FirebaseFirestore.instance;
final fcm = FirebaseMessaging.instance;

class MessagesHomePage extends StatefulWidget {
  const MessagesHomePage({super.key});

  @override
  State<MessagesHomePage> createState() => _HomeState();
}

class _HomeState extends State<MessagesHomePage> {
  final _nameController = TextEditingController();
  final userGlobal = firebaseAuthInstance.currentUser;

  File? _pickedFile;
  String _imageUrl = '';
  String mesaj = 'defaultMesage';

  @override
  void initState() {
    requestNotificationPermission();
    _getMessage();
    super.initState();
  }

  void requestNotificationPermission() async {
    NotificationSettings notificationSetting = await fcm.requestPermission();

    String? token = await fcm.getToken();

    print("TOKENNNNNNN");
    print(token);
  }

  void _getMessage() async {
    try {
      final user = firebaseAuthInstance.currentUser;
      if (user != null) {
        final document = firebaseFireStore.collection("messages").doc(user.uid);
        final documentSnapshot = await document.get();

        mesaj = documentSnapshot.get("mesaj");
      }
    } catch (e) {
      print("Hata oluştu: $e");
    }
  }

  void _getUserImage(String userId) async {
    try {
      final document = firebaseFireStore.collection("users").doc(userId);
      final documentSnapshot = await document.get();

      if (documentSnapshot.exists) {
        setState(() {
          // Eğer kullanıcının imageUrl alanı varsa onu kullan, yoksa boş bir değer kullan
          _imageUrl = documentSnapshot.get("imageUrl") ?? "";
        });
      }
    } catch (e) {
      print("Hata oluştu: $e");
    }
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
    final user = firebaseAuthInstance.currentUser;
    final storageRef =
        firebaseStorageInstance.ref().child("images").child("${user!.uid}.jpg");

    await storageRef.putFile(_pickedFile!);

    final url = await storageRef.getDownloadURL();

    final document = firebaseFireStore.collection("users").doc(user!.uid);

    await document.update({
      'imageUrl': url
    }); // document.update => verilen değeri ilgili dökümanda günceller!
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Firebase Application"),
        actions: [
          IconButton(
              onPressed: () {
                firebaseAuthInstance.signOut();
              },
              icon: const Icon(Icons.logout)),
          IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Center(
                      child: Column(children: [
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_imageUrl.isNotEmpty && _pickedFile == null)
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.grey,
                                foregroundImage: NetworkImage(_imageUrl),
                              ),
                            if (_pickedFile != null)
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.grey,
                                foregroundImage: FileImage(_pickedFile!),
                              ),
                            TextButton(
                                onPressed: () {
                                  _pickImage();
                                },
                                child: const Text("Resim Seç")),
                            if (_pickedFile != null)
                              ElevatedButton(
                                  onPressed: () {
                                    _upload();
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Yükle"))
                          ],
                        )
                      ]),
                    );
                  },
                );
              },
              icon: const Icon(Icons.settings))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firebaseFireStore
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else {
                  var mesajlar = snapshot.data!.docs.reversed;
                  return ListView(
                    padding: const EdgeInsets.all(8),
                    children: mesajlar.map((doc) {
                      var mesaj = doc['mesaj'];
                      var kullaniciId = doc['email'];
                      _getUserImage(kullaniciId);

                      var myMessage = kullaniciId == userGlobal!.email;

                      var alignment = myMessage
                          ? Alignment.centerRight
                          : Alignment.centerLeft;

                      return Container(
                        alignment: alignment,
                        child: Column(
                          children: [
                            CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.grey,
                                foregroundImage: _imageUrl != null
                                    ? NetworkImage(_imageUrl)
                                    : null),
                            Text(kullaniciId.toString()),
                            Text(
                              mesaj,
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameController,
                  maxLength: 50,
                  decoration: InputDecoration(labelText: "Mesaj yaz.."),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  print("Gönderr Tıklandıı");

                  try {
                    final user = firebaseAuthInstance.currentUser;

                    firebaseFireStore
                        .collection("messages")
                        .doc(user!.uid)
                        .set({
                      'email': user.email,
                      'mesaj': _nameController.text,
                      'timestamp': FieldValue.serverTimestamp(),
                    });
                  } catch (e) {
                    print("Hata");
                    print(e);
                  }
                },
                child: Text("Gönder"),
              ),
            ],
          )
        ],
      ),
    );
  }
}
