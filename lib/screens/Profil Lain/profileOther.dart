import 'package:ayomasak_2/styles/button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Detail/detail.dart';
import '../FollowersFollowing/followers.dart';
import '../FollowersFollowing/following.dart';

class ElseProfile extends StatefulWidget {
  final String uid;

  const ElseProfile({super.key, required this.uid});

  @override
  State<ElseProfile> createState() => _ElseProfileState();
}

class _ElseProfileState extends State<ElseProfile> {
  late bool isFollowing;
  late int followersCount;
  late int followingCount;
  late int totalRecipesCount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;
          String nama = userData['name'] ?? '';
          String imageUrl = userData['profile_image_url'] ?? '';

          return SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(imageUrl),
                    ),
                  ),
                  Text(
                    nama,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 70),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FollowersPage(
                userId: widget.uid,
              ),
            ),
          );
        },
        child:  Text('$followersCount Pengikut',style: const TextStyle(fontSize: 10,fontWeight: FontWeight.w700,color: Colors.black)),
      ),
                        Text('$totalRecipesCount Resep', style: const TextStyle(fontSize: 10,fontWeight: FontWeight.w700)),
                        TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FollowingPage(
                userId: widget.uid,
              ),
            ),
          );
        },
        child:  Text('$followingCount Mengikuti', style: const TextStyle(fontSize: 10,fontWeight: FontWeight.w700,color: Colors.black))
      ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10,),
                  ElevatedButton(
                    style: isFollowing ? buttonBerhentiIkuti : buttonIkuti,
                    onPressed: () {
                      toggleFollowStatus();
                    },
                    child: Text(isFollowing ? 'Berhenti Ikuti' : 'Ikuti', style: const TextStyle(color: Colors.white),),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('recipe')
                          .where('ownerUid', isEqualTo: widget.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
              
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
              
                        var recipes = snapshot.data!.docs;
              
                        if (recipes.isEmpty) {
                          return const Center(
                            child: Text('Pengguna ini belum memiliki resep.'),
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
                          itemBuilder: (context, index) {
                            var recipe =
                                recipes[index].data() as Map<String, dynamic>;
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
                    ),
                  ),
                  // Tampilkan informasi tambahan sesuai kebutuhan
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    isFollowing = false;
    followersCount = 0;
    followingCount = 0;
    totalRecipesCount = 0;
    // Inisialisasi status "Ikuti" berdasarkan kondisi saat ini
    checkFollowStatus();
    fetchCounts();
  }

void checkFollowStatus() async {
  // Mendapatkan status saat ini
  final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
  final userDocument = await FirebaseFirestore.instance
      .collection('users')
      .doc(currentUserUid)
      .get();

  setState(() {
    // Mengubah status "Ikuti" berdasarkan hasil snapshot
    final userData = userDocument.data() as Map<String, dynamic>;
    final followingList = List<String>.from(userData['following'] ?? []);
    isFollowing = followingList.contains(widget.uid);
  });
}
void fetchCounts() async {
    final userDocument = await FirebaseFirestore.instance
      .collection('users')
      .doc(widget.uid)
      .get();
    final totalRecipesSnapshot = await FirebaseFirestore.instance
        .collection('recipe')
        .where('ownerUid', isEqualTo: widget.uid)
        .get();

    setState(() {
      followersCount = (userDocument.data()?['followedBy'] as List<dynamic>?)?.length ?? 0;
    followingCount = (userDocument.data()?['following'] as List<dynamic>?)?.length ?? 0;
      totalRecipesCount = totalRecipesSnapshot.size;
    });
  }

  void toggleFollowStatus() async {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    // Periksa apakah sudah mengikuti atau belum
    if (isFollowing) {
      // Berhenti mengikuti
      await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserUid)
        .update({
      'following': FieldValue.arrayRemove([widget.uid])
    });

      await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .update({
      'followedBy': FieldValue.arrayRemove([currentUserUid])
    });
    } else {
      // Ikuti
      await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserUid)
        .update({
      'following': FieldValue.arrayUnion([widget.uid])
    });

      await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .update({
      'followedBy': FieldValue.arrayUnion([currentUserUid])
    });
    }

    // Perbarui status "Ikuti"
    setState(() {
      isFollowing = !isFollowing;
    });
    fetchCounts();
  }
  
}
