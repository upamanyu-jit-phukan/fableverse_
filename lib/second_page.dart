
import 'package:fableverse/bar.dart';
import 'package:fableverse/tile.dart';
import 'package:flutter/material.dart';
import 'package:fableverse/bookstore.dart'; // Import your BookStore page

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: TopBar(),
      backgroundColor: Colors.black87,
      body: SingleChildScrollView(
        child: Column(
          children: [
            StoreCard(
              store: 'Book Store',
              image: 'lib/assets/merch2.webp',
              destination: BookStore(), // Specify the destination
            ),
            StoreCard(
              store: 'Merchandise',
              image: 'lib/assets/bookstore3.webp',
              destination: BookStore() , // Update to your actual page
            ),
            StoreCard(
              store: 'Know the Characters',
              image: 'lib/assets/ch1.png',
              destination: BookStore(), // Update to your actual page
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomBar(),
    );
  }
}
