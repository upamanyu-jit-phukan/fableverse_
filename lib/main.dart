import 'package:fableverse/adminpanel/admin.dart';
import 'package:fableverse/adminpanel/manage.dart';
import 'package:fableverse/auth.dart/splashscreen.dart';
import 'package:fableverse/library.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fableverse/cart.dart';
import 'package:fableverse/second_page.dart';
import 'package:fableverse/home.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); 
  runApp(MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash', // Set initial route to the Splashscreen
      routes: {
        '/splash': (context) => Splashscreen(), // Splashscreen as initial route
        '/home': (context) => Home(), // Default home page
        '/search': (context) => SecondPage(),
        '/cart': (context) => CartPage(),
        '/lib':(context) => Library(),
        '/admin':(context)=> AdminPanel(),
        '/manage':(context)=>ManageBooksPage()
        
      },
    );
  }
}
