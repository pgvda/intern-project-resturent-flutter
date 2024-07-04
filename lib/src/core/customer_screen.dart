import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:resturent/src/model/customers.dart';
import 'package:resturent/src/utils/api.dart';

class CustomerService {
  static const String getCustomerUrl = '$API_URL/customers/show/customer';
  static const String addCustomerUrl = '$API_URL/customers/add/customer';

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

  void _addCustomer() async {
    if (_formKey.currentState!.validate()) {
      final customer = Customers(

        customerName: _nameController.text,
        customerEmail: _emailController.text,
        //password: _passwordController.text,
      );

      try {
        await CustomerService.addCustomer(customer);
        setState(() {
          futureCustomers = CustomerService.fetchCustomers();  // Refresh the customer list
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Customer added successfully')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add customer: $e')));
      }
    }
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
                    onPressed: _addCustomer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: TextStyle(fontSize: 20),
                    ),
                    child: Text('Add Customer'),
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
