import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/widgets/main_drawer.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = 'orders-screen';

  /*@override
  _OrdersScreenState createState() => _OrdersScreenState();
}*/

/*class _OrdersScreenState extends State<OrdersScreen> {
  var isLoading = false;

  @override
  void initState() {
    Future.delayed(Duration.zero).then((value) async {
      setState(() {
        isLoading = true;
      });

      await Provider.of<Orders>(context, listen: false).fetchAndSetOrders();

      setState(() {
        isLoading = false;
      });
    });

    // TODO: implement initState
    super.initState();
  }*/

  @override
  Widget build(BuildContext context) {
    // final orderData = Provider.of<Orders>(context);
    return Scaffold(
        drawer: AppDrawer(),
        appBar: AppBar(
          title: Text('Your Orders'),
        ),
        body:
            /*isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: orderData.orders.length,
              itemBuilder: (ctx, i) => OrderItem(orderData.orders[i]),
            )*/
            FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.error != null) {
              return Center(
                child: Text('error'),
              );
            } else {
              return Consumer<Orders>(
                builder: (context, orderData, ch) {
                  return ListView.builder(
                    itemCount: orderData.orders.length,
                    itemBuilder: (ctx, i) => OrderItem(orderData.orders[i]),
                  );
                },
              );
            }
          },
          future:
              Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
        ));
  }
}
