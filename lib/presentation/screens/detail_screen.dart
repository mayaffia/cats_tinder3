import 'package:flutter/material.dart';
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
          children: [
            Image.network(cat.url),
            SizedBox(height: 8.0),
            Text(cat.breedDescription, style: TextStyle(fontSize: 16.0)),
          ],
        ),
      ),
    );
  }
}
