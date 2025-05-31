import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/cat_provider.dart';
import 'package:intl/intl.dart';

class LikedCatsScreen extends StatelessWidget {
  const LikedCatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final catProvider = Provider.of<CatProvider>(context);
    final likedCats = catProvider.likedCats;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '❤️ Liked Cats',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: DropdownButton<String>(
              dropdownColor: const Color.fromARGB(255, 249, 238, 242),
              icon: const Icon(Icons.filter_list, color: Colors.pink),
              underline: const SizedBox(),
              hint: const Text(
                'Filter by breed',
                style: TextStyle(color: Colors.pink),
              ),
              items: [
                ...catProvider.availableBreeds.map(
                  (breed) => DropdownMenuItem(
                    value: breed,
                    child: Text(
                      breed,
                      style: const TextStyle(color: Colors.pink),
                    ),
                  ),
                ),
                const DropdownMenuItem(
                  value: 'all',
                  child: Text(
                    'All breeds',
                    style: TextStyle(color: Colors.pink),
                  ),
                ),
              ],
              onChanged: (value) => catProvider.setFilterBreed(value ?? 'all'),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: likedCats.length,
        itemBuilder: (context, index) {
          final cat = likedCats[index];
          if (catProvider.filterBreed != 'all' &&
              cat.breedName != catProvider.filterBreed) {
            return const SizedBox.shrink();
          }

          return Dismissible(
            key: Key(cat.id),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20.0),
              child: const Icon(Icons.delete, color: Colors.white, size: 40),
            ),
            onDismissed: (_) => catProvider.removeLikedCat(cat),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: CachedNetworkImage(
                              imageUrl: cat.url,
                              width: double.infinity,
                              height: 180,
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) => Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) =>
                                      const Icon(Icons.error),
                            ),
                          ),
                          Container(
                            height: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  // Colors.black.withOpacity(0.7),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 16,
                            bottom: 16,
                            child: Text(
                              cat.breedName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    blurRadius: 10.0,
                                    color: Colors.black,
                                    offset: Offset(2.0, 2.0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Icon(Icons.pets, color: Colors.pink[300], size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Breed: ${cat.breedName}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Text(
                        cat.breedDescription,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.date_range,
                                color: Colors.pink[300],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat(
                                  'MMM dd, yyyy – HH:mm',
                                ).format(cat.dateLiked),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
