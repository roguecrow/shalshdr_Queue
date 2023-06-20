class User {
  final int? id;
  final int clinicId;
  final int doctorId;
  final String doctorName;

  User({
    this.id,
    required this.clinicId,
    required this.doctorId,
    required this.doctorName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      clinicId: json['clinic_id'] as int,
      doctorId: json['doctor_id'] as int,
      doctorName: json['doctor_name'] as String,
    );
  }
}




