import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:resturent/src/model/customers.dart';
import 'package:resturent/src/utils/api.dart';

class CustomerService {
  static const String getCustomerUrl = '$API_URL/customers/show/customer';
  static const String addCustomerUrl = '$API_URL/customers/add/customer';
  static const String deleteCustomerUrl = '$API_URL/customers/delete/customer';
  static const String updateCustomerUrl = '$API_URL/customers/update/customer';

  static Future<List<Customers>> fetchCustomers() async {
    final response = await http.get(Uri.parse(getCustomerUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => Customers.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load customer list');
    }
  }

  static Future<void> addCustomer(Customers customer) async {
    final response = await http.post(
      Uri.parse(addCustomerUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(customer.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add customer');
    }
  }

  static Future<void> deleteCustomer(String id) async {
    final response = await http.delete(
      Uri.parse('$deleteCustomerUrl/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete customer');
    }
  }

  static Future<void> updateCustomer(Customers customer) async {
    final response = await http.put(
      Uri.parse('$updateCustomerUrl/${customer.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(customer.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update customer');
    }
  }
}

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  _CustomerPageState createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  late Future<List<Customers>> futureCustomers;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  Customers? _editingCustomer;

  @override
  void initState() {
    super.initState();
    futureCustomers = CustomerService.fetchCustomers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _addOrUpdateCustomer() async {
    if (_formKey.currentState!.validate()) {
      final customer = Customers(
        id: _editingCustomer?.id ?? '',
        customerName: _nameController.text,
        customerEmail: _emailController.text,
        // password: _passwordController.text,
      );

      try {
        if (_editingCustomer == null) {
          await CustomerService.addCustomer(customer);
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Customer added successfully')));
        } else {
          await CustomerService.updateCustomer(customer);
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Customer updated successfully')));
          _editingCustomer = null;
        }
        setState(() {
          futureCustomers = CustomerService.fetchCustomers();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add/update customer: $e')));
      }
    }
  }

  void _deleteCustomer(String id) async {
    try {
      await CustomerService.deleteCustomer(id);
      setState(() {
        futureCustomers = CustomerService.fetchCustomers();
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Customer deleted successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete customer: $e')));
    }
  }

  void _editCustomer(Customers customer) {
    setState(() {
      _editingCustomer = customer;
      _nameController.text = customer.customerName;
      _emailController.text = customer.customerEmail;
      // _passwordController.text = customer.password; //not complete backend to get that data
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Page'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.network(
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQo55q8aIv2qYhNSm8b7Fo0wb9-pbp7BAGzdw&s',
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
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addOrUpdateCustomer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: TextStyle(fontSize: 20),
                    ),
                    child: Text(_editingCustomer == null
                        ? 'Add Customer'
                        : 'Update Customer'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            FutureBuilder<List<Customers>>(
              future: futureCustomers,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No customers available');
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final customer = snapshot.data![index];
                      return ListTile(
                        title: Text(customer.customerName),
                        subtitle: Text(customer.customerEmail),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _editCustomer(customer),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteCustomer(customer.id),
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
