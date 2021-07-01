import 'dart:convert';

import 'package:flutter/foundation.dart';

import './cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  String _authToken;
  String _userId;
  List<OrderItem> get orders {
    return [..._orders];
  }

  Orders(this._authToken,_orders,this._userId);

  Future<void> fetchAndSetOrders() async {
    final url = 'https://demoapp-6f4d9.firebaseio.com/orders/$_userId.json?auth=$_authToken';
    final responce = await http.get(url);

    final ordersMap = jsonDecode(responce.body) as Map<String, dynamic>;

    List<OrderItem>tempList = [];


    ordersMap.forEach((orderId, orderData) {
      OrderItem orderItem = OrderItem(
          id: orderId,
          amount: orderData['amount'],
          products: (orderData['products'] as List<dynamic>)
              .map((item) =>
              CartItem(
                title: item['title'],
                  id: item['id'],
                  quantity: item['quantity'],
                  price: item['price']))
              .toList(),
          dateTime: DateTime.parse(orderData['dateTime']));
      tempList.add(orderItem);
    });

    _orders = tempList;

    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = 'https://demoapp-6f4d9.firebaseio.com/orders/$_userId.json?auth=$_authToken';

    var dateTime = DateTime.now();

    final responce = await http.post(url,
        body: jsonEncode({
          'amount': total,
          'dateTime': dateTime.toIso8601String(),
          'products': cartProducts
              .map((cartItem) =>
          {
            'title': cartItem.title,
            'price': cartItem.price,
            'id': cartItem.id,
            'quantity': cartItem.quantity
          })
              .toList()
        }));
    _orders.insert(
      0,
      OrderItem(
        id: jsonDecode(responce.body)['name'],
        amount: total,
        dateTime: dateTime,
        products: cartProducts,
      ),
    );
    notifyListeners();
  }
}
