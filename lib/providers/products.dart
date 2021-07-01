import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/models/http_exeption.dart';
import 'package:http/http.dart' as http;

import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];

  String _authToken;

  String _userId;

  Products(this._authToken, this._items, this._userId);

  // var _showFavoritesOnly = false;

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  Future<void> addProduct(Product product) async {
    notifyListeners();

    Map<String, Object> productMap = {
      'title': product.title,
      'description': product.description,
      'price': product.price,
      'imageUrl': product.imageUrl,
      'isFavorite': product.isFavorite,
      'creatorId': _userId,
    };

    final url =
        'https://demoapp-6f4d9.firebaseio.com/products.json?auth=$_authToken';
    try {
      final responce = await http.post(url, body: json.encode(productMap));
      print(responce.body);
      Product newProduct = Product(
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl,
          id: jsonDecode(responce.body)['name']);
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }

    /*.catchError((error) {

    });*/
  }

  Future<Void> updateProduct(Product product) async {
    //get index of that product

    final url =
        'https://demoapp-6f4d9.firebaseio.com/products/${product.id}.json?auth=$_authToken';
    await http.patch(url,
        body: jsonEncode({
          'title': product.title,
          'imageUrl': product.imageUrl,
          'description': product.description,
          'price': product.price
        }));
    var productIndex = _items.indexWhere((element) => element.id == product.id);
    _items[productIndex] = product;
    notifyListeners();
  }

  Future<Void> deleteProduct(String productId) async {
    var existingIndex = _items.indexWhere((element) => element.id == productId);
    var existingProduct = _items[existingIndex];
    _items.removeWhere((element) => element.id == productId);
    notifyListeners();

    final url =
        'https://demoapp-6f4d9.firebaseio.com/products/$productId.json?auth=$_authToken';
    var responce = await http.delete(url);
    if (responce.statusCode >= 400) {
      _items.insert(existingIndex, existingProduct);
      notifyListeners();
      throw HttpExeption('something went wrong');
    }
    existingProduct = null;
  }

  Future<void> fetchAndSetProducts([filter=false]) async {

    var filterdString='';
    if(filter)
      filterdString='orderBy="creatorId"&equalTo="$_userId"';

    var url =
        'https://demoapp-6f4d9.firebaseio.com/products.json?auth=$_authToken&$filterdString';

    try {
      final responce = await http.get(url);
      final responceMap = json.decode(responce.body) as Map<String, dynamic>;

      url =
          'https://demoapp-6f4d9.firebaseio.com/favoriteProducts/$_userId.json?auth=$_authToken';

      final favoriteResponce = await http.get(url);

      final favoriteData = jsonDecode(favoriteResponce.body);

      List<Product> lodedProducts = [];

      responceMap.forEach((productId, productData) {
        lodedProducts.add(Product(
            id: productId,
            price: productData['price'],
            imageUrl: productData['imageUrl'],
            description: productData['description'],
            isFavorite:
                favoriteData == null ? false : favoriteData[productId] ?? false,
            title: productData['title']));
      });

      _items = lodedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}
