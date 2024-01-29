import 'dart:io';
import 'package:ayomasak_2/styles/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../styles/button.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
    final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;

  bool isChecked = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ScaffoldMessenger(
        key: scaffoldMessengerKey,
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
          ),
          body: Container(
            margin: const EdgeInsets.only(left: 10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      iconSize: 20,
                      onPressed: () {
                        Navigator.pushNamed(context, '/loginregister');
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 15, top: 10),
                    child: const Text(
                      'Daftar',
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 8, left: 15),
                    child: const Text(
                      'Simpan resep lezat dan dapatkan  konten pribadimu',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 15, right: 20, top: 25),
                    child: TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: 'Nama',
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 15, right: 20, top: 25),
                    child: TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        hintText: 'Email',
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 15, right: 20, top: 25),
                    child: TextFormField(
                      controller: passwordController,
                      obscureText: !isPasswordVisible,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 35),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Checkbox(
                          value: isChecked,
                          activeColor: Colors.green,
                          onChanged: (bool? value) {
                            setState(() {
                              isChecked = value!;
                            });
                          },
                        ),
                        const Expanded(
                          child: Text(
                            'Saya menyetujui Syarat Dan Ketentuan dan Kebijakan Privasi yang berlaku',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 35),
                      child: ElevatedButton(
  style: buttonSimpan,
  onPressed: isChecked
      ? () async {
          try {
            UserCredential userCredential =
                await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: emailController.text,
              password: passwordController.text,
            );

            // Store user data in Firestore
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userCredential.user!.uid)
                .set({
              'name': nameController.text,
              'email': emailController.text,
              // Add more fields as needed
            });

            String uid = userCredential.user!.uid;

            // Navigate to profile image picker
            if (!context.mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileImagePicker(uid: uid),
              ),
            );
          } catch (e) {
            print("Error during registration: $e");

            String errorMessage =
                "Terjadi kesalahan saat mendaftar. Mohon periksa kembali email dan password Anda.";

            if (e is FirebaseAuthException && e.code == 'invalid-email') {
              errorMessage = "Mohon masukkan format email yang benar.";

              // Show the error message using a Snackbar
              scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(
                  content: Text(errorMessage),
                  duration: const Duration(seconds: 3),
                ),
              );
            } else {
              // Show the default error message for other cases
              scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(
                  content: Text(errorMessage),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        }
      : null,
  child: const Text(
    'Daftar',
    style: TextStyle(color: Colors.white, fontSize: 20),
  ),
),


        
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            'Sudah memiliki akun?',
                            style: TextStyle(color: Colors.black),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            child: const Text(
                              'Masuk',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileImagePicker extends StatefulWidget {
  final String uid;
  const ProfileImagePicker({required this.uid, Key? key}) : super(key: key);

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  XFile? _pickedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _pickedImage = pickedFile;
    });
  }

  Future<void> _saveProfileData() async {
    try {
      if (_pickedImage == null) {
        // Only proceed if an image is picked
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Peringatan'),
              content: const Text('Mohon pilih gambar profil.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }
        String imagePath = 'images/${widget.uid}_profile_image.jpg';
        Reference storageReference =
            FirebaseStorage.instance.ref().child(imagePath);
        await storageReference.putFile(File(_pickedImage!.path));
        String profileImageUrl = await storageReference.getDownloadURL();
        print('URL Gambar Profil: ${_pickedImage?.path}');

        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.uid)
            .update({
          'profile_image_url': profileImageUrl,
          'uid': widget.uid,
          // Add other fields as needed
        });
      
      if (!mounted) return;
      // Navigasi ke halaman utama atau profil setelah menyimpan data
      Navigator.pushNamed(
          context, '/navbar'); // Update with the appropriate route
    } catch (e) {
      print('Error saat menyimpan data ke Firestore: $e');
      // Handle error as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: greyBackground,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Align(
              alignment: Alignment.topCenter,
              child: Text(
                "Pilih Profil",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              )),
          Column(
            children: [
              GestureDetector(
                onTap: () => _pickImage(),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                  ),
                  child: _pickedImage != null
                      ? CircleAvatar(
                          backgroundImage: FileImage(File(_pickedImage!.path)),
                          radius: 100,
                        )
                      : const Icon(
                          Icons.account_circle,
                          size: 200,
                          color: Colors.white,
                        ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: buttonIkuti,
                onPressed: () {
                  _saveProfileData();
                },
                child: const Text('Konfirmasi',
                    style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 10),
            ],
          ),
          const SizedBox(
            height: 60,
          )
        ],
      ),
    );
  }
}
