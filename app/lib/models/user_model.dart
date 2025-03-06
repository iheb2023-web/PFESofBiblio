class User {
  final int? id;
  final String firstname;
  final String lastname;
  final String email;
  final String? image;
  final String? job;
  final DateTime? birthday;
  final String role;
  final String? password;

  User({
    this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    this.image,
    this.job,
    this.birthday,
    required this.role,
    this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      return User(
        id: json['id'] != null ? int.parse(json['id'].toString()) : null,
        firstname: json['firstname']?.toString() ?? '',
        lastname: json['lastname']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        image: json['image']?.toString(),
        job: json['job']?.toString(),
        birthday: json['birthday'] != null ? DateTime.parse(json['birthday'].toString()) : null,
        role: json['role']?.toString() ?? 'USER',
        password: json['password']?.toString(),
      );
    } catch (e) {
      print('Erreur lors de la conversion JSON: $e');
      print('JSON reçu: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'image': image,
      'job': job,
      'birthday': birthday?.toIso8601String(),
      'role': role,
      'password': password,
    };
  }
} 