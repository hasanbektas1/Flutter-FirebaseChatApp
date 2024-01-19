import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

final firebaseAuthInstance = FirebaseAuth.instance;
final firebaseStorageInstance = FirebaseStorage.instance;
final firebaseFireStore = FirebaseFirestore.instance;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _nameController = TextEditingController();
  final userGlobal = firebaseAuthInstance.currentUser;

  File? _pickedFile;
  String _imageUrl = '';
  String mesaj = 'sdasdas';

  @override
  void initState() {
    _getUserImage();
    _getMessage();
    super.initState();
  }

  void _getMessage() async {
    print("_GEtmesaasajasd");
    try {
      final user = firebaseAuthInstance.currentUser;
      if (user != null) {
        final document = firebaseFireStore.collection("mesajlar").doc(user.uid);
        final documentSnapshot = await document.get();
        print("idd-------------------------");

        print(documentSnapshot.id);
        print("email-------------------------");
        mesaj = documentSnapshot.get("mesaj");

        print(documentSnapshot.get("mesaj"));
        print("data-------------------------");

        print(documentSnapshot.data());

        // documentSnapshot.exists kontrolü eklenerek dökümanın varlığı kontrol ediliyor
        if (documentSnapshot.exists) {
          print("documentSnapshot");
        } else {
          print("Döküman bulunamadı.");
          // Döküman bulunamadığında varsayılan bir değeri atayabilir veya
          // gerekli işlemleri gerçekleştirebilirsiniz.
        }
      } else {
        print("Kullanıcı oturumu kapatılmış veya bulunamadı.");
        // Kullanıcı oturumu kapatılmış veya bulunamadığında gerekli işlemleri gerçekleştirebilirsiniz.
      }
    } catch (e) {
      print("Hata oluştu: $e");
      // Hata durumunda gerekli işlemleri gerçekleştirebilirsiniz.
    }
  }

  void _getUserImage() async {
    try {
      final user = firebaseAuthInstance.currentUser;
      if (user != null) {
        final document = firebaseFireStore.collection("users").doc(user.uid);
        final documentSnapshot = await document.get();

        // documentSnapshot.exists kontrolü eklenerek dökümanın varlığı kontrol ediliyor
        if (documentSnapshot.exists) {
          print("documentSnapshot");
          setState(() {
            _imageUrl = documentSnapshot.get("imageUrl");
          });
        } else {
          print("Döküman bulunamadı.");
          // Döküman bulunamadığında varsayılan bir değeri atayabilir veya
          // gerekli işlemleri gerçekleştirebilirsiniz.
        }
      } else {
        print("Kullanıcı oturumu kapatılmış veya bulunamadı.");
        // Kullanıcı oturumu kapatılmış veya bulunamadığında gerekli işlemleri gerçekleştirebilirsiniz.
      }
    } catch (e) {
      print("Hata oluştu: $e");
      // Hata durumunda gerekli işlemleri gerçekleştirebilirsiniz.
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
              icon: const Icon(Icons.logout))
        ],
      ),
      body: Column(
        children: [
          Center(
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
                        },
                        child: const Text("Yükle"))
                ],
              )
            ]),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firebaseFireStore
                  .collection('mesajlar')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Hata: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Text('Veri bulunamadı');
                } else {
                  var mesajlar = snapshot.data!.docs.reversed;
                  return ListView(
                    padding: const EdgeInsets.all(8),
                    children: mesajlar.map((doc) {
                      var mesaj = doc['mesaj'];
                      var kullaniciId = doc['email'];

                      final user = firebaseAuthInstance.currentUser;
                      print("Prinnt-------");
                      print(user);
                      print("Prinas222--------");

                      print(userGlobal!.email);

                      var myMessage = kullaniciId == userGlobal!.email;

                      var alignment = myMessage
                          ? Alignment.centerRight
                          : Alignment.centerLeft;

                      return Container(
                        alignment: alignment,
                        child: Column(
                          children: [
                            Text(kullaniciId.toString()),
                            Text(mesaj),
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
                        .collection("mesajlar")
                        .doc(user!
                            .uid) // içerisine id aldığında o id'yi almadığına AUTO-ID kullanır.
                        .set({
                      'email': user.email,
                      'mesaj': _nameController.text,
                      'timestamp': FieldValue.serverTimestamp(),
                    }); // Verilen değeri ilgili dökümana yazar.
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
