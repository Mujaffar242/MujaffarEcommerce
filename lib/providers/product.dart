import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_complete_guide/models/http_exeption.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavoriteStatus(String authToken, String userId) async {
    isFavorite = !isFavorite;
    notifyListeners();

    final url =
        'https://demoapp-6f4d9.firebaseio.com/favoriteProducts/$userId/$id.json?auth=$authToken';
    final respoce = await http.put(url, body: jsonEncode(isFavorite));
    if (respoce.statusCode >= 400) {
      isFavorite = !isFavorite;
      notifyListeners();
      throw HttpExeption('something went wrong');
    }
  }
}
