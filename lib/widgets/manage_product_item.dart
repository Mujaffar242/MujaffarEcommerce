import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/product.dart';
import 'package:flutter_complete_guide/providers/products.dart';
import 'package:flutter_complete_guide/screens/edit_product_screen.dart';
import 'package:provider/provider.dart';

class ManageProductItem extends StatelessWidget {
  Product product;

  ManageProductItem(this.product);

  @override
  Widget build(BuildContext context) {

    var scaffold=Scaffold.of(context);

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(product.imageUrl),
      ),
      title: Text(product.title),
      trailing: Container(width:100,child: Row(mainAxisAlignment:MainAxisAlignment.spaceEvenly,children: <Widget>[
        IconButton(icon: Icon(Icons.edit),onPressed: (){
          Navigator.of(context).pushNamed(EditProductScreen.routeName,arguments: product.id);
        },),
        IconButton(icon: Icon(Icons.delete),onPressed: ()async{
          try{
           await Provider.of<Products>(context,listen: false).deleteProduct(product.id);
          }
          catch(error){
            scaffold.showSnackBar(SnackBar(content: Text('please try after some time',textAlign: TextAlign.center,),));
          }
        },)
      ],)),
    );
  }
}
