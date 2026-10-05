class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final String? profilePictureUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.profilePictureUrl,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? profilePictureUrl,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    );
  }
}
