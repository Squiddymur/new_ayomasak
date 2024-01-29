import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../styles/color.dart';
import '../Detail/detail.dart';

class Disimpan extends StatefulWidget {
  const Disimpan({super.key});

  @override
  State<Disimpan> createState() => _DisimpanState();
}

class _DisimpanState extends State<Disimpan> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              TextField(
                controller: _searchController,
                onChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
                decoration: InputDecoration(
                  constraints: const BoxConstraints(maxHeight: 45),
                  filled: true,
                  fillColor: greyPrimary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  hintText: "Cari Resep",
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 20),
              _buildBookmarkedRecipes(), // Tambahkan widget untuk menampilkan resep yang di-bookmark
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookmarkedRecipes() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _fetchRecipesFromFirestore(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final recipes = snapshot.data?.docs ?? [];

        if (recipes.isEmpty) {
          return const Center(child: Text('Tidak ada resep yang disimpan'));
        }

        return Expanded(
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200.0,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
            ),
            itemCount: recipes.length,
            itemBuilder: (BuildContext context, int index) {
              var recipe = recipes[index].data();
              var documentId = recipes[index].id;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Detail(
                        documentId: documentId,
                        recipe: recipe,
                      ),
                    ),
                  );
                },
                child: Column(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      height: 145,
                      width: 145,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        image: DecorationImage(
                          image: NetworkImage(recipe['imageUrl']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Text(recipe['title'])
                ],
              ),
              );
            },
          ),
        );
      },
    );
  }
  Stream<QuerySnapshot<Map<String, dynamic>>> _fetchRecipesFromFirestore() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    Query query = FirebaseFirestore.instance.collection('recipe');
    if (_searchQuery.isNotEmpty) {
      query = query
          .where('title', isGreaterThanOrEqualTo: _searchQuery)
          .where('title', isLessThanOrEqualTo: '${_searchQuery}z');
    }

    return query
    .where('bookmarkedBy', arrayContains: userId)
    .orderBy('title')
    .snapshots(includeMetadataChanges: true)
        as Stream<QuerySnapshot<Map<String, dynamic>>>;
  }
}