// lib/src/models/menu_item.dart

class MenuItem {
  final String menuName;
  final String menuPrice;

    MenuItem({
    required this.menuName,
    required this.menuPrice,
  });



  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      menuName: json['menuName'],
      menuPrice: json['menuPrice'],
    );
  }

    Map<String, dynamic> toJson() {
    return {
      'menuName': menuName,
      'menuPrice': menuPrice,
    };
  }
}
