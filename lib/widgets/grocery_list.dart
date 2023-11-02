import 'package:flutter/material.dart';
import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItems = [];
  void _addItem() async {
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

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text("Oops! You have no items in your grocery list"),
    );
    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
          shrinkWrap: true,
          itemCount: _groceryItems.length,
          itemBuilder: (ctx, indx) {
            print("grocery item");
            return Dismissible(
              key: ValueKey(_groceryItems[indx].id),
              onDismissed: (direction) {
                setState(() {
                  _groceryItems.remove(_groceryItems[indx]);
                });
                print(_groceryItems.length);
              },
              child: ListTile(
                title: Text(_groceryItems[indx].name),
                leading: Container(
                  width: 24,
                  height: 24,
                  color: _groceryItems[indx].category.color,
                ),
                trailing: Text(_groceryItems[indx].quantity.toString()),
              ),
            );
          });
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("your grocery list"),
        actions: [
          IconButton(onPressed: _addItem, icon: Icon(Icons.add)),
        ],
      ),
      body: content,
    );
  }
}
