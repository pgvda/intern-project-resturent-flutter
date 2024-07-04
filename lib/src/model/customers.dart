class Customers {
  final String customerName;
  final String customerEmail;
  

  Customers({
    required this.customerName,
    required this.customerEmail,
  });

  factory Customers.fromJson(Map<String, dynamic> json) {
    return Customers(customerName: json['customerName'], customerEmail: json['customerEmail']);
    
  }

  Map<String, dynamic> toJson() {
    return {
      'customerName' : customerName,
      'customerEmail' : customerEmail,
    };
  }
}