import 'package:flutter/material.dart';
import '../styles/button.dart';

class GetStarted extends StatelessWidget {
  const GetStarted({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 60, left: 20),
                child: Image.asset(
                  'images/Layer 2.png',
                  height: 300,
                  width: 300,
                  fit: BoxFit.contain,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 90, top: 50),
                child: Text('Selamat datang di',
                    style: TextStyle(
                        fontSize: 24, color: Color.fromARGB(255, 86, 134, 23))),
              ),
              const Padding(
                padding: EdgeInsets.only(
                  right: 177,
                ),
                child: Text('ayomasak',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 86, 134, 23))),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 20, right: 137),
                child: Text('temukan resep yang',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 127),
                child: Text('sempurna dan praktis',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
              ),
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 110),
                  child: ElevatedButton(
                      style: buttonPrimary,
                      onPressed: () {
                        Navigator.pushNamed(context, '/loginregister');
                      },
                      child: const Text(
                        'Mulai',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      )),
                ),
              )
            ],
          ),
        ));
  }
}
