class Customers {
  final String id;
  final String customerName;
  final String customerEmail;

  Customers({
    required this.id,
    required this.customerName,
    required this.customerEmail,
  });

  factory Customers.fromJson(Map<String, dynamic> json) {
    return Customers(
      id: json['_id'],
      customerName: json['customerName'],
      customerEmail: json['customerEmail'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'customerName': customerName,
      'customerEmail': customerEmail,
    };
  }
}
