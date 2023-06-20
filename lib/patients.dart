class Patient {
  final String name;
  final String age;

  Patient({
    required this.name,
    required this.age,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      name: json['name'],
      age: json['age'],
    );
  }
}
