import 'package:flutter/material.dart';

class Library extends StatelessWidget {
  
  const Library({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('Library'),
      ),
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Image.asset(
          'lib/assets/bookshelf.png',
          fit: BoxFit.cover
          
        ),
        
      ),
    );
  }
}