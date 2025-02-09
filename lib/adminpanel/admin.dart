import 'dart:io';
import 'package:fableverse/adminpanel/bookmodel.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _costController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _image;
  File? _pdf;
  final picker = ImagePicker();
  String _bookType = 'single'; // Default value

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future getPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _pdf = File(result.files.single.path!);
      });
    }
  }

  Future<String> uploadImage(File image) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('book_images/$fileName');
    UploadTask uploadTask = firebaseStorageRef.putFile(image);
    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

  Future<String> uploadPdf(File pdf) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('book_pdfs/$fileName.pdf');
    UploadTask uploadTask = firebaseStorageRef.putFile(pdf);
    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

void _submitForm() async {
  if (_formKey.currentState!.validate() && _image != null && _pdf != null) {
    String imageUrl = await uploadImage(_image!);
    String pdfUrl = await uploadPdf(_pdf!);

    Book newBook = Book(
      id: '',
      title: _titleController.text,
      imagePath: imageUrl,
      cost: _costController.text,
      description: _descriptionController.text,
      pdfUrl: pdfUrl,
      type: _bookType,
    );

    // Get a new write batch
    WriteBatch batch = FirebaseFirestore.instance.batch();

    // Create a reference for the new book document
    DocumentReference newBookRef = FirebaseFirestore.instance
        .collection('books')
        .doc(_bookType)
        .collection('items')
        .doc();

    // Set the data for the new book
    batch.set(newBookRef, {
      'id': newBookRef.id,
      'title': newBook.title,
      'imagePath': newBook.imagePath,
      'cost': newBook.cost,
      'description': newBook.description,
      'pdfUrl': newBook.pdfUrl,
      'type': newBook.type,
    });

    // Commit the batch
    await batch.commit();

    // Clear form after submission
    _titleController.clear();
    _costController.clear();
    _descriptionController.clear();
    setState(() {
      _image = null;
      _pdf = null;
      _bookType = 'single'; // Reset to default value
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Book added successfully')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill all fields and select both an image and a PDF')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _costController,
                decoration: const InputDecoration(labelText: 'Cost'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a cost';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _bookType,
                decoration: const InputDecoration(labelText: 'Book Type'),
                items: <String>['single', 'comic'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value[0].toUpperCase() + value.substring(1)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _bookType = newValue!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a book type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: getImage,
                child: const Text('Select Cover Image'),
              ),
              const SizedBox(height: 10),
              _image != null
                  ? Image.file(_image!, height: 100)
                  : const Text('No image selected'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: getPdf,
                child: const Text('Select PDF'),
              ),
              const SizedBox(height: 10),
              _pdf != null
                  ? Text('PDF selected: ${_pdf!.path.split('/').last}')
                  : const Text('No PDF selected'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Add Book'),
              ),
            ],
          ),
        ),
        
      ),
      bottomNavigationBar: AdBottomBar()
    );
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