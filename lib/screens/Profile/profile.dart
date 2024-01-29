import 'package:ayomasak_2/screens/Profile/Components/body.dart';
import 'package:ayomasak_2/screens/Profile/Components/header.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Profil extends StatefulWidget {
  const Profil({super.key});

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    User user = FirebaseAuth.instance.currentUser!;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  _showLogoutConfirmationDialog(context);
                },
                icon: const Icon(
                  Icons.logout_outlined,
                  color: Colors.red,
                ))
          ],
        ),
        body: ListView(
          children: [
            ProfilHeader(
              uid: user.uid,
            ),
            const ProfilResep()
          ],
        ),
      ),
    );
  }

  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Log Out'),
              onPressed: () async {
                // Perform the log out action
                await _auth.signOut().then((value) =>
                    Navigator.pushReplacementNamed(context, '/loginregister'));

                // Navigate to the login or home screen after logout
                // Example:
                // Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        );
      },
    );
  }
}