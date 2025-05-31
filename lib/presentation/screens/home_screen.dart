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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<CatProvider>(context, listen: false).fetchNewCat();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final catProvider = Provider.of<CatProvider>(context);

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
        child:
            catProvider.currentCat == null
                ? CircularProgressIndicator()
                : CatCard(),
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
