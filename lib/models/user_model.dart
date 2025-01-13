class User {
  final int id;
  final String name;
  final String email;
  final bool isAdmin;
  final bool verified;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.isAdmin,
    required this.verified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      isAdmin: json['isAdmin'] ?? false,
      verified: json['verified'] ?? false,
    );
  }
}
