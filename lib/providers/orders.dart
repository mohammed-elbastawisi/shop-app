import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import './cart.dart';

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

class Order with ChangeNotifier {
  List<OrderItem> _orders = [];

  final String orderToken;
  final String userId;

  Order(
    this.orderToken,
    this.userId,
    this._orders,
  );

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url =
        'https://flutter-shop-11754.firebaseio.com/orders/$userId.json?auth=$orderToken';
    final response = await http.get(url);
    List<OrderItem> loadedOrders = [];
//    print(json.decode(response.body));
    final existingOrders = json.decode(response.body) as Map<String, dynamic>;
    if (existingOrders == null) {
      return;
    }
    existingOrders.forEach((orderId, orderData) {
      loadedOrders.add(
        OrderItem(
          id: orderId,
          amount: orderData['amount'],
          dateTime: DateTime.parse(orderData['dateTime']),
          products: (orderData['products'] as List<dynamic>)
              .map((item) => CartItem(
                    id: item['id'],
                    price: item['price'],
                    quantity: item['quantity'],
                    title: item['title'],
                  ))
              .toList(),
        ),
      );
    });
    _orders = loadedOrders;
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProduct, double total) async {
    final timeTamp = DateTime.now();
    final url =
        'https://flutter-shop-11754.firebaseio.com/orders/$userId.json?auth=$orderToken';
    await http.post(
      url,
      body: json.encode({
        'amount': total,
        'dateTime': timeTamp.toIso8601String(),
        'products': cartProduct
            .map((cp) => {
                  'id': cp.id,
                  'title': cp.title,
                  'price': cp.price,
                  'quantity': cp.quantity,
                })
            .toList(),
      }),
    );
    _orders.insert(
      0,
      OrderItem(
        id: timeTamp.toString(),
        amount: total,
        dateTime: DateTime.now(),
        products: cartProduct,
      ),
    );
    notifyListeners();
  }
}
