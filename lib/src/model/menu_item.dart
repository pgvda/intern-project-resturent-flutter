// lib/src/models/menu_item.dart

import 'dart:convert';

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
      id:json['_id'],
      menuName: json['menuName'],
      menuPrice: json['menuPrice'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id' : id,
      'menuName': menuName,
      'menuPrice': menuPrice,
    };
  }
}
