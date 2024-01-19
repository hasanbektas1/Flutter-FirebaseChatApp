import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebasestudy/screens/login_page.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late FirebaseAuth auth;

  late String userEmail, userPassword;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      appBar: AppBar(
        title: Text("Kayıt ol"),
        backgroundColor: Color.fromARGB(255, 91, 89, 89),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return "email giriniz";
                  }
                  return null;
                },
                onSaved: (newValue) {
                  userEmail = newValue!;
                },
                decoration: const InputDecoration(
                    hintText: "Email",
                    hintStyle: TextStyle(color: Colors.white),
                    border: InputBorder.none),
              ),
              TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return "şifre giriniz";
                  }
                  return null;
                },
                onSaved: (newValue) {
                  userPassword = newValue!;
                },
                obscureText: true,
                decoration: const InputDecoration(
                    hintText: "Password",
                    hintStyle: TextStyle(color: Colors.white),
                    border: InputBorder.none),
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          print("Kayıt ol tıklandı");

                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            createUserEmailAndPass();
                          } else {}
                        },
                        child: Text("Kayıt ol")),
                    const SizedBox(
                      width: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void createUserEmailAndPass() async {
    try {
      var _userCredential = await auth.createUserWithEmailAndPassword(
          email: userEmail, password: userPassword);
      print("pasdaasdasd ${_userCredential.user!.uid}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("KAyıt başarılı giriş yapınız"),
        ),
      );
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (ctx) => LoginPage()));
    } catch (e) {
      print("catch e : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$e"),
        ),
      );
    }
  }
}
