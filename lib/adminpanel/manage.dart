import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fableverse/adminpanel/bookmodel.dart';
import 'package:fableverse/adminpanel/bookdetail.dart';

class ManageBooksPage extends StatefulWidget {
  const ManageBooksPage({super.key});

  @override
  _ManageBooksPageState createState() => _ManageBooksPageState();
}

class _ManageBooksPageState extends State<ManageBooksPage> {
  String _filter = 'all';  // Default filter set to 'all'
  String _searchQuery = '';
  String _sortOrder = 'newest';  // Default sort set to 'newest'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Books'),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          _buildSearchAndFilterBar(),
          Expanded(
            child: _buildBookList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search books...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              DropdownButton<String>(
                value: _filter,
                items: [
                  DropdownMenuItem(value: 'all', child: Text('All')),
                  DropdownMenuItem(value: 'comic', child: Text('Comics')),
                  DropdownMenuItem(value: 'single', child: Text('Singles')),
                ],
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _filter = newValue;
                    });
                  }
                },
              ),
              DropdownButton<String>(
                value: _sortOrder,
                items: [
                  DropdownMenuItem(value: 'newest', child: Text('Newest First')),
                  DropdownMenuItem(value: 'oldest', child: Text('Oldest First')),
                ],
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _sortOrder = newValue;
                    });
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('books').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        List<Book> books = snapshot.data!.docs.map((doc) => Book.fromFirestore(doc)).toList();

        // Apply filtering
        if (_filter != 'all') {
          books = books.where((book) => book.type == _filter).toList();
        }

        // Apply search
        if (_searchQuery.isNotEmpty) {
          books = books.where((book) => 
            book.title.toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();
        }

        // Apply sorting
        books.sort((a, b) {
          switch (_sortOrder) {
            case 'newest':
              return b.id.compareTo(a.id); // Assuming newer books have larger IDs
            case 'oldest':
              return a.id.compareTo(b.id);
            default:
              return 0;
          }
        });

        return GridView.count(
          crossAxisCount: 3,
          childAspectRatio: 2 / 3,
          children: books.map((book) => Tile(
            imagePath: book.imagePath,
            cost: book.cost,
            type: book.type,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookDetailsPage(
                    book: book,
                  ),
                ),
              );
            },
          )).toList(),
        );
      },
    );
  }
}

// The Tile class remains unchanged

class Tile extends StatelessWidget {
  final String imagePath;
  final String cost;
  final String type;
  final VoidCallback onTap;

  const Tile({
    super.key,
    required this.imagePath,
    required this.cost,
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                child: Image.network(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(child: Icon(Icons.error));
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₹$cost',
                    style: TextStyle(color: Colors.green),
                  ),
                  Text(
                    type.capitalize(),
                    style: TextStyle(color: Colors.grey),
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

// Extension to capitalize the first letter of a string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
















class AdBottomBar extends StatelessWidget {
  const AdBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/admin');
            },
            icon: const Icon(Icons.home),
            color: Colors.white,
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/manage');
            },
            icon: const Icon(Icons.edit),
            color: Colors.white,
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            },
            icon: const Icon(Icons.notifications),
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}