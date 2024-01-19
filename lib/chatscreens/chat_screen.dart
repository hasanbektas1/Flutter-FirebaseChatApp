import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Uygulaması'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('messages').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }

                var messages = snapshot.data!.docs;
                List<Widget> messageWidgets = [];
                for (var message in messages) {
                  var messageData = message.data() as Map<String, dynamic>;
                  var userEmail = messageData['email'];
                  var userMessage = messageData['mesaj'];
                  var userId = messageData['userId']; // Kullanıcının ID'sini al
                  var userImageUrl =
                      ''; // Kullanıcının resminin Firestore'dan alınması gerekiyor

                  // Firestore'dan kullanıcının resmini çek

                  print("USerIDdddd");
                  print(userId);
                  print(message.id);
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(message.id)
                      .get()
                      .then((userDoc) {
                    if (userDoc.exists) {
                      setState(() async {
                        userImageUrl = await userDoc['image'];
                      });
                    }
                  });

                  var messageWidget = ListTile(
                    leading: CircleAvatar(
                      backgroundImage: userImageUrl.isNotEmpty
                          ? NetworkImage(userImageUrl) as ImageProvider<Object>?
                          : AssetImage('assets/default_avatar.png')
                              as ImageProvider<Object>?,
                    ),
                    title: Text(userEmail),
                    subtitle: Text(userMessage),
                  );

                  messageWidgets.add(messageWidget);
                }

                return ListView(
                  children: messageWidgets,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Mesajınızı girin...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    // Mesaj gönderme fonksiyonunu burada çağırabilirsiniz
                    // Örneğin: sendMessage(currentUserEmail, _messageController.text);
                    _messageController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
