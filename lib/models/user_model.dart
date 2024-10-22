class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phoneNumber;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phoneNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
    );
  }
}
