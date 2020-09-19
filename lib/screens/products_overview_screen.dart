import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './cart_screen.dart';
import '../providers/cart.dart';
import '../providers/products_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/badge.dart';
import '../widgets/product_grid.dart';

enum FilterOption {
  Favorite,
  All,
}

class ProductsOverviewScreen extends StatefulWidget {
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showFavorite = false;
  var _inIt = false;
  var _isLoaded = false;

//  fetching data from dataBase
  @override
  void initState() {
    _isLoaded = true;
    Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts()
        .then((_) {
      setState(() {
        _isLoaded = false;
      });
    });

//    Future.delayed(Duration.zero).then((_) {
//      _isLoaded = true;
//      Provider.of<Products>(context, listen: false)
//          .fetchAndSetProducts()
//          .then((_) {
//        setState(() {
//          _isLoaded = false;
//        });
//      });
//    });
    super.initState();
  }
//  @override
//  void didChangeDependencies() {
//    if (_inIt) {
//      setState(() {
//        _isLoaded = true;
//      });
//      Provider.of<Products>(context).fetchAndSetProducts();
//    }
//    setState(() {
//      _isLoaded = false;
//    });
//    _inIt = true;
//    super.didChangeDependencies();
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyShop'),
        actions: <Widget>[
          PopupMenuButton(
            elevation: 20,
            onSelected: (FilterOption selectedValue) {
              setState(() {
                if (selectedValue == FilterOption.Favorite) {
                  _showFavorite = true;
                } else {
                  _showFavorite = false;
                }
              });
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('My Favorite'),
                value: FilterOption.Favorite,
              ),
              PopupMenuItem(
                child: Text('Show all'),
                value: FilterOption.All,
              ),
            ],
            icon: Icon(
              Icons.more_vert,
            ),
          ),
          Consumer<Cart>(
            builder: (ctx, cart, ch) => Badge(
              child: ch,
              value: cart.itemCount.toString(),
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoaded
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(_showFavorite),
    );
  }
}
