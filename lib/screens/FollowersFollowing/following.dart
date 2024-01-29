// FollowingPage.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Profil Lain/profileOther.dart';
import '../Profile/profile.dart';

class FollowingPage extends StatelessWidget {
  final String userId; // Terima ID pengguna dari konstruktor

  const FollowingPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mengikuti'),
      ),
      body: _buildFollowingList(),
    );
  }

  Widget _buildFollowingList() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>;
        List<dynamic> following = userData['following'] ?? [];

        if (following.isEmpty) {
          return const Center(
            child: Text('Pengguna ini belum mengikuti siapapun.'),
          );
        }

        // Tampilkan daftar yang diikuti
        return ListView.builder(
          itemCount: following.length,
          itemBuilder: (BuildContext context, int index) {
            // Ambil data pengguna berdasarkan ID
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(following[index])
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (userSnapshot.hasError) {
                  return Text('Error: ${userSnapshot.error}');
                }

                var followingData =
                    userSnapshot.data!.data() as Map<String, dynamic>;

                String followerUid = following[index];
              bool isCurrentUser = FirebaseAuth.instance.currentUser?.uid == followerUid;
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage:
                          NetworkImage(followingData['profile_image_url'] ?? ''),
                    ),
                    title: Text(followingData['name'] ?? ''),
                    onTap: () {
                  if (isCurrentUser) {
                    // Jika pengguna yang diklik adalah pengguna sendiri
                    // Navigasi ke halaman profil pengguna sendiri
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const Profil()));
                  } else {
                    // Jika pengguna yang diklik adalah pengguna lain
                    // Navigasi ke halaman profil pengguna lain
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ElseProfile(uid: followerUid)));
                  }
                },
                    // Tambahan informasi atau aksi lainnya sesuai kebutuhan
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
