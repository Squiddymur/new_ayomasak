import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../styles/Text.dart';
import '../../../styles/button.dart';
import '../../FollowersFollowing/followers.dart';
import '../../FollowersFollowing/following.dart';
import '../profile_edit.dart';

class ProfilHeader extends StatefulWidget {
  final String uid;
  const ProfilHeader({super.key, required this.uid});

  @override
  State<ProfilHeader> createState() => _ProfilHeaderState();
}

class _ProfilHeaderState extends State<ProfilHeader> {
    late StreamController<int> _controller;
    @override
  void initState() {
    super.initState();
    // Inisialisasi StreamController
    _controller = StreamController<int>();
  }
    Stream<int> _fetchTotalRecipes() {
    final currentUserUID = FirebaseAuth.instance.currentUser?.uid;
    try {
      // Melakukan query ke Firestore untuk mendapatkan jumlah resep
      FirebaseFirestore.instance
          .collection('recipe')
          .where('ownerUid', isEqualTo: currentUserUID)
          .snapshots()
          .listen((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
        // Mengirimkan jumlah resep ke dalam stream
        _controller.add(querySnapshot.size);
      }, onError: (error) {
        print('Error fetching total recipes: $error');
        // Mengirimkan nilai 0 jika terjadi error
        _controller.add(0);
      });

      // Mengembalikan stream dari controller
      return _controller.stream;
    } catch (error) {
      print('Error fetching total recipes: $error');
      // Mengembalikan stream dengan nilai 0 jika terjadi error
      return Stream<int>.value(0);
    }
  }

  @override
  void dispose() {
    // Menutup StreamController saat widget di dispose
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance.collection('users').doc(widget.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Loading state
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Error state
          return Text('Error: ${snapshot.error}');
        } else {
          // Data loaded successfully
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          String nama = userData['name'] ??
              ''; // Ganti 'nama' dengan field yang sesuai di Firestore
          String imageUrl = userData['profile_image_url'] ??
              ''; // Ganti 'image_url' dengan field yang sesuai di Firestore

                    List<dynamic> followers = userData['followedBy'] ?? [];
          List<dynamic> following = userData['following'] ?? [];

          return Column(
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
                style: judulDetail,
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
                  child: Text('${followers.length} Pengikut',style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 10,color: Colors.black),),),
                    StreamBuilder(
                stream: _fetchTotalRecipes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    int totalRecipes = snapshot.data!;
                    return Text('$totalRecipes Resep',style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),);
                  }
                },
              ),
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
                child: Text(' ${following.length} Mengikuti',style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 10,color: Colors.black)),)
                  ],
                ),
              ),
              ElevatedButton(
                style: buttonIkuti,
                onPressed: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => EditProfile(uid: uid),
                  //     ));
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditProfile(
                                uid: widget.uid,
                                dataDiri: userData,
                              )));
                },
                child: const Text(
                  'Edit Profil',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          );
        }
      },
    );
  }
}
