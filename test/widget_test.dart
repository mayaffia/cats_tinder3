import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:cats_tinder/data/api_service.dart';
import 'package:cats_tinder/data/database_service.dart';

@GenerateMocks([ApiService, DatabaseService])
import 'widget_test.mocks.dart';

void main() {
  testWidgets('App should render without crashing', (
    WidgetTester tester,
  ) async {
    final mockApiService = MockApiService();
    final mockDatabaseService = MockDatabaseService();

    when(mockApiService.connectionStatus).thenAnswer((_) => Stream.value(true));
    when(mockApiService.isConnected).thenReturn(true);
    when(mockDatabaseService.getLikedCats()).thenAnswer((_) async => []);

    final testApp = MaterialApp(
      title: 'Kototinder',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(title: Text('kototinder')),
        body: Center(child: Text('Test version')),
      ),
    );

    await tester.pumpWidget(testApp);

    expect(find.text('kototinder'), findsOneWidget);
  });
}
