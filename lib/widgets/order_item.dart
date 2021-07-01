import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/orders.dart' as ord;

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;

  OrderItem(this.order);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {

  var isExpaded=false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text('\$${widget.order.amount}'),
            subtitle: Text(
              DateFormat('dd/MM/yyyy hh:mm').format(widget.order.dateTime),
            ),
            trailing: IconButton(
              icon: Icon(isExpaded?Icons.expand_less:Icons.expand_more),
              onPressed: () {
                setState(() {
                  isExpaded=!isExpaded;
                });
              },
            ),
          ),
          if(isExpaded)Container(height: min(widget.order.products.length*20+10.0,180),
          child: ListView.builder(itemCount: widget.order.products.length,itemBuilder: (ctx,index)=>Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children: <Widget>[
            Text(widget.order.products[index].title)
            ,Text('${widget.order.products[index].price} x ${widget.order.products[index].quantity}')
          ],)),
          )
        ],
      ),
    );
  }
}
