import 'package:flutter/material.dart';

import '../../../styles/Text.dart';

class Bahan extends StatelessWidget {
  final Map<String, dynamic> recipeDetails;

  const Bahan({required this.recipeDetails, super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(5, 5),
            )
          ],
        ),
        child: Column(
          children: [
            const SizedBox(
              height: 15,
            ),
            const Text('Bahan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(
              height: 10,
            ),
            ListView.builder(
              itemCount: recipeDetails['ingredients'].length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ${recipeDetails['ingredients'][index]}',
                        style: bahanMakanan,
                      ),
                      const Divider(),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
