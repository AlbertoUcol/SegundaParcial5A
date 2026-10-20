import 'dart:async';
import 'dart:convert' as convert;
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/product_model.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  static final Uri _productsUri = Uri.parse(
    'https://fakestoreapi.com/products/',
  );

  final http.Client _client;

  Future<List<Product>> fetchProducts() async {
    try {
      final response = await _client
          .get(_productsUri)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != HttpStatus.ok) {
        throw ApiException(
          'No se pudo cargar el catálogo (HTTP ${response.statusCode}).',
        );
      }

      final decoded = convert.jsonDecode(response.body);
      if (decoded is! List) {
        throw const FormatException('La respuesta del catálogo no es válida.');
      }

      return decoded
          .map((item) {
            if (item is! Map<String, dynamic>) {
              throw const FormatException(
                'La respuesta contiene un producto inválido.',
              );
            }
            return Product.fromJson(item);
          })
          .toList(growable: true);
    } on SocketException {
      throw const ApiException(
        'No hay conexión a Internet. Revisa tu red e inténtalo de nuevo.',
      );
    } on TimeoutException {
      throw const ApiException(
        'La conexión tardó demasiado. Inténtalo de nuevo.',
      );
    } on http.ClientException {
      throw const ApiException(
        'No fue posible conectar con el catálogo. Inténtalo de nuevo.',
      );
    } on FormatException {
      throw const ApiException(
        'El catálogo devolvió datos inválidos. Inténtalo más tarde.',
      );
    }
  }
}

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
