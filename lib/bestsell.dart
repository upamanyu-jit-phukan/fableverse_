import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BestSellTile extends StatefulWidget {
  const BestSellTile({super.key});

  @override
  State<BestSellTile> createState() => _BestSellTileState();
}

class _BestSellTileState extends State<BestSellTile> {
  int activeIndex = 0;
  late List<String> urlImages = [];

  @override
  void initState() {
    super.initState();
    fetchBestSellers();
  }

  Future<void> fetchBestSellers() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('books')
          .limit(3) // Limit to 3 bestsellers, adjust as needed
          .get();

      setState(() {
        urlImages = snapshot.docs.map((doc) => doc['imagePath'] as String).toList();
      });
    } catch (e) {
      print('Error fetching best sellers: $e');
      // Handle error gracefully, e.g., show a placeholder image or message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: urlImages.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CarouselSlider.builder(
                  itemCount: urlImages.length,
                  itemBuilder: (context, index, realIndex) {
                    final urlImage = urlImages[index];
                    return buildCard(urlImage);
                  },
                  options: CarouselOptions(
                    height: 300,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    aspectRatio: 16 / 9, // Adjust aspect ratio as needed
                    onPageChanged: (index, reason) {
                      setState(() {
                        activeIndex = index;
                      });
                    },
                  ),
                ),
                SizedBox(height: 10),
                Center(child: buildIndicator()),
              ],
            ),
    );
  }

  Widget buildIndicator() => AnimatedSmoothIndicator(
        activeIndex: activeIndex,
        count: urlImages.length,
        effect: ExpandingDotsEffect(
          dotWidth: 7,
          dotHeight: 7,
          activeDotColor: Colors.blue,
        ),
      );

  Widget buildCard(String urlImage) => Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            urlImage,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 300,
          ),
        ),
      );
}
