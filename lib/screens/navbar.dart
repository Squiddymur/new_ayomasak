import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../styles/color.dart';
import 'Bookmark/bookmark.dart';
import 'Create/create.dart';
import 'Home/home.dart';
import 'Profile/profile.dart';
import 'Search/search.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _Navbar();
}

class _Navbar extends State<Navbar> {
  int currentPageIndex = 0;

  final labelBehavior = NavigationDestinationLabelBehavior.onlyShowSelected;

  

  @override 
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
      print('onWillPop called'); // Add this line for debugging

      // Show exit confirmation dialog
      bool exitConfirmed = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Tidak'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Ya'),
            ),
          ],
        ),
      );

      // If user confirms exit or dialog is dismissed, exit the app
      if (exitConfirmed) {
        SystemNavigator.pop();
        return true; // Return true to prevent further handling
      }

      return false; // Return false to allow normal back navigation
    },
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          backgroundColor: greenPrimary,
          foregroundColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyCreate()),
            );
          },
          child: const Icon(Icons.add),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
              border: Border(top: BorderSide(color: greyPrimary, width: 0.5))),
          child: NavigationBar(
            elevation: 0,
            height: 70,
            labelBehavior: labelBehavior,
            onDestinationSelected: (int index) {
              setState(() {
                currentPageIndex = index;
              });
            },
            indicatorColor: greenPrimary,
            backgroundColor: Colors.white,
            selectedIndex: currentPageIndex,
            destinations: const [
              NavigationDestination(
                selectedIcon: Icon(
                  Icons.home,
                  color: Colors.white,
                ),
                icon: Icon(Icons.home_outlined),
                label: 'Beranda',
              ),
              NavigationDestination(
                selectedIcon: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                icon: Icon(Icons.search_outlined),
                label: 'Cari',
              ),
              NavigationDestination(
                selectedIcon: Icon(
                  Icons.bookmark,
                  color: Colors.white,
                ),
                icon: Icon(Icons.bookmark_outline),
                label: 'Disimpan',
              ),
              NavigationDestination(
                selectedIcon: Icon(
                  Icons.person,
                  color: Colors.white,
                ),
                icon: Icon(Icons.person_outline),
                label: 'Profil',
              ),
            ],
          ),
        ),
        body: <Widget>[
          const Home(),
          const Cari(),
          const Disimpan(),
          const Profil()
        ][currentPageIndex],
      ),
    );
  }
}