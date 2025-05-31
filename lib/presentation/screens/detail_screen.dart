import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/models/cat.dart';

class DetailScreen extends StatelessWidget {
  final Cat cat;

  const DetailScreen({super.key, required this.cat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(cat.breedName)),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: CachedNetworkImage(
                imageUrl: cat.url,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(
                      height: 300,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      height: 300,
                      color: Colors.grey[200],
                      child: const Center(child: Icon(Icons.error, size: 50)),
                    ),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'About ${cat.breedName}',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(cat.breedDescription, style: TextStyle(fontSize: 16.0)),
          ],
        ),
      ),
    );
  }
}
