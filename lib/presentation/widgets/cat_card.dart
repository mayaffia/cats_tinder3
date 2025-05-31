import 'package:cats_tinder/presentation/widgets/dislike_button.dart';
import 'package:cats_tinder/presentation/widgets/like_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/cat_provider.dart';
import '../screens/detail_screen.dart';

class CatCard extends StatelessWidget {
  const CatCard({super.key});

  @override
  Widget build(BuildContext context) {
    final catProvider = Provider.of<CatProvider>(context);

    if (catProvider.currentCat == null) {
      return CircularProgressIndicator();
    }

    final cat = catProvider.currentCat!;

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: 20,
          child: Text(
            cat.breedName,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
        ),
        Positioned(
          top: 60,
          child: Dismissible(
            key: Key(cat.id),
            direction: DismissDirection.horizontal,
            onDismissed: (direction) {
              final provider = Provider.of<CatProvider>(context, listen: false);
              if (direction == DismissDirection.startToEnd) {
                provider.likeCat();
              } else {
                provider.dislikeCat();
              }

              provider.fetchNewCat();
            },

            child: SizedBox(
              width: 400.0,
              height: 500.0,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(cat: cat),
                    ),
                  );
                },
                child: ClipRRect(
                  child: CachedNetworkImage(
                    fit: BoxFit.contain,
                    imageUrl: cat.url,
                    placeholder:
                        (context, url) =>
                            Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 80,
          child: Text(
            'Likes: ${catProvider.likes}',
            style: TextStyle(fontSize: 20.0, color: Colors.black),
          ),
        ),
        Positioned(
          bottom: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              DislikeButton(onPressed: () => catProvider.dislikeCat()),
              SizedBox(width: 100),
              LikeButton(
                onPressed: () {
                  final provider = Provider.of<CatProvider>(
                    context,
                    listen: false,
                  );
                  provider.likeCat();
                  provider.fetchNewCat();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
