import 'package:cats_tinder/data/api_service.dart';
import 'package:cats_tinder/data/database_service.dart';
import 'package:cats_tinder/data/connectivity_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/providers/cat_provider.dart';
import 'presentation/screens/home_screen.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  getIt.registerSingleton<ApiService>(ApiService());
  getIt.registerSingleton<DatabaseService>(DatabaseService());
  getIt.registerSingleton<ConnectivityService>(ConnectivityService());

  getIt.registerSingleton<CatProvider>(CatProvider(getIt<ApiService>()));

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => getIt<CatProvider>())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kototinder',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}
