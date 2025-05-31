import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/models/cat.dart';

class ApiService {
  static const String baseUrl = "https://api.thecatapi.com/v1";

  Future<Cat> fetchRandomCat() async {
    final response = await http.get(
      Uri.parse('$baseUrl/images/search?has_breeds=true'),
      headers: {
        'x-api-key':
            'live_Fo0aiwRuHNo5DIBB7FJVRrXn7GUvjJ92ieh1VLjTPT2uY1eJpmv3rw4IFRBLd5Hg',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)[0];

      if (data.isNotEmpty) {
        return Cat.fromJson(data);
      } else {
        throw Exception('No cat data found');
      }
    } else {
      throw Exception('Failed to load cat image: ${response.statusCode}');
    }
  }
}
