import 'package:flutter/material.dart';

class News extends StatelessWidget {
  final String? title, isi, image;
  const News({super.key, this.title, this.image, this.isi});

  get length => null;
  @override
  // News widget
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120, // Batasi lebar
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            width: 175,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: NetworkImage(image ?? ''),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title ?? '',
            maxLines: 2,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
