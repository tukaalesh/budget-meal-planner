import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String token;
  final bool familyProfileCompleted;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    required this.familyProfileCompleted,
    this.phone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] ?? json;

    return UserModel(
      id: userData['id'].toString(),
      name: userData['name'] ?? '',
      email: userData['email'] ?? '',
      phone: userData['phone'],
      token: json['token'] ?? userData['token'] ?? '',
      familyProfileCompleted: json['family_profile_completed'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'token': token,
      'family_profile_completed': familyProfileCompleted,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? token,
    bool? familyProfileCompleted,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      token: token ?? this.token,
      familyProfileCompleted:
          familyProfileCompleted ?? this.familyProfileCompleted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        token,
        familyProfileCompleted,
      ];
}
