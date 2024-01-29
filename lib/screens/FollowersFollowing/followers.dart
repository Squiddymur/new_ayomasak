import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Profil Lain/profileOther.dart';
import '../Profile/profile.dart';

class FollowersPage extends StatelessWidget {
  final String userId; // Terima ID pengguna dari konstruktor

  const FollowersPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengikut'),
      ),
      body: _buildFollowersList(),
    );
  }

  Widget _buildFollowersList() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>;
        List<dynamic> followers = userData['followedBy'] ?? [];

        if (followers.isEmpty) {
          return const Center(
            child: Text('Pengguna ini belum memiliki pengikut.'),
          );
        }

        // Tampilkan daftar pengikut
        return ListView.builder(
          itemCount: followers.length,
          itemBuilder: (BuildContext context, int index) {
            // Ambil data pengguna berdasarkan ID
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(followers[index]).get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (userSnapshot.hasError) {
                  return Text('Error: ${userSnapshot.error}');
                }

                var followerData = userSnapshot.data!.data() as Map<String, dynamic>;

                // Tampilkan informasi pengguna (nama, foto profil, dll.)
                String followerUid = followers[index];
              bool isCurrentUser = FirebaseAuth.instance.currentUser?.uid == followerUid;
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(followerData['profile_image_url'] ?? ''),
                    ),
                    title: Text(followerData['name'] ?? ''),
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

