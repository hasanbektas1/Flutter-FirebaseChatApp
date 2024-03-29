import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebasestudy/chatscreens/chat_page.dart';
import 'package:firebasestudy/chatscreens/chat_login_page.dart';
import 'package:firebasestudy/firebase_options.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // önce flutter ayaga kalmkası
  await Firebase.initializeApp(
    // sonra firebase ayaga kalkması
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ChatPage();
          }
          return ChatLoginPage();
        }),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chat Uygulaması',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(),
    );
  }
}
