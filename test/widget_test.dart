// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:flutter_first5a/main.dart';
import 'package:flutter_first5a/screens/login_screen.dart';
import 'package:flutter_first5a/services/api_service.dart';

void main() {
  testWidgets('login requires a username and password', (tester) async {
    await tester.pumpWidget(const InventoryManagementApp());

    await tester.tap(find.text('Ingresar'));
    await tester.pumpAndSettle();

    expect(find.text('Ingresa tu usuario'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña'), findsOneWidget);
  });

  testWidgets('demo users can sign in and log out', (tester) async {
    final client = MockClient((_) async => http.Response('[]', 200));
    addTearDown(client.close);
    final apiService = ApiService(client: client);
    const users = [
      ('admin', '12345'),
      ('inventario', '67890'),
      ('ventas', '54321'),
      ('bodega', '24680'),
    ];

    await tester.pumpWidget(
      MaterialApp(home: LoginScreen(apiService: apiService)),
    );

    for (final (username, password) in users) {
      await tester.enterText(find.byType(TextFormField).at(0), username);
      await tester.enterText(find.byType(TextFormField).at(1), password);
      await tester.tap(find.text('Ingresar'));
      await tester.pumpAndSettle();

      expect(find.text('Catálogo de productos'), findsOneWidget);

      await tester.tap(find.byTooltip('Cerrar sesión'));
      await tester.pumpAndSettle();

      expect(find.text('¡Qué bueno verte!'), findsOneWidget);
    }
  });
}
