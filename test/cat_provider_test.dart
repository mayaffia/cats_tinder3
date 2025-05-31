import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:cats_tinder/data/api_service.dart';
import 'package:cats_tinder/data/database_service.dart';
import 'package:cats_tinder/domain/models/cat.dart';
import 'package:cats_tinder/presentation/providers/cat_provider.dart';

@GenerateMocks([ApiService, DatabaseService])
import 'cat_provider_test.mocks.dart';

void main() {
  late MockApiService mockApiService;
  late MockDatabaseService mockDatabaseService;
  late CatProvider catProvider;
  late Cat testCat;

  setUp(() {
    mockApiService = MockApiService();
    mockDatabaseService = MockDatabaseService();

    when(mockApiService.connectionStatus).thenAnswer((_) => Stream.value(true));

    when(mockApiService.isConnected).thenReturn(true);

    when(mockDatabaseService.getLikedCats()).thenAnswer((_) async => []);

    catProvider = CatProvider(mockApiService);

    catProvider.databaseService = mockDatabaseService;

    testCat = Cat(
      id: 'test-id',
      url: 'https://example.com/cat.jpg',
      breedName: 'Test Breed',
      breedDescription: 'This is a test cat',
      dateLiked: DateTime.now(),
    );
  });

  group('CatProvider Like/Dislike Tests', () {
    test('likeCat should add cat to liked cats list', () async {
      when(mockApiService.fetchRandomCat()).thenAnswer((_) async => testCat);
      when(mockDatabaseService.insertCat(any)).thenAnswer((_) async => 1);

      await catProvider.fetchNewCat();
      await catProvider.likeCat();

      expect(catProvider.likedCats.length, 1);
      expect(catProvider.likedCats.first.id, testCat.id);
      expect(catProvider.likes, 1);
    });

    test('dislikeCat should fetch a new cat', () async {
      Cat secondCat = Cat(
        id: 'second-cat',
        url: 'https://example.com/cat2.jpg',
        breedName: 'Second Breed',
        breedDescription: 'This is another test cat',
        dateLiked: DateTime.now(),
      );

      when(mockApiService.fetchRandomCat()).thenAnswer((_) async => testCat);

      await catProvider.fetchNewCat();
      expect(catProvider.currentCat?.id, testCat.id);

      when(mockApiService.fetchRandomCat()).thenAnswer((_) async => secondCat);

      catProvider.dislikeCat();

      await Future.delayed(Duration.zero);

      expect(catProvider.currentCat?.id, secondCat.id);
    });

    test('removeLikedCat should remove cat from liked cats list', () async {
      when(mockApiService.fetchRandomCat()).thenAnswer((_) async => testCat);
      when(mockDatabaseService.insertCat(any)).thenAnswer((_) async => 1);
      when(mockDatabaseService.deleteCat(any)).thenAnswer((_) async => {});

      await catProvider.fetchNewCat();
      await catProvider.likeCat();
      expect(catProvider.likedCats.length, 1);

      await catProvider.removeLikedCat(testCat);

      expect(catProvider.likedCats.length, 0);
      expect(catProvider.likes, 0);
    });
  });

  group('Offline Mode Tests', () {
    test('should handle offline mode gracefully', () async {
      when(mockApiService.isConnected).thenReturn(false);
      when(
        mockApiService.fetchRandomCat(),
      ).thenThrow(NetworkException('No internet connection'));

      await catProvider.fetchNewCat();

      expect(catProvider.isOffline, true);
      expect(catProvider.currentCat, null);
      expect(catProvider.errorMessage, null);
    });
  });
}
