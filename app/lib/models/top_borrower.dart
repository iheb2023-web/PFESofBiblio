class TopBorrower {
  final int id;
  final String firstname;
  final String lastname;
  final String email;
  final int borrowCount;

  TopBorrower({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.borrowCount,
  });

  factory TopBorrower.fromJson(Map<String, dynamic> json) {
    return TopBorrower(
      id: json['id'],
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      email: json['email'] ?? '',
      borrowCount: json['borrowCount'] ?? 0, // adapte la clé si besoin
    );
  }
}
