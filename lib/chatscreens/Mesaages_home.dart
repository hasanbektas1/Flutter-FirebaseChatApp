import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebasestudy/chatscreens/messages_item.dart';
import 'package:flutter/material.dart';

final firebaseAuthInstance = FirebaseAuth.instance;
final firebaseStorageInstance = FirebaseStorage.instance;
final firebaseFireStore = FirebaseFirestore.instance;
final fcm = FirebaseMessaging.instance;

class MessagesHomePage extends StatefulWidget {
  const MessagesHomePage({Key? key}) : super(key: key);

  @override
  State<MessagesHomePage> createState() => _HomeState();
}

class _HomeState extends State<MessagesHomePage> {
  final _nameController = TextEditingController();
  final userGlobal = firebaseAuthInstance.currentUser;

  Map<String, String> usersData = {};

  @override
  void initState() {
    super.initState();
    // Kullanıcı verilerini yükle
    loadUsersData();
  }

  Future<void> loadUsersData() async {
    try {
      var usersSnapshot = await firebaseFireStore.collection("users").get();
      for (var userDoc in usersSnapshot.docs) {
        var email = userDoc['email'];

        // Kullanıcı belgesinde 'username' alanı var mı kontrol et
        if (userDoc.data()!.containsKey('username')) {
          var username = userDoc['username'];
          usersData[email] = username;
          /*       print("Priasdasdasdas");
          print(username);
          print(usersData); */
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
    print("UserGlobal");
    print(userGlobal!.uid);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Firebase Application"),
        actions: [
          IconButton(
            onPressed: () {
              firebaseAuthInstance.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings),
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

                    final messageWidget = MessageWidget(
                      sender: usernames,
                      text: messageText,
                      imageUrl: "null",
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
