import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fableverse/product.dart';
import 'package:flutter/material.dart';


class ProductService {
  final CollectionReference _productsCollection = FirebaseFirestore.instance.collection('books');

  Stream<List<Product>> getProducts() {
    return _productsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product(
          id: doc.id,
          title: doc['title'],
          imagePath: doc['imagePath'],
          cost: doc['cost'],
          description: doc['description'],
        );
      }).toList();
    });
  }

  Future<void> addProduct(Product product) {
    return _productsCollection.add({
      'title': product.title,
      'imagePath': product.imagePath,
      'cost': product.cost,
      'description': product.description,
    });
  }

  Future<void> removeProduct(String productId) {
    return _productsCollection.doc(productId).delete();
  }
}








class ProductListPage extends StatelessWidget {
  final ProductService _productService = ProductService();

  ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
      ),
      body: StreamBuilder<List<Product>>(
        stream: _productService.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          List<Product> products = snapshot.data ?? [];

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ProductCard(product: products[index]);
            },
          );
        },
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Image.network(product.imagePath),
        title: Text(product.title),
        subtitle: Text('₹${product.cost}'),
        trailing: IconButton(
          icon: Icon(Icons.add_shopping_cart),
          onPressed: () {
            // Add to cart functionality
          },
        ),
      ),
    );
  }
}