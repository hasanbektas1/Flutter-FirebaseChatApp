import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebasestudy/chatscreens/messages_item.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

final firebaseAuthInstance = FirebaseAuth.instance;
final firebaseStorageInstance = FirebaseStorage.instance;
final firebaseFireStore = FirebaseFirestore.instance;
final fcm = FirebaseMessaging.instance;

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _HomeState();
}

class _HomeState extends State<ChatPage> {
  final _nameController = TextEditingController();
  final userGlobal = firebaseAuthInstance.currentUser;

  Map<String, String> usersData = {};
  Map<String, String> usersDataImage = {};

  File? _pickedFile;
  XFile? selectedImage;

  final ImagePicker _picker = ImagePicker();

  String _imageUrl = '';

  @override
  void initState() {
    super.initState();
    // Kullanıcı verilerini yükle
    loadUsersData();
    _getUserImage();
  }

  void _getUserImage() async {
    try {
      var usersSnapshot = await firebaseFireStore.collection("users").get();
      for (var userDoc in usersSnapshot.docs) {
        var imageUrlGet = userDoc['email'];

        if (userDoc.data()!.containsKey('imageUrl')) {
          var imageName = userDoc['imageUrl'];
          usersDataImage[imageUrlGet] = imageName;
        } else {
          usersDataImage[imageUrlGet] = 'Bilinmeyen Username';
        }
      }
      setState(() {});
    } catch (e) {
      print('Hata: $e');
    }
  }

  void _upload(File? picketFileImage) async {
    final user = firebaseAuthInstance.currentUser;
    final storageRef =
        firebaseStorageInstance.ref().child("images").child("${user!.uid}.jpg");

    await storageRef.putFile(picketFileImage!);

    final url = await storageRef.getDownloadURL();

    final document = firebaseFireStore.collection("users").doc(user!.uid);

    await document.update({'imageUrl': url});
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

  openImagePicker() async {
    XFile? selectedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      selectedImage = selectedFile;
    });
  }

  Future<void> loadUsersData() async {
    try {
      var usersSnapshot = await firebaseFireStore.collection("users").get();
      for (var userDoc in usersSnapshot.docs) {
        var email = userDoc['email'];

        if (userDoc.data()!.containsKey('username')) {
          var username = userDoc['username'];
          usersData[email] = username;
        } else {
          usersData[email] = 'Bilinmeyen Username';
        }
      }
      setState(() {});
    } catch (e) {
      print('Hata: $e');
    }
  }

  void sendMesaage() {
    try {
      final user = firebaseAuthInstance.currentUser;

      firebaseFireStore.collection("messages").add({
        'email': user!.email,
        'mesaj': _nameController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    print(userGlobal!.uid);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
        backgroundColor: const Color.fromARGB(255, 93, 160, 214),
        actions: [
          IconButton(
            onPressed: () {
              firebaseAuthInstance.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (BuildContext context) {
                  return Center(
                    child: Column(children: [
                      const SizedBox(height: 15),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 30,
                          ),
                          if (selectedImage != null)
                            Image.file(
                              File(selectedImage!.path),
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.contain,
                            ),
                          SizedBox(
                            height: 60,
                          ),
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
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                    title: const Text('AlertDialog Title'),
                                    content:
                                        const Text('AlertDialog description'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => openImagePicker(),
                                        child: const Text('Galeri'),
                                      ),
                                      TextButton(
                                        onPressed: () => _pickImage(),
                                        child: const Text('Kamera'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: const Text("Resim Seç")),
                          ElevatedButton(
                              onPressed: () {
                                _upload(_pickedFile);
                                Navigator.pop(context);
                              },
                              child: const Text("Yükle")),
                          SizedBox(
                            height: 10,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                File file = File(selectedImage!.path);

                                _upload(file);
                                Navigator.pop(context);
                              },
                              child: const Text("Yükle Galeri"))
                        ],
                      )
                    ]),
                  );
                },
              );
            },
            icon: const Icon(Icons.person),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firebaseFireStore
                  .collection("messages")
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Hata: ${snapshot.error}');
                } else {
                  var messages = snapshot.data!.docs;

                  List<Widget> messageWidgets = [];
                  for (var message in messages) {
                    final messageText = message['mesaj'];
                    final messageSender = message['email'];

                    var usernames =
                        usersData[messageSender] ?? 'Bilinmeyen Username';

                    var userImage =
                        usersDataImage[messageSender] ?? 'Bilinmeyen Username';

                    final messageWidget = MessageWidget(
                      sender: usernames,
                      text: messageText,
                      imageUrl: userImage,
                      isMe: firebaseAuthInstance.currentUser != null &&
                          firebaseAuthInstance.currentUser!.email ==
                              messageSender,
                    );

                    messageWidgets.add(messageWidget);
                  }

                  return ListView(
                    reverse: true,
                    children: messageWidgets,
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
                onPressed: () {
                  sendMesaage();
                  _nameController.clear();
                },
                child: Text("Gönder"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
