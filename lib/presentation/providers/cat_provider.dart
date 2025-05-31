import 'package:cats_tinder/data/api_service.dart';
import 'package:cats_tinder/data/database_service.dart';
import 'package:cats_tinder/domain/models/cat.dart';
import 'package:flutter/material.dart';

class CatProvider with ChangeNotifier {
  final ApiService _apiService;
  DatabaseService _databaseService = DatabaseService();

  set databaseService(DatabaseService service) {
    _databaseService = service;
  }

  Cat? _currentCat;
  List<Cat> _likedCats = [];
  String _filterBreed = 'all';
  List<String> _availableBreeds = [];
  bool _isOffline = false;
  int _currentOfflineCatIndex = 0;

  CatProvider(this._apiService) {
    _isOffline = !_apiService.isConnected;

    _loadLikedCatsFromDatabase();

    _apiService.connectionStatus.listen((isConnected) {
      bool wasOffline = _isOffline;
      _isOffline = !isConnected;

      if (!wasOffline && _isOffline) {
        if (_likedCats.isNotEmpty) {
          _currentOfflineCatIndex = 0;
          _currentCat = _likedCats[_currentOfflineCatIndex];
        }
        notifyListeners();
      } else if (wasOffline && !_isOffline) {
        if (_currentCat == null) {
          fetchNewCat();
        }
        notifyListeners();
      }
    });
  }

  Cat? get currentCat => _currentCat;
  int get likes => _likedCats.length;
  List<Cat> get likedCats => _likedCats;
  List<String> get availableBreeds => _availableBreeds;
  String get filterBreed => _filterBreed;
  bool get isOffline => _isOffline;
  int get currentOfflineCatIndex => _currentOfflineCatIndex;

  Future<void> _loadLikedCatsFromDatabase() async {
    try {
      _likedCats = await _databaseService.getLikedCats();
      _updateAvailableBreeds();

      if (_isOffline && _likedCats.isNotEmpty && _currentCat == null) {
        _currentOfflineCatIndex =
            _currentOfflineCatIndex < _likedCats.length
                ? _currentOfflineCatIndex
                : 0;
        _currentCat = _likedCats[_currentOfflineCatIndex];
      } else if (!_isOffline && _currentCat == null) {
        fetchNewCat();
      }

      notifyListeners();
    } catch (e) {
      if (e.toString().contains('databaseFactory not initialized')) {
        _likedCats = [];
        _updateAvailableBreeds();
      } else {
        _errorMessage = 'Failed to load liked cats: ${e.toString()}';
      }
      notifyListeners();
    }
  }

  void nextOfflineCat() {
    if (_likedCats.isEmpty) return;

    _currentOfflineCatIndex = (_currentOfflineCatIndex + 1) % _likedCats.length;
    _currentCat = _likedCats[_currentOfflineCatIndex];
    notifyListeners();
  }

  void previousOfflineCat() {
    if (_likedCats.isEmpty) return;

    _currentOfflineCatIndex =
        (_currentOfflineCatIndex - 1 + _likedCats.length) % _likedCats.length;
    _currentCat = _likedCats[_currentOfflineCatIndex];
    notifyListeners();
  }

  Future<void> fetchNewCat() async {
    if (_isOffline) {
      if (_likedCats.isNotEmpty) {
        nextOfflineCat();
      }
      return;
    }

    try {
      if (!_isOffline) {
        _currentCat = null;
        notifyListeners();
      }

      final newCat = await _apiService.fetchRandomCat();
      _currentCat = newCat;
      notifyListeners();
    } catch (e) {
      if (e.toString().contains('No internet connection') ||
          e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException')) {
        _isOffline = true;

        if (_likedCats.isNotEmpty) {
          _currentOfflineCatIndex = 0;
          _currentCat = _likedCats[_currentOfflineCatIndex];
        }
      } else {
        _errorMessage = e.toString();
      }
      notifyListeners();
    }
  }

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  void clearError() => _errorMessage = null;

  Future<void> likeCat() async {
    if (_currentCat != null) {
      _likedCats.add(_currentCat!);

      try {
        await _databaseService.insertCat(_currentCat!);
      } catch (e) {
        _errorMessage = 'Failed to save liked cat: ${e.toString()}';
      }

      _updateAvailableBreeds();
      notifyListeners();

      if (!_isOffline) {
        fetchNewCat();
      }
    }
  }

  void dislikeCat() {
    if (_isOffline && _likedCats.isNotEmpty) {
      nextOfflineCat();
    } else {
      fetchNewCat();
    }
  }

  Future<void> removeLikedCat(Cat cat) async {
    _likedCats.removeWhere((c) => c.id == cat.id);

    try {
      await _databaseService.deleteCat(cat.id);
    } catch (e) {
      _errorMessage = 'Failed to remove cat: ${e.toString()}';
    }

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
