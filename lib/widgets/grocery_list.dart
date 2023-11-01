import 'package:flutter/material.dart';
import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  void _addItem() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) {
          return const NewItem();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("your grocery list"),
        actions: [
          IconButton(onPressed: _addItem, icon: Icon(Icons.add)),
        ],
      ),
      body: ListView.builder(
          shrinkWrap: true,
          itemCount: groceryItems.length,
          itemBuilder: (ctx, indx) {
            print("grocery item");
            print(groceryItems[indx]);
            return ListTile(
              title: Text(groceryItems[indx].name),
              leading: Container(
                width: 24,
                height: 24,
                color: groceryItems[indx].category.color,
              ),
              trailing: Text(groceryItems[indx].quantity.toString()),
            );
          }),
    );
  }
}
