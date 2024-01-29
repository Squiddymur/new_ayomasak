import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../styles/Text.dart';
import '../../styles/button.dart';
import '../../styles/color.dart';

class MyCreate extends StatefulWidget {
  const MyCreate({super.key});

  @override
  State<MyCreate> createState() => _MyCreateState();
}

class _MyCreateState extends State<MyCreate> {
  TextEditingController titleController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  List<TextEditingController> listController1 = [TextEditingController()];
  List<TextEditingController> listController2 = [TextEditingController()];
  String? selectedImagePath;
  String? selectedCategory;
  File? imageFile;
  final GlobalKey _imageKey = GlobalKey();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  Future<String> _uploadImageToFirebaseStorage(
      File imageFile, String imageName) async {
    try {
      // Access Firebase Storage instance
      FirebaseStorage storage = FirebaseStorage.instance;

      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String uniqueImageName = '$imageName$timestamp.jpg';
      // Define path to store the image in Firebase Storage
      String imagePath = 'images/$uniqueImageName.jpg';

      // Upload image to Firebase Storage
      await storage.ref(imagePath).putFile(imageFile);

      // Get the download URL of the uploaded image
      String imageUrl = await storage.ref(imagePath).getDownloadURL();

      print('Image URL: $imageUrl');
      return imageUrl;
    } catch (error) {
      print('Error uploading image: $error');
      return '';
    }
  }

