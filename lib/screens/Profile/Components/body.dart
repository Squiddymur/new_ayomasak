import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../Detail/detail.dart';

class ProfilResep extends StatefulWidget {
  const ProfilResep({super.key});

  @override
  State<ProfilResep> createState() => _ProfilResepState();
}

class _ProfilResepState extends State<ProfilResep> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _fetchRecipesFromFirestore(),
      builder: (context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final recipes = snapshot.data?.docs ?? [];

        if (recipes.isEmpty) {
          return const Center(
            child: Text('Resep Kosong'),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
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
        );
      },
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _fetchRecipesFromFirestore() {
    final currentUserUID = FirebaseAuth.instance.currentUser?.uid;
    print("User ID : $currentUserUID");
    return FirebaseFirestore.instance
        .collection('recipe')
        .where('ownerUid', isEqualTo: currentUserUID)
        .orderBy('timestamp', descending: true)
        .snapshots(includeMetadataChanges: true);
  }
}