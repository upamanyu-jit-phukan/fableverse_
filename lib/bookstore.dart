
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fableverse/bar.dart';
import 'package:fableverse/tile.dart';
import 'package:fableverse/product_page.dart';

// Assuming you have a Tile widget defined

class Book {
  final String id;
  final String imagePath;
  final String cost;
  final String type;

  Book({
    required this.id,
    required this.imagePath,
    required this.cost,
    required this.type,
  });

  factory Book.fromSnapshot(DocumentSnapshot snapshot) {
  Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
  print('Raw data from Firestore: $data'); // Add this line
  return Book(
    id: snapshot.id,
    imagePath: data['imagePath'] ?? '',
    cost: (data['cost'] ?? '0').toString(),
    type: data['type'] ?? '',
  );
}
}

class BookStore extends StatelessWidget {
  const BookStore({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: const Center(child: Text('Book Store')),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black87,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collectionGroup('items').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No books found'));
          }

          final books = snapshot.data!.docs.map((doc) => Book.fromSnapshot(doc)).toList();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'BESTSELLERS...',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: books
                        .where((book) => book.type == 'single')
                        .map((book) => Tile(
                              imagePath: book.imagePath,
                              cost: book.cost,
                              type: 'single',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductPage(
                                      id: book.id,
                                      imagePath: book.imagePath,
                                      type: book.type
                                    ),
                                  ),
                                );
                              },
                            ))
                        .toList(),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'ALL BOOKS',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: books
                        .map((book) => Tile(
                              imagePath: book.imagePath,
                              cost: book.cost,
                              type: book.type,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductPage(
                                      id: book.id,
                                      imagePath: book.imagePath,
                                      type:book.type
                                    ),
                                  ),
                                );
                              },
                            ))
                        .toList(),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'COMICS',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: books
                        .where((book) => book.type == 'comic')
                        .map((book) => Tile(
                              imagePath: book.imagePath,
                              cost: book.cost,
                              type: 'comic',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductPage(
                                      id: book.id,
                                      imagePath: book.imagePath,
                                      type:  book.type
                                    ),
                                  ),
                                );
                              },
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const BottomBar(),
    );
  }
}