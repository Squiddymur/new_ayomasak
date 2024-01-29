import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Header extends StatefulWidget {
  final String uid;
  const Header({super.key, required this.uid});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
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
            String imageUrl = userData['profile_image_url'] ?? ''; // Ganti 'im
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, $nama',
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            'temukan resepmu hari ini',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          )
                        ],
                      ),
                      Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(imageUrl),
                        radius: 20,
                      ),
                    ),
                    ],
                  ),
                ],
              ),
            );
          }
        }
        );
  }
}
