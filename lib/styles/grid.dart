import 'package:flutter/material.dart';

import 'Text.dart';

class MyViewList extends StatelessWidget {
  final String documentId;
  final Map<String, dynamic> recipe;

  const MyViewList({super.key, required this.documentId, required this.recipe});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 181.35,
            height: 176.55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              image: DecorationImage(
                image: NetworkImage(recipe['imageUrl']),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(5, 5),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              recipe['title'],
              style: judulView,
            ),
          ),
          Row(
            children: [
              Text(
                'Resep dibuat oleh: ',
                style: hintTextView,
              ),
              Text(
                recipe['ownerName'],
                style: resepPembuatView,
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(recipe['time'], style: hintTextView),
          )
        ],
      ),
    );
  }
}
