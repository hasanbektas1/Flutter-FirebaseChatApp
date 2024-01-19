import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebasestudy/screens/home_page.dart';
import 'package:firebasestudy/screens/sign_up.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late FirebaseAuth auth;

  late String userEmail, userPassword;

  final _formKey = GlobalKey<FormState>();

/*   final _emailController = TextEditingController();
  final _passwordController = TextEditingController(); */

  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 49, 87, 118),
      appBar: AppBar(
        title: Text("Giriş Sayfası"),
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
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            loginUserEmailAndPass();
                          } else {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text("Hata"),
                                    content: Text("ALanları doldurunuz"),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text("Tamam"))
                                    ],
                                  );
                                });
                          }
                        },
                        child: Text("Giriş yap")),
                    const SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (ctx) => SignUpPage()));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Kayıt sayfasına gidilddi'),
                            ),
                          );
                        },
                        child: Text("Kayıt ol")),
                  ],
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    loginAnonymous();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Anonymous giriş yapıldı '),
                      ),
                    );
                  },
                  child: Text("Misafir girişi")),
            ],
          ),
        ),
      ),
    );
  }

  void loginAnonymous() async {
    try {
      var _userCredential = await auth.signInAnonymously();
      print("Anonymous=${_userCredential.user!.uid}");
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (ctx) => HomePage()));
    } on FirebaseAuthException catch (e) {
      print(e);
    }
  }

  void loginUserEmailAndPass() async {
    try {
      var _userCredential = await auth.signInWithEmailAndPassword(
          email: userEmail, password: userPassword);
      print(_userCredential.toString());
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (ctx) => HomePage()));
    } on FirebaseAuthException catch (ex) {
      print(ex.code);
      if (ex.code == "user-not-found") {
        print("ser-not-found--------" + ex.code);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("user-not-found"),
          ),
        );
      } else if (ex.code == "wrong-password") {
        print("wrong-password--------" + ex.code);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Şifre yanlış")),
        );
      } else if (ex.code == "invalid-email") {
        print("wrong-password--------" + ex.code);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                " kullanıcı özelliği için sağlanan değer geçersiz. Bir dizi e-posta adresi olmalıdır."),
          ),
        );
      } else if (ex.code == "invalid-password") {
        print("invalid-password-------" + ex.code);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "kullanıcı özelliği için sağlanan değer geçersiz. En az altı karakterden oluşan bir dize olmalıdır."),
          ),
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("BAşka bir hata ${ex.message}"),
        ),
      );
    }
  }
}
