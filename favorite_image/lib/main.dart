import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final List<String> _selectedImages = [];
  int _selectedImageIndex = 0;

  Future<void> _openCamera() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(pickedFile.path);
      });
    }
  }

  Future<void> _openGallery() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(pickedFile.path);
      });
    }
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Open Camera'),
              onTap: () {
                Navigator.pop(context);
                _openCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Access Gallery'),
              onTap: () {
                Navigator.pop(context);
                _openGallery();
              },
            ),
          ],
        );
      },
    );
  }

  void _viewImage(int index) {
    setState(() {
      _selectedImageIndex = index;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _buildImageGallery(),
      ),
    );
  }

  void _navigateBackToGrid() {
    Navigator.pop(context);
  }

  Widget _buildImageGallery() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        title: const Text('Image Viewer'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _navigateBackToGrid,
        ),
      ),
      body: PhotoViewGallery.builder(
        itemCount: _selectedImages.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: FileImage(File(_selectedImages[index])),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        scrollPhysics: const BouncingScrollPhysics(),
        backgroundDecoration: const BoxDecoration(
          color: Colors.black,
        ),
        pageController: PageController(initialPage: _selectedImageIndex),
        onPageChanged: (index) {
          setState(() {
            _selectedImageIndex = index;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        title: const Text('Image Picker App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo),
            onPressed: _showOptions,
          ),
        ],
      ),
      body: _selectedImages.isEmpty
          ? const Center(
              child: Text('No images selected'),
            )
          : GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 5.0,
                mainAxisSpacing: 5.0,
              ),
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _viewImage(index),
                  child: Image.file(
                    File(_selectedImages[index]),
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
    );
  }
}
