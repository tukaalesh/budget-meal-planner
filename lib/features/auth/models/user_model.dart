import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
  });

  UserModel copyWith({String? id, String? name, String? email, String? phone}) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }

  @override
  List<Object?> get props => [id, name, email, phone];
}
