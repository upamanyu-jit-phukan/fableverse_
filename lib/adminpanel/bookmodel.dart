import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String title;
  final String imagePath;
  final File? imageFile;
  final String cost;
  final String description;
  final String pdfUrl;
  final File? pdfFile;
  final String type;

  Book({
    required this.id,
    required this.title,
    required this.imagePath,
    this.imageFile,
    required this.cost,
    required this.description,
    required this.pdfUrl,
    this.pdfFile,
    required this.type,
  });

  factory Book.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Book(
      id: doc.id,
      title: data['title'] ?? '',
      imagePath: data['imagePath'] ?? '',
      cost: data['cost'] ?? '',
      description: data['description'] ?? '',
      pdfUrl: data['pdfUrl'] ?? '',
      type: data['type'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'imagePath': imagePath,
      'cost': cost,
      'description': description,
      'pdfUrl': pdfUrl,
      'type': type,
    };
  }

  factory Book.withFiles({
    required String title,
    required File imageFile,
    required String cost,
    required String description,
    required File pdfFile,
    required String type,
  }) {
    return Book(
      id: '',  // This will be set after Firestore creates the document
      title: title,
      imagePath: '',  // This will be set after the image is uploaded
      imageFile: imageFile,
      cost: cost,
      description: description,
      pdfUrl: '',  // This will be set after the PDF is uploaded
      pdfFile: pdfFile,
      type: type,
    );
  }
}
