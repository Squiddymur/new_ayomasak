import 'package:flutter/material.dart';

import 'Text.dart';

class Item extends StatelessWidget {
  final String documentId;
  final Map<String, dynamic> recipe;

  const Item({super.key, required this.recipe, required this.documentId});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      width: MediaQuery.of(context).size.width,
      height: 83,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(5, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 83,
            height: 83,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              image: DecorationImage(
                image: NetworkImage(recipe["imageUrl"]),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe['title'],
                  style: judulList,
                ),
                Row(
                  children: [
                    Text("Resep oleh: ", style: hintTextList),
                    Text(
                      recipe['ownerName'],
                      style: resepPembuatList,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                Text(
                  recipe['time'],
                  style: hintTextList,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
