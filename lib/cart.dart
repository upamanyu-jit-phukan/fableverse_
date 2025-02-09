import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Cart'),
        backgroundColor: Color.fromARGB(255, 170, 121, 243),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('cart').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          List<Product> cartItems = snapshot.data!.docs.map((doc) {
            return Product(
              id: doc.id,
              title: doc['title'],
              imagePath: doc['imagePath'],
              cost: doc['cost'],
              description: doc['description'],
              isAdded: true,
            );
          }).toList();

          return ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (ctx, i) {
              return ProductCard(product: cartItems[i]);
            },
          );
        },
      ),
      bottomNavigationBar: TotalCostBar(),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black, // Set card background color to black
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              product.imagePath,
              width: 150,
              height: 150,
            ),
            SizedBox(width: 10), // Add spacing between image and text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), // Set text color to white
                  ),
                  SizedBox(height: 5), // Add spacing between title and price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${product.cost}',
                        style: TextStyle(fontSize: 16, color: Colors.white), // Set text color to white
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        color: Colors.white, // Set delete icon color to white
                        onPressed: () {
                          FirebaseFirestore.instance.collection('cart').doc(product.id).delete();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TotalCostBar extends StatelessWidget {
  const TotalCostBar({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('cart').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox();

        double totalCost = snapshot.data!.docs.fold(0, (sum, doc) {
          return sum + double.parse(doc['cost'].toString());
        });

        return Container(
          padding: EdgeInsets.all(16),
          color: Color.fromARGB(255, 170, 121, 243),
          child: Text(
            'Total: ₹${totalCost.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        );
      },
    );
  }
}
