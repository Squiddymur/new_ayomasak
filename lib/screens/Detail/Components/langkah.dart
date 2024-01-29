import 'package:flutter/material.dart';

import '../../../styles/Text.dart';
import '../../../styles/color.dart';

class Langkah extends StatelessWidget {
  final Map<String, dynamic> recipeDetails;

  const Langkah({required this.recipeDetails, super.key});

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
            const Text('Langkah',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(
              height: 10,
            ),
            ListView.builder(
              itemCount: recipeDetails['steps'].length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: greyPrimary,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text('${index + 1}'),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              child: Text(
                                '${recipeDetails['steps'][index]}',
                                style: bahanMakanan,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      )
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
