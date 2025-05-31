import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../domain/models/cat.dart';
import 'connectivity_service.dart';

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  static const String baseUrl = "https://api.thecatapi.com/v1";
  final ConnectivityService _connectivityService = ConnectivityService();

  Future<Cat> fetchRandomCat() async {
    if (!_connectivityService.isConnected) {
      throw NetworkException('No internet connection');
    }

    try {
      await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 2));
    } catch (e) {
      _connectivityService.setOffline();
      throw NetworkException('No internet connection');
    }

    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/images/search?has_breeds=true'),
            headers: {
              'x-api-key':
                  'live_Fo0aiwRuHNo5DIBB7FJVRrXn7GUvjJ92ieh1VLjTPT2uY1eJpmv3rw4IFRBLd5Hg',
            },
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)[0];

        if (data.isNotEmpty) {
          return Cat.fromJson(data);
        } else {
          throw NetworkException('No cat data found');
        }
      } else {
        throw NetworkException(
          'Failed to load cat image: ${response.statusCode}',
        );
      }
    } on SocketException {
      _connectivityService.setOffline();
      throw NetworkException('No internet connection');
    } on TimeoutException {
      _connectivityService.setOffline();
      throw NetworkException('Connection timeout');
    } catch (e) {
      throw NetworkException('Failed to fetch cat: ${e.toString()}');
    }
  }

  bool get isConnected => _connectivityService.isConnected;

  Stream<bool> get connectionStatus => _connectivityService.connectionStatus;
}
