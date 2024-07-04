class Employees {
  final String id;
  final String employeeName;
  final String employeeEmail;

  Employees({
    required this.id,
    required this.employeeName,
    required this.employeeEmail,
  });

  factory Employees.fromJson(Map<String, dynamic> json) {
    return Employees(
      id: json['_id'],
      employeeName: json['employeeName'],
      employeeEmail: json['employeeEmail'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'employeeName': employeeName,
      'employeeEmail': employeeEmail,
    };
  }
}
