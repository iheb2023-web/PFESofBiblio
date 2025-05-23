class TopBorrower {
  final int id;
  final String firstname;
  final String lastname;
  final String email;
  final int nbEmprunts; // Notez le nom correspondant à l'API ("nbEmprunts")

  TopBorrower({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.nbEmprunts,
  });

  factory TopBorrower.fromJson(Map<String, dynamic> json) {
    return TopBorrower(
      id: json['id'] ?? 0,
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      email: json['email'] ?? '',
      nbEmprunts: json['nbEmprunts'] ?? 0, // Correspond au champ de l'API
    );
  }
}
