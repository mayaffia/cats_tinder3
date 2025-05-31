import 'package:cats_tinder/data/api_service.dart';
import 'package:cats_tinder/domain/models/cat.dart';
import 'package:flutter/material.dart';

class CatProvider with ChangeNotifier {
  final ApiService _apiService;
  Cat? _currentCat;
  int _likes = 0;
  final List<Cat> _likedCats = [];
  String _filterBreed = 'all';
  List<String> _availableBreeds = [];

  CatProvider(this._apiService);

  Cat? get currentCat => _currentCat;
  int get likes => _likes;
  List<Cat> get likedCats => _likedCats;
  List<String> get availableBreeds => _availableBreeds;
  String get filterBreed => _filterBreed;

  Future<void> fetchNewCat() async {
    try {
      _currentCat = null;
      notifyListeners();

      final newCat = await _apiService.fetchRandomCat();
      _currentCat = newCat;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  void clearError() => _errorMessage = null;

  void likeCat() {
    if (_currentCat != null) {
      _likes++;
      _likedCats.add(_currentCat!);
      _updateAvailableBreeds();
      notifyListeners();
      fetchNewCat;
    }
  }

  void dislikeCat() {
    fetchNewCat();
    notifyListeners();
  }

  void removeLikedCat(Cat cat) {
    _likedCats.remove(cat);
    _updateAvailableBreeds();
    notifyListeners();
  }

  void setFilterBreed(String breed) {
    _filterBreed = breed;
    notifyListeners();
  }

  void _updateAvailableBreeds() {
    _availableBreeds = _likedCats.map((cat) => cat.breedName).toSet().toList();
  }
}
