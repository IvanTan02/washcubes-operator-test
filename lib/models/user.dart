class UserProfile {
  final String id;
  final int phoneNumber;
  final String name;
  final String email;
  final String profilePicURL;
  final int v;

  UserProfile({
    required this.id,
    required this.phoneNumber,
    required this.name,
    required this.email,
    required this.profilePicURL,
    required this.v,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return (UserProfile(
      id: json['_id'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profilePicURL: json['profilePicURL'] ?? '',
      v: json['__v'] ?? 0,
    ));
  }
}

class User {
  final String id;
  final int phoneNumber;

  User({
    required this.id,
    required this.phoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return (User(
      id: json['_id'] ?? '',
      phoneNumber: json['phoneNumber'] ?? 0,
    ));
  }
}
