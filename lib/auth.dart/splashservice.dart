import 'dart:async';
import 'package:fableverse/auth.dart/loginpage.dart';
import 'package:fableverse/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
 // Replace with your actual path

class SplashService {
  void isLogin(BuildContext context) {
    final auth=FirebaseAuth.instance;
    final user = auth.currentUser;
    if(user!=null){
      Timer(Duration(seconds: 3), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Home()), // Corrected builder syntax
      );
    });

    }else{
      Timer(Duration(seconds: 3), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Loginpage()), // Corrected builder syntax
      );
    });
    }
    

    
  }
}
