import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../styles/Text.dart';
import '../../../styles/grid.dart';
import '../../../styles/list.dart';
import '../../Detail/detail.dart';

class HomeResep extends StatefulWidget {
  const HomeResep({Key? key}) : super(key: key);

  @override
  State<HomeResep> createState() => _HomeResepState();
}

class _HomeResepState extends State<HomeResep> {
  late Stream<List<String>> followedUserIdsStream;

  @override
  void initState() {
    super.initState();
    followedUserIdsStream = _fetchFollowedUserIds();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      followedUserIdsStream = _fetchFollowedUserIds();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Text(
                'Diikuti',
                style: kategori,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            _buildHorizontalScroll(),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Text(
                'Terbaru',
                style: kategori,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            _buildVerticalScroll(),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalScroll() {
    return StreamBuilder<List<String>>(
      stream: followedUserIdsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
        }

        if (snapshot.hasError || snapshot.data == null) {
          return const Text('Error: Unable to fetch followed users');
        }

        final followedUserIds = snapshot.data!;
        return _buildRecipesStream(followedUserIds);
      },
    );
  }

  Widget _buildRecipesStream(List<String> followedUserIds) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _fetchRecipesFromFollowedUsers(followedUserIds),
      builder: (context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
        }

        if (snapshot.hasError) {
          return const Text('Error: Unable to fetch recipes');
        }

        final recipes = snapshot.data?.docs ?? [];

        if (recipes.isEmpty) {
          return const Center(
            child: Text('Resep dari akun yang diikuti kosong'),
          );
        }

        return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.31,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
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
                child: MyViewList(
                  recipe: recipe,
                  documentId: documentId,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildVerticalScroll() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _fetchRecipesFromFirestore(),
      builder: (context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
        
        }

        if (snapshot.hasError) {
          return const Text('Error: Unable to fetch recipes');
        }

        final recipes = snapshot.data?.docs ?? [];

        final filteredRecipes = recipes.where((recipe) {
          final ownerUid = recipe['ownerUid'];
          final currentUserUID = FirebaseAuth.instance.currentUser?.uid;
          return ownerUid != currentUserUID;
        }).toList();

        if (filteredRecipes.isEmpty) {
          return const Center(
            child: Text('Resep Kosong'),
          );
        }

        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemCount: filteredRecipes.length,
          itemBuilder: (BuildContext context, int index) {
            var recipe = filteredRecipes[index].data();
            var documentId = filteredRecipes[index].id;
        
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
              child: Item(
                documentId: documentId,
                recipe: recipe,
              ),
            );
          },
        );
      },
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _fetchRecipesFromFirestore() {
    return FirebaseFirestore.instance
        .collection('recipe')
        .orderBy('timestamp', descending: true)
        .snapshots(includeMetadataChanges: true);
  }

Stream<List<String>> _fetchFollowedUserIds() {
  final currentUserUID = FirebaseAuth.instance.currentUser?.uid;
  return FirebaseFirestore.instance
      .collection('users')
      .doc(currentUserUID)
      .snapshots()
      .map((snapshot) {
        var userData = snapshot.data() as Map<String, dynamic>;
        return List<String>.from(userData['following'] ?? []);
      });
}


  Stream<QuerySnapshot<Map<String, dynamic>>> _fetchRecipesFromFollowedUsers(
      List<String>? followedUserIds) {
    if (followedUserIds == null || followedUserIds.isEmpty) {
      return const Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('recipe')
        .where('ownerUid', whereIn: followedUserIds)
        .orderBy('timestamp', descending: true)
        .snapshots(includeMetadataChanges: true);
  }
}
