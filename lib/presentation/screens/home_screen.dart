import 'package:cats_tinder/presentation/screens/liked_cats_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cat_provider.dart';
import '../widgets/cat_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  bool _previousOfflineState = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final catProvider = Provider.of<CatProvider>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (catProvider.isOffline != _previousOfflineState) {
        _previousOfflineState = catProvider.isOffline;

        if (catProvider.isOffline && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.signal_wifi_off, color: Colors.white),
                  SizedBox(width: 10),
                  Text('You are offline. Showing cached content.'),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        } else if (!catProvider.isOffline && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.wifi, color: Colors.white),
                  SizedBox(width: 10),
                  Text('You are back online!'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'kototinder',
          style: TextStyle(
            color: const Color.fromARGB(255, 223, 105, 144),
            fontSize: 26.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(
              catProvider.isOffline ? Icons.signal_wifi_off : Icons.wifi,
              color: catProvider.isOffline ? Colors.orange : Colors.green,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LikedCatsScreen()),
                ),
          ),
        ],
      ),
      body: Center(
        child: Builder(
          builder: (context) {
            if (catProvider.isOffline) {
              if (catProvider.likedCats.isNotEmpty) {
                if (catProvider.currentCat != null) {
                  return CatCard();
                }

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.signal_wifi_off, size: 48, color: Colors.orange),
                    SizedBox(height: 16),
                    Text(
                      'You are offline',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'You can view your liked cats:',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LikedCatsScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Text('View Liked Cats'),
                    ),
                  ],
                );
              } else {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.signal_wifi_off, size: 64, color: Colors.orange),
                    SizedBox(height: 16),
                    Text(
                      'You are offline',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'No cached cats available',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Please connect to the internet\nto see new cats',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                );
              }
            }

            if (catProvider.currentCat != null) {
              return CatCard();
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Loading cats...',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Provider.of<CatProvider>(context).errorMessage != null && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorDialog(context);
      });
    }
  }

  void _showErrorDialog(BuildContext context) {
    final errorMessage = Provider.of<CatProvider>(context).errorMessage;
    if (!mounted || errorMessage == null) return;

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Error'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () {
                  Provider.of<CatProvider>(context, listen: false).clearError();
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
