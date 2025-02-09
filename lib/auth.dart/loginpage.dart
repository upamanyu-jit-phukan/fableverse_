import 'package:fableverse/adminpanel/admin.dart';
import 'package:fableverse/auth.dart/roundbutton.dart';
import 'package:fableverse/auth.dart/signuppage.dart';
import 'package:fableverse/firebase/auth/userrepo.dart';
import 'package:fableverse/home.dart';
import 'package:fableverse/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


const String ADMIN_EMAIL = 'admin@example.com';


class Loginpage extends StatefulWidget {
  const Loginpage({super.key});

  @override
  State<Loginpage> createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final userIdController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

void login() {
  setState(() {
    loading = true;
  });
  _auth
      .signInWithEmailAndPassword(
    email: emailController.text,
    password: passwordController.text.toString(),
  )
      .then((value) async {
    if (value.user != null) {
      await UserRepository().createOrUpdateUserData(
        value.user!.uid,
        userIdController.text.trim(),
      );
      Utils().toastMessage(value.user!.email.toString());
      
      // Check if the logged-in user is the admin
      if (value.user!.email == ADMIN_EMAIL) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminPanel()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
      }
    }
    setState(() {
      loading = false;
    });
  }).onError((error, StackTrace) {
    setState(() {
      loading = false;
    });
    Utils().toastMessage(error.toString());
  });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Login'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/loginbg.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome To FableVerse\nWhere dreams come true',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            controller: emailController,
                            decoration: InputDecoration(
                              hintText: 'Enter your email',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 15),
                          TextFormField(
                            keyboardType: TextInputType.text,
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: 'Enter your password',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 15),
                          TextFormField(
                              keyboardType: TextInputType.text,
                              controller: userIdController, // Add this controller
                              decoration: InputDecoration(
                                hintText: 'Enter your user ID',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your user ID';
                                }
                                return null;
                              },
                            ),
                          Roundbutton(
                            title: 'Login',
                            onTap: () {
                              if (_formKey.currentState!.validate()) {
                                login();
                              }
                            },
                            loading: loading,
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account?",
                                style: TextStyle(color: Colors.white),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => Signuppage()),
                                  );
                                },
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

