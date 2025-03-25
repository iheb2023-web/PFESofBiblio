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
  final String? token;
  final String? phone;
  final String? address;
  final List<int>? borrowedBooks;
  final List<int>? myBooks;
  final List<int>? toReadBooks;

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
    this.token,
    this.phone,
    this.address,
    this.borrowedBooks,
    this.myBooks,
    this.toReadBooks,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      print('User.fromJson - raw id: ${json['id']} (${json['id'].runtimeType})'); // Debug log
      return User(
        id: json['id'] is int ? json['id'] : 
            json['id'] != null ? int.tryParse(json['id'].toString()) : null,
        firstname: json['firstname']?.toString() ?? '',
        lastname: json['lastname']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        image: json['image']?.toString(),
        job: json['job']?.toString(),
        birthday: json['birthday'] != null ? DateTime.parse(json['birthday'].toString()) : null,
        role: json['role']?.toString() ?? 'USER',
        password: json['password']?.toString(),
        token: json['token']?.toString(),
        phone: json['phone']?.toString(),
        address: json['address']?.toString(),
        borrowedBooks: json['borrowedBooks'] != null 
          ? List<int>.from(json['borrowedBooks'])
          : null,
        myBooks: json['myBooks'] != null 
          ? List<int>.from(json['myBooks'])
          : null,
        toReadBooks: json['toReadBooks'] != null 
          ? List<int>.from(json['toReadBooks'])
          : null,
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
      if (password != null) 'password': password,
      if (token != null) 'token': token,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (borrowedBooks != null) 'borrowedBooks': borrowedBooks,
      if (myBooks != null) 'myBooks': myBooks,
      if (toReadBooks != null) 'toReadBooks': toReadBooks,
    };
  }

  // Copier l'utilisateur avec des modifications
  User copyWith({
    int? id,
    String? firstname,
    String? lastname,
    String? email,
    String? image,
    String? job,
    DateTime? birthday,
    String? role,
    String? password,
    String? token,
    String? phone,
    String? address,
    List<int>? borrowedBooks,
    List<int>? myBooks,
    List<int>? toReadBooks,
  }) {
    return User(
      id: id ?? this.id,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      image: image ?? this.image,
      job: job ?? this.job,
      birthday: birthday ?? this.birthday,
      role: role ?? this.role,
      password: password ?? this.password,
      token: token ?? this.token,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      borrowedBooks: borrowedBooks ?? this.borrowedBooks,
      myBooks: myBooks ?? this.myBooks,
      toReadBooks: toReadBooks ?? this.toReadBooks,
    );
  }
}