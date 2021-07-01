import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/providers/product.dart';
import 'package:flutter_complete_guide/providers/products.dart';
import 'package:provider/provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = 'edit_product_screen';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  var priceFocusNode = new FocusNode();

  var decriptionFocusNode = new FocusNode();

  var imageUrlFocusNode = new FocusNode();

  var imageUrlContoller = TextEditingController();

  var isLoding = false;

  final _from = GlobalKey<FormState>();

  var product = new Product(
    id: null,
    title: '',
    description: '',
    price: 0,
    imageUrl: '',
  );

  var isInit = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imageUrlContoller.addListener(updateImageUrl);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies

    if (isInit) {
      String id = ModalRoute.of(context).settings.arguments as String;
      if (id != null) {
        product = Provider.of<Products>(context).findById(id);
        imageUrlContoller.text = product.imageUrl;
      }
      isInit = false;
    }

    super.didChangeDependencies();
  }

  void updateImageUrl() {
    if (!imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    // to avoid the memory leck problem we shold remove all listners on dispose page
    // TODO: implement dispose
    super.dispose();

    imageUrlContoller.removeListener(updateImageUrl);

    priceFocusNode.dispose();
    decriptionFocusNode.dispose();
    imageUrlFocusNode.dispose();
    imageUrlContoller.dispose();
  }

  void _saveFrom() async {
    final isFromValid = _from.currentState.validate();

    if (isFromValid) {
      setState(() {
        isLoding = true;
      });

      _from.currentState.save();
      //  print(product.title+product.price.toString()+product.description+product.imageUrl);

      if (product.id != null) {
        await Provider.of<Products>(context, listen: false)
            .updateProduct(product);
      } else {
        try {
          await Provider.of<Products>(context, listen: false)
              .addProduct(product);
        } catch (error) {
          await showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                    title: Text('An error occur'),
                    content: Text('Please try after some time'),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('Okay'),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                      )
                    ],
                  ));
        }
      }

      setState(() {
        isLoding = false;
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your products'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveFrom,
          )
        ],
      ),
      body: isLoding
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                  key: _from,
                  child: ListView(
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Title'),
                        textInputAction: TextInputAction.next,
                        initialValue: product.title,
                        onFieldSubmitted: (value) =>
                            FocusScope.of(context).requestFocus(priceFocusNode),
                        onSaved: (title) {
                          product = Product(
                              title: title,
                              price: product.price,
                              description: product.description,
                              imageUrl: product.imageUrl,
                              id: product.id,
                              isFavorite: product.isFavorite);
                        },
                        validator: (value) {
                          if (value.isEmpty) return 'Please enter title';
                          return null;
                        },
                      ),
                      TextFormField(
                          decoration: InputDecoration(labelText: 'Price'),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          initialValue: product.price.toString(),
                          validator: (value) {
                            if (value.isEmpty) return 'Please enter price';
                            if (double.tryParse(value) == null)
                              return 'please enter valid price';
                            if (double.parse(value) <= 0)
                              return 'please amount >=0';
                            return null;
                          },
                          focusNode: priceFocusNode,
                          onFieldSubmitted: (_) => FocusScope.of(context)
                              .requestFocus(decriptionFocusNode),
                          onSaved: (price) {
                            product = Product(
                                title: product.title,
                                price: double.parse(price),
                                description: product.description,
                                imageUrl: product.imageUrl,
                                id: product.id,
                                isFavorite: product.isFavorite);
                          }),
                      TextFormField(
                          decoration: InputDecoration(labelText: 'Description'),
                          maxLines: 3,
                          validator: (value) {
                            if (value.isEmpty)
                              return 'Please enter discription';
                            if (value.length <= 10)
                              return 'descriptio is too short!';
                            return null;
                          },
                          keyboardType: TextInputType.multiline,
                          focusNode: decriptionFocusNode,
                          initialValue: product.description,
                          onSaved: (description) {
                            product = Product(
                                title: product.title,
                                price: product.price,
                                description: description,
                                id: product.id,
                                isFavorite: product.isFavorite,
                                imageUrl: product.imageUrl);
                          }),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                            height: 100,
                            width: 100,
                            margin: EdgeInsets.only(right: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(border: Border.all()),
                            child: imageUrlContoller.text.isEmpty
                                ? Text('No image')
                                : Image.network(
                                    imageUrlContoller.text,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                                validator: (value) {
                                  if (value.isEmpty) return 'Please image url';
                                  return null;
                                },
                                decoration:
                                    InputDecoration(labelText: 'Image URL'),
                                textInputAction: TextInputAction.done,
                                focusNode: imageUrlFocusNode,
                                keyboardType: TextInputType.url,
                                controller: imageUrlContoller,
                                onFieldSubmitted: (_) => _saveFrom(),
                                onSaved: (imageUrl) {
                                  product = Product(
                                      title: product.title,
                                      price: product.price,
                                      description: product.description,
                                      id: product.id,
                                      isFavorite: product.isFavorite,
                                      imageUrl: imageUrl);
                                }),
                          ),
                        ],
                      ),
                    ],
                  )),
            ),
    );
  }
}
