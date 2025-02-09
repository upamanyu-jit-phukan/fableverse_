import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class FeedbackWidget extends StatefulWidget {
  final String titles;
  final String currentUserId; // Add this line to receive the current user's ID

  const FeedbackWidget({super.key, required this.titles, required this.currentUserId});

  @override
  State<FeedbackWidget> createState() => _FeedbackWidgetState();
}

class _FeedbackWidgetState extends State<FeedbackWidget> {
  final TextEditingController _commentController = TextEditingController();
  double _rating = 0;
  bool loading = false;
  final databaseRef = FirebaseDatabase.instance.ref('Comments');
  CollectionReference feedbackCollection =
      FirebaseFirestore.instance.collection('feedback');
  List<Map<String, dynamic>> feedbacks = [];

  @override
  void initState() {
    super.initState();
    fetchFeedbacks();
  }

  void fetchFeedbacks() {
    feedbackCollection.doc(widget.titles).get().then((DocumentSnapshot documentSnapshot) {
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
      setState(() {
        feedbacks.add({
          'comment': newComment,
          'rating': _rating,
          'timestamp': DateTime.now().toIso8601String(),
          'userId': widget.currentUserId, // Add the user ID to the feedback
        });
        _commentController.clear();
        _rating = 0;
      });

      feedbackCollection.doc(widget.titles).set({
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
              print('Rating updated: $_rating');
            },
          ),
        ),
        SizedBox(height: 16),
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
                      SizedBox(width: 8)
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    'User ID: ${feedbacks[index]['userId']}', // Display the user ID
                    style: TextStyle(fontSize: 12, color: Colors.grey),
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