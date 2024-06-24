class Users {
  final String id;
  final String email;

  Users({
    required this.id,
    required this.email,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
    };
  }
}
