import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  // var _isLoading = true;
  late Future<List<GroceryItem>> _loadedItems;
  String? _error;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadedItems = _loadItems();
  }

  Future<List<GroceryItem>> _loadItems() async {
    // try {
    final url = Uri.https('shopping-list-92cd5-default-rtdb.firebaseio.com',
        'shopping-list.json');
    final response = await http.get(url);
    if (response.statusCode >= 400) {
      throw Exception("Failed to fetch data please try again later!");
      // setState(() {
      //   _error = "Failed to fetch data please try again later!";
      // });
    }
    if (response.body == 'null') {
      // setState(() {
      //   _isLoading = false;
      // });
      return [];
    }
    final Map<String, dynamic> listData = json.decode(response.body);
    final List<GroceryItem> _loadedItemsList = [];
    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere(
            (element) => element.value.title == item.value['category'],
          )
          .value;
      _loadedItemsList.add(GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category));
    }
    return _loadedItemsList;
    // setState(() {
    //   _groceryItems = _loadedItemsList;
    //   _isLoading = false;
    // });
    // } catch (e) {
    //   // throw Exception()
    //   setState(() {
    //     _error = "Failed to fetch data please try again later!";
    //   });
    // }
  }

  void _addItem() async {
    // await Navigator.of(context).push<GroceryItem>(
    //   MaterialPageRoute(
    //     builder: (ctx) {
    //       return const NewItem();
    //     },
    //   ),
    // );
    // _loadItems();
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) {
          return const NewItem();
        },
      ),
    );
    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });
    final url = Uri.https('hopping-list-92cd5-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, item);
      });
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("failed to delete the item, please try again"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Widget content = const Center(
    //   child: Text("Oops! You have no items in your grocery list"),
    // );
    // if (_isLoading) {
    //   content = const Center(
    //     child: CircularProgressIndicator(),
    //   );
    // }
    // if (_groceryItems.isNotEmpty) {
    //   content = ListView.builder(
    //       shrinkWrap: true,
    //       itemCount: _groceryItems.length,
    //       itemBuilder: (ctx, indx) {
    //         return Dismissible(
    //           key: ValueKey(_groceryItems[indx].id),
    //           onDismissed: (direction) {
    //             _removeItem(_groceryItems[indx]);
    //           },
    //           child: ListTile(
    //             title: Text(_groceryItems[indx].name),
    //             leading: Container(
    //               width: 24,
    //               height: 24,
    //               color: _groceryItems[indx].category.color,
    //             ),
    //             trailing: Text(_groceryItems[indx].quantity.toString()),
    //           ),
    //         );
    //       });
    // }
    // if (_error != null) {
    //   content = Center(
    //     child: Text(_error!),
    //   );
    // }
    return Scaffold(
      appBar: AppBar(
        title: const Text("your grocery list"),
        actions: [
          IconButton(onPressed: _addItem, icon: Icon(Icons.add)),
        ],
      ),
      // body: content,
      body: FutureBuilder(
        future: _loadedItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }
          if (snapshot.data!.isEmpty) {
            return const Center(
              child: Text("Oops! You have no items in your grocery list"),
            );
          }
          return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              itemBuilder: (ctx, indx) {
                return Dismissible(
                  key: ValueKey(snapshot.data![indx].id),
                  onDismissed: (direction) {
                    _removeItem(snapshot.data![indx]);
                  },
                  child: ListTile(
                    title: Text(snapshot.data![indx].name),
                    leading: Container(
                      width: 24,
                      height: 24,
                      color: snapshot.data![indx].category.color,
                    ),
                    trailing: Text(snapshot.data![indx].quantity.toString()),
                  ),
                );
              });
        },
      ),
    );
  }
}
