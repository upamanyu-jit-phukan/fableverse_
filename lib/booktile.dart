import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Tile extends StatelessWidget {
  final String imagePath;
  final String cost;
  final VoidCallback onTap;

  const Tile({
    super.key,
    required this.imagePath,
    required this.cost,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<String>(
              future: _getImageUrl(imagePath),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  // Handle error or display placeholder image
                  return Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey,
                    child: Icon(Icons.image_not_supported, color: Colors.white),
                  );
                }
                return Image.network(
                  snapshot.data!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                );
              },
            ),
            SizedBox(height: 8),
            Text('₹$cost', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Future<String> _getImageUrl(String imagePath) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(imagePath);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error fetching image URL: $e');
      return ''; // or return a default image URL
    }
  }
}
