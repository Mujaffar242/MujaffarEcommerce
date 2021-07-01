import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/products.dart';
import 'package:flutter_complete_guide/screens/edit_product_screen.dart';
import 'package:flutter_complete_guide/widgets/main_drawer.dart';
import 'package:flutter_complete_guide/widgets/manage_product_item.dart';
import 'package:provider/provider.dart';

class ManageProductScreen extends StatelessWidget {
  static const routeName = 'manage_product';

  Future<void> startRefreshing(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    //final products = Provider.of<Products>(context).items;

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Your Products'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () =>
                  Navigator.of(context).pushNamed(EditProductScreen.routeName))
        ],
      ),
      body: FutureBuilder(
        future: Provider.of<Products>(context, listen: false)
            .fetchAndSetProducts(true),
        builder: (context, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: CircularProgressIndicator(),
            );
          else
            return RefreshIndicator(
              onRefresh: () => startRefreshing(context),
              child: Consumer<Products>(
                builder: (context, products, ch) {
                  return ListView.builder(
                      itemCount: products.items.length,
                      itemBuilder: (ctx, index) =>
                          ManageProductItem(products.items[index]));
                },
              ),
            );
        },
      ),
      drawer: AppDrawer(),
    );
  }
}