  Future<void> _getImage1(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        selectedImagePath = pickedFile.path;
        imageFile = File(selectedImagePath!);
      });
    }
  }

  Future<void> _saveRecipeToFirestore() async {
    try {
      if (imageFile == null ||
          titleController.text.isEmpty ||
          timeController.text.isEmpty ||
          selectedCategory == null ||
          listController1.any((controller) => controller.text.isEmpty) ||
          listController2.any((controller) => controller.text.isEmpty)) {
        // Tampilkan pesan atau handling lainnya
        print("Pastikan semua field terisi dan gambar telah dipilih.");
        return;
      }
      // Access Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      String imageUrl = '';

      // Check if imageFile is not null before uploading
      if (imageFile != null) {
        // Upload the image to Firebase Storage and get the URL
        imageUrl =
            await _uploadImageToFirebaseStorage(imageFile!, 'recipe_image');
      }

      Timestamp timestamp = Timestamp.now();
      String currentUserUid = FirebaseAuth.instance.currentUser?.uid ?? '';
      // Create a new document in the 'recipes' collection
      DocumentReference recipeRef = await firestore.collection('recipe').add({
        'title':
            titleController.text, // Use the title from the first controller
        'time': timeController.text, // Use the time from the first controller
        'category':
            selectedCategory, // Define 'selectedCategory' based on user selection
        'ingredients':
            listController1.map((controller) => controller.text).toList(),
        'steps': listController2.map((controller) => controller.text).toList(),
        'imageUrl': imageUrl,
        'timestamp': timestamp,
        'ownerUid': currentUserUid,
        'id': 'custom_id_${DateTime.now().millisecondsSinceEpoch}',
        // Add other fields as needed
      });

      // Print the document ID for reference
      print('Recipe added with ID: ${recipeRef.id}');
      String ownerName = await _getOwnerName(currentUserUid);
      recipeRef.update({'ownerName': ownerName});
      _resetForm();
      if (!mounted) return;
      Navigator.pop(context);
    } catch (error) {
      print('Error saving recipe: $error');
    }
  }

  void _resetForm() {
    // Reset semua field dan state yang perlu direset
    setState(() {
      titleController.clear();
      timeController.clear();
      listController1.clear();
      listController1.add(TextEditingController());
      listController2.clear();
      listController2.add(TextEditingController());
      selectedImagePath = null;
      selectedCategory = null;
      imageFile = null;
    });
  }

  Future<String> _getOwnerName(String uid) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot userSnapshot =
          await firestore.collection('users').doc(uid).get();

      if (userSnapshot.exists) {
        return userSnapshot['name'];
      } else {
        return ''; // Atau nilai default jika pengguna tidak ditemukan
      }
    } catch (error) {
      print('Error getting owner name: $error');
      return ''; // Atau nilai default jika terjadi kesalahan
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ScaffoldMessenger(
        key: scaffoldMessengerKey,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_ios),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: greyPrimary,
                  height: 266,
                  width: MediaQuery.of(context).size.width,
                  child: FittedBox(
                    alignment: Alignment.center,
                    fit: BoxFit.cover,
                    child: GestureDetector(
                      onTap: () => _getImage1(
                        ImageSource.gallery,
                      ),
                      child: KeyedSubtree(
                        key: _imageKey,
                        child: selectedImagePath != null
                            ? Image.file(File(selectedImagePath!))
                            : const Icon(Icons.photo),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                    hintText: 'Judul',
                    hintStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                    filled: true,
                    fillColor: Colors.grey[300],
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide.none,
                    ),
                    counterText: ''),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLength: 20,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Waktu Pembuatan',
                  ),
                  SizedBox(
                    width: 157,
                    child: TextField(
                      controller: timeController,
                      decoration: InputDecoration(
                          hintText: '1 Jam 45 Menit',
                          hintStyle: const TextStyle(
                            fontSize: 12,
                          ),
                          filled: true,
                          fillColor: Colors.grey[300],
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none,
                          ),
                          counterText: ""),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLength: 14,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Kategori'),
                  SizedBox(
                    width: 157,
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        hintText: 'Sarapan',
                        hintStyle: const TextStyle(
                          fontSize: 12,
                        ),
                        filled: true,
                        fillColor: Colors.grey[300],
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      value: selectedCategory,
                      items: [
                        DropdownMenuItem(
                          value: 'Sarapan',
                          child: Text(
                            'Sarapan',
                            style: kategoriCreate,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Makan Siang',
                          child: Text(
                            'Makan Siang',
                            style: kategoriCreate,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Makan Malam',
                          child: Text(
                            'Makan Malam',
                            style: kategoriCreate,
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Snack',
                          child: Text(
                            'Snack',
                            style: kategoriCreate,
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                        });
                        //
                      },
                    ),
                  ),
                ],
              ),
              const Divider(),
              SizedBox(
                height: 220,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Bahan'),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              listController1.add(TextEditingController());
                            });
                          },
                          icon: const Icon(Icons.add),
                          color: greenPrimary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      // Tambahkan Expanded di sini
                      child: ListView.builder(
                        itemCount: listController1.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    height: 50,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: greyPrimary,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: TextFormField(
                                      controller: listController1[index],
                                      autofocus: false,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Masukkan Bahan",
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                index != 0
                                    ? GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            listController1[index].clear();
                                            listController1[index].dispose();
                                            listController1.removeAt(index);
                                          });
                                        },
                                        child: const Icon(
                                          Icons.delete,
                                          size: 35,
                                        ),
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              SizedBox(
                height: 220,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Langkah'),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              listController2.add(TextEditingController());
                            });
                          },
                          icon: const Icon(Icons.add),
                          color: greenPrimary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      // Tambahkan Expanded di sini
                      child: ListView.builder(
                        itemCount: listController2.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    height: 50,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: greyPrimary,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: TextFormField(
                                      controller: listController2[index],
                                      autofocus: false,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Masukkan Langkah",
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                index != 0
                                    ? GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            listController2[index].clear();
                                            listController2[index].dispose();
                                            listController2.removeAt(index);
                                          });
                                        },
                                        child: const Icon(
                                          Icons.delete,
                                          size: 35,
                                        ),
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: ElevatedButton(
                    onPressed: () {
                      // Validasi apakah semua input sudah terisi
                      if (imageFile == null ||
                          titleController.text.isEmpty ||
                          timeController.text.isEmpty ||
                          selectedCategory == null ||
                          listController1
                              .any((controller) => controller.text.isEmpty) ||
                          listController2
                              .any((controller) => controller.text.isEmpty)) {
                        // Tampilkan pesan atau handling lainnya
                        print(
                            "Pastikan semua field terisi dan gambar telah dipilih.");
                        scaffoldMessengerKey.currentState?.showSnackBar(
                          const SnackBar(
                            content: Text(
                                "Pastikan semua field terisi dan gambar telah dipilih."),
                            duration: Duration(seconds: 3),
                          ),
                        );
                        // Tombol tidak aktif
                      } else {
                        // Jalankan fungsi _saveRecipeToFirestore jika semua input sudah terisi
                        _saveRecipeToFirestore();
                      }
                    },
                    style: buttonPrimary,
                    child: const Text(
                      'Unggah',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ))
            ]),
          ),
        ),
      ),
    );
  }
}
