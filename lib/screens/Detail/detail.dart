import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../styles/Text.dart';
import '../Profil Lain/profileOther.dart';
import '../Update/update.dart';
import 'Components/bahan.dart';
import 'Components/langkah.dart';

class Detail extends StatefulWidget {
  final String documentId;
  final Map<String, dynamic> recipe;
  const Detail({super.key, required this.recipe, required this.documentId});

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  late final FirebaseFirestore _db;
  late Map<String, dynamic> recipe;

  late Stream<DocumentSnapshot> _recipeStream;

  @override
  void initState() {
    recipe = widget.recipe;
    _db = FirebaseFirestore.instance;
    _recipeStream = _db.collection('recipe').doc(widget.documentId).snapshots();
    super.initState();
  }

  Widget _buildDetailWidget(BuildContext context, DocumentSnapshot snapshot) {
    if (!snapshot.exists) {
      return const Center(child: CircularProgressIndicator());
    }

    recipe = snapshot.data() as Map<String, dynamic>;

    return ListView(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 266,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  image: DecorationImage(
                    image: NetworkImage(recipe['imageUrl']),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(5, 5),
                    ),
                  ],
                ),
              ),
            ),
            Text(recipe['title'], style: judulDetail),
            if (!_isOwner()) 
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Resep oleh: ',
                  style: hintTextDetail,
                ),
                GestureDetector(
                  onTap: () {
                              // Navigasi ke profil pemilik resep
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ElseProfile(uid: recipe['ownerUid']),
                                ),
                              );
                            },
                  child: Text(
                    recipe['ownerName'],
                    style: resepPembuatDetail,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              '~ ${recipe['time']}',
              style: hintTextDetail,
            ),
            const SizedBox(
              height: 10,
            ),
            Bahan(recipeDetails: recipe),
            const SizedBox(
              height: 10,
            ),
            Langkah(recipeDetails: recipe),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        actions: [
          StreamBuilder<String?>(
            stream: _getUserDetails(),
            builder: (context, AsyncSnapshot<String?> userIdSnapshot) {
              if (userIdSnapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              final userId = userIdSnapshot.data;

              if (_isOwner()) {
                return Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UpdateRecipe(recipeId: widget.documentId),
                          ),
                        );
                      },
                      child: const Text('Ubah'),
                    ),
                    TextButton(
                      onPressed: () {
                        _showDeleteDialog();
                      },
                      child: const Text('Hapus'),
                    ),
                  ],
                );
              } else {
                return IconButton(
                  onPressed: () {
                      print('Tambah/Remove Bookmark');
                    if (userId != null) {
                      if (recipe['bookmarkedBy']?.contains(userId) ?? false) {
                        // Jika resep sudah di-bookmark, panggil removeBookmark
                        removeBookmark(widget.documentId, userId);
                      } else {
                        // Jika resep belum di-bookmark, panggil addBookmark
                        addBookmark(context, widget.documentId, userId);
                      }
                      // Muat ulang halaman Detail setelah Bookmark diubah
                      setState(() {});
                    }
                  },
                  icon: Icon(
                    recipe['bookmarkedBy']?.contains(userId) ?? false
                        ? Icons.bookmark
                        : Icons.bookmark_add,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _recipeStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return _buildDetailWidget(context, snapshot.data!);
        },
      ),
      )
    );
  }

  bool _isOwner() {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    final ownerUid = recipe['ownerUid'];
    return currentUserUid == ownerUid;
  }
  Future<void> _deleteRecipe() async {
    try {
      await _db.collection('recipe').doc(widget.documentId).delete();
      print('Recipe successfully deleted: ${widget.documentId}');
      if (!context.mounted) return;
      Navigator.pop(context); // Close the detail page after deletion
    } catch (e) {
      print('Error deleting recipe: $e');
    }
  }

  Future<void> _showDeleteDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Resep'),
          content: const Text('Apakah Anda yakin ingin menghapus resep ini?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Hapus'),
              onPressed: () {
                _deleteRecipe();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Stream<String?> _getUserDetails() async* {
    final currentUser = FirebaseAuth.instance.currentUser;
    yield currentUser?.uid;
  }

  // Misalkan ini adalah metode untuk menambahkan bookmark ke resep
  void addBookmark(BuildContext context, String recipeId, String userId) {
    FirebaseFirestore.instance.collection('recipe').doc(recipeId).update({
      'bookmarkedBy': FieldValue.arrayUnion([userId]),
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resep Disimpan'),
          duration: Duration(seconds: 2), // Adjust the duration as needed
        ),
      );
    }).catchError((error) {
      print('Error adding bookmark: $error');
    });
  }

  // Misalkan ini adalah metode untuk menghapus bookmark dari resep
  void removeBookmark(String recipeId, String userId) {
    FirebaseFirestore.instance.collection('recipe').doc(recipeId).update({
      'bookmarkedBy': FieldValue.arrayRemove([userId]),
    });
  }
}