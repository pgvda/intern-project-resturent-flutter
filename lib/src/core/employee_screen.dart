import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:resturent/src/model/employees.dart';
import 'package:resturent/src/utils/api.dart';


class EmployeeService {
  static const String getEmployeeUrl = '$API_URL/employees/show/employee';
  static const String addEmployeeUrl = '$API_URL/employees/add/employee';
  static const String deleteEmployeeUrl = '$API_URL/employees/delete/employee';
  static const String updateEmployeeUrl = '$API_URL/employees/update/employee';

  static Future<List<Employees>> fetchEmployee() async {
    final response = await http.get(Uri.parse(getEmployeeUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => Employees.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load employees');
    }
  }

  static Future<void> addEmployee(Employees employee) async {
    final response = await http.post(
      Uri.parse(addEmployeeUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(employee.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add employee');
    }
  }

  static Future<void> deleteEmployee(String id) async {
    final response = await http.delete(
      Uri.parse('$deleteEmployeeUrl/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete employee');
    }
  }

  static Future<void> updateEmployee(Employees employee) async {
    final response = await http.put(
      Uri.parse('$updateEmployeeUrl/${employee.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(employee.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update employee');
    }
  }
}

class EmployeePage extends StatefulWidget {
  const EmployeePage({super.key});

  @override
  _EmployeePageState createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  late Future<List<Employees>> futureEmployees;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  Employees? _editingEmployee;

  @override
  void initState() {
    super.initState();
    futureEmployees = EmployeeService.fetchEmployee();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _addOrUpdateEmployee() async {
    if (_formKey.currentState!.validate()) {
      final employee = Employees(
        id: _editingEmployee?.id ?? '',
        employeeName: _nameController.text,
        employeeEmail: _emailController.text,
      );

      try {
        if (_editingEmployee == null) {
          await EmployeeService.addEmployee(employee);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Employee added successfully')),
          );
        } else {
          await EmployeeService.updateEmployee(employee);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Employee updated successfully')),
          );
          _editingEmployee = null;
        }

        setState(() {
          futureEmployees = EmployeeService.fetchEmployee();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add/update employee: $e')),
        );
      }
    }
  }

  void _deleteEmployee(String id) async {
    try {
      await EmployeeService.deleteEmployee(id);
      setState(() {
        futureEmployees = EmployeeService.fetchEmployee();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Employee deleted successfully')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete employee: $error')),
      );
    }
  }

  void _editEmployee(Employees employee) {
    setState(() {
      _editingEmployee = employee;
      _nameController.text = employee.employeeName;
      _emailController.text = employee.employeeEmail;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Page'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.network(
              'https://elearningindustry.com/wp-content/uploads/2019/03/employee-or-employer-who-is-responsible-for-improving-employee-performance-and-how.jpeg',
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
                  ElevatedButton(
                    onPressed: _addOrUpdateEmployee,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: TextStyle(fontSize: 20),
                    ),
                    child: Text(_editingEmployee == null ? 'Add Employee' : 'Update Employee'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            FutureBuilder<List<Employees>>(
              future: futureEmployees,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No employees available');
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final employee = snapshot.data![index];
                      return ListTile(
                        title: Text(employee.employeeName),
                        subtitle: Text(employee.employeeEmail),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _editEmployee(employee),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteEmployee(employee.id),
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