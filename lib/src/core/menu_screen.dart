import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:resturent/src/utils/api.dart';

class MenuItem {
  final String id;
  final String menuName;
  final String menuPrice;

  MenuItem({
    required this.id,
    required this.menuName,
    required this.menuPrice,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['_id'],
      menuName: json['menuName'],
      menuPrice: json['menuPrice'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'menuName': menuName,
      'menuPrice': menuPrice,
    };
  }
}

class MenuService {
  static const String apiUrl = '$API_URL/menus/show/menu';
  static const String addItemUrl = '$API_URL/menus/add/menu';
  static const String deleteItemUrl = '$API_URL/menus/delete/menu';
  static const String updateItemUrl = '$API_URL/menus/update/menu';

  static Future<List<MenuItem>> fetchMenuItems() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => MenuItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load menu items');
    }
  }

  static Future<void> addMenuItem(MenuItem menuItem) async {
    final response = await http.post(
      Uri.parse(addItemUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(menuItem.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add menu item');
    }
  }

  static Future<void> deleteMenuItem(String id) async {
    final response = await http.delete(
      Uri.parse('$deleteItemUrl/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete menu item');
    }
  }

  static Future<void> updateMenuItem(MenuItem menuItem) async {
    final response = await http.put(
      Uri.parse('$updateItemUrl/${menuItem.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(menuItem.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update menu item');
    }
  }
}

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late Future<List<MenuItem>> futureMenuItems;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  MenuItem? _editingMenu;

  @override
  void initState() {
    super.initState();
    futureMenuItems = MenuService.fetchMenuItems();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _addOrUpdateItem() async {
    if (_formKey.currentState!.validate()) {
      final menuItem = MenuItem(
        id: _editingMenu?.id ?? '',
        menuName: _nameController.text,
        menuPrice: _priceController.text,
      );

      try {
        if (_editingMenu == null) {
          await MenuService.addMenuItem(menuItem);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Item added successfully')),
          );
        } else {
          await MenuService.updateMenuItem(menuItem);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Item updated successfully')),
          );
          _editingMenu = null;
        }

        setState(() {
          futureMenuItems = MenuService.fetchMenuItems();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add/update item: $e')),
        );
      }
    }
  }

  void _deleteMenuItem(String id) async {
    try {
      await MenuService.deleteMenuItem(id);
      setState(() {
        futureMenuItems = MenuService.fetchMenuItems();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item deleted successfully')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete item: $error')),
      );
    }
  }

  void _editMenuItem(MenuItem menuItem) {
    setState(() {
      _editingMenu = menuItem;
      _nameController.text = menuItem.menuName;
      _priceController.text = menuItem.menuPrice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu Page'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.network(
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQWDg7nhxER8Rxa4T6ddNAu1REs4QVdLcZuDQ&s',
              height: 200,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a price';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addOrUpdateItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: TextStyle(fontSize: 20),
                    ),
                    child: Text(_editingMenu == null ? 'Add Item' : 'Update Item'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            FutureBuilder<List<MenuItem>>(
              future: futureMenuItems,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No menu items available');
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final menuItem = snapshot.data![index];
                      return ListTile(
                        title: Text(menuItem.menuName),
                        subtitle: Text(menuItem.menuPrice),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _editMenuItem(menuItem),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteMenuItem(menuItem.id),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
