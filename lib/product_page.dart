import 'package:fableverse/firebase/auth/userrepo.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fableverse/cart.dart';

class ProductPage extends StatefulWidget {
  final String id;
  final String imagePath;
  final String type;
  
  const ProductPage({
    super.key,
    required this.id, 
    required this.imagePath,
    required this.type,
   
    
  });

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final UserRepository _userRepository = UserRepository();

  Future<String?> getCurrentUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return await _userRepository.getUserId(user.uid);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Text(
          'Product Page',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 159, 92, 171),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
          .collection('books')
          .doc(widget.type) // 'comic' or 'single'
          .collection('items')
          .doc(widget.id)
          .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
                child: Text('Book not found', style: TextStyle(color: Colors.white)));
          }

          Map<String, dynamic> bookData = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromARGB(255, 170, 121, 243).withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Image.network(
                                bookData['imagePath'],
                                width: 250,
                                height: 300,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 250,
                                    height: 300,
                                    color: Colors.grey,
                                    child: Icon(Icons.error),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            bookData['title'],
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            '₹${bookData['cost']}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            bookData['description'],
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        FutureBuilder<String?>(
                          future: getCurrentUserId(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              return FeedbackWidget(
                                bookId: widget.id,
                                currentUserId: snapshot.data,
                              );
                            } else {
                              return Center(child: CircularProgressIndicator());
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CartButton(
                        onPressed: () async {
                          try {
                            // Create a map of the product data
                            Map<String, dynamic> productData = {
                              'imagePath': bookData['imagePath'],
                              'cost': bookData['cost'],
                              'title': bookData['title'],
                              'description': bookData['description'],
                              'isAdded': true,
                              'id': widget.id,
                            };

                            // Add the product data to Firestore
                            await FirebaseFirestore.instance.collection('cart').add(productData);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Added to Cart'),
                                duration: Duration(seconds: 2),
                              ),
                            );

                            // Navigate to the CartPage
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => CartPage()),
                            );
                          } catch (e) {
                            print('Error adding to cart: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error adding to cart'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        text: 'Add to cart',
                      ),
                      SizedBox(width: 16),
                      CartButton(
                        onPressed: () {
                          print('Buy Now button pressed');
                          // Implement buy now functionality
                        },
                        text: 'Buy Now',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


class CartButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const CartButton({super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Color.fromARGB(255, 159, 92, 171),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: onPressed,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class FeedbackWidget extends StatefulWidget {
  final String bookId;
  final String? currentUserId;

  const FeedbackWidget({super.key, required this.bookId, this.currentUserId});

  @override
  State<FeedbackWidget> createState() => _FeedbackWidgetState();
}

class _FeedbackWidgetState extends State<FeedbackWidget> {
  final TextEditingController _commentController = TextEditingController();
  double _rating = 0;
  CollectionReference feedbackCollection = FirebaseFirestore.instance.collection('feedback');
  List<Map<String, dynamic>> feedbacks = [];

  @override
  void initState() {
    super.initState();
    fetchFeedbacks();
  }

  void fetchFeedbacks() {
    feedbackCollection.doc(widget.bookId).get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          feedbacks = List.from(documentSnapshot['feedbacks'] ?? []);
        });
      }
    }).catchError((error) {
      print('Failed to load feedbacks: $error');
    });
  }

  void addFeedback() {
    String newComment = _commentController.text.trim();
    if (newComment.isNotEmpty && _rating > 0) {
      if (widget.currentUserId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please log in to submit feedback')),
        );
        return;
      }

      setState(() {
        feedbacks.add({
          'comment': newComment,
          'rating': _rating,
          'userId': widget.currentUserId,
        });
        _commentController.clear();
        _rating = 0;
      });

      feedbackCollection.doc(widget.bookId).set({
        'feedbacks': feedbacks,
      }).then((value) {
        print('Feedback added to Firestore');
      }).catchError((error) {
        print('Failed to add feedback: $error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rate this product:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: RatingBar.builder(
            initialRating: _rating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemSize: 30,
            itemPadding: const EdgeInsets.symmetric(horizontal: 2),
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              setState(() {
                _rating = rating;
              });
            },
          ),
        ),
        SizedBox(height: 16),
        if (widget.currentUserId != null) ...[
          TextField(
            controller: _commentController,
            decoration: InputDecoration(
              hintText: 'Write a review',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: addFeedback,
            child: Text('Submit Feedback'),
          ),
        ] else
          Text('Please log in to submit feedback', style: TextStyle(color: Colors.white)),
        SizedBox(height: 16),
        Text(
          'Reviews:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: feedbacks.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        ' ${feedbacks[index]['userId'] ?? 'Anonymous'}',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      RatingBarIndicator(
                        rating: feedbacks[index]['rating'],
                        itemBuilder: (context, index) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: 16,
                        direction: Axis.horizontal,
                      ),
                      SizedBox(width: 8),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    feedbacks[index]['comment'],
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}