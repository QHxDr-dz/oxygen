import '../../domain/entities/auth_entities.dart';

/// Data model for User — handles JSON serialization.
class UserModel {
  final int id;
  final String name;
  final String email;
  final String? photo;
  final String status;
  final String approvalStatus;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photo,
    required this.status,
    required this.approvalStatus,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      photo: json['photo'] as String?,
      status: json['status'] as String? ?? 'active',
      approvalStatus: json['approval_status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'photo': photo,
    'status': status,
    'approval_status': approvalStatus,
  };

  UserEntity toEntity() => UserEntity(
    id: id,
    name: name,
    email: email,
    photo: photo,
    status: status,
    approvalStatus: approvalStatus,
  );
}

/// Data model for Member.
class MemberModel {
  final int id;
  final String code;
  final String name;
  final String goal;
  final String status;
  final String? photo;

  const MemberModel({
    required this.id,
    required this.code,
    required this.name,
    required this.goal,
    required this.status,
    this.photo,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id'] as int,
      code: json['code'] as String? ?? '',
      name: json['name'] as String,
      goal: json['goal'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      photo: json['photo'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    'goal': goal,
    'status': status,
    'photo': photo,
  };

  MemberEntity toEntity() => MemberEntity(
    id: id,
    code: code,
    name: name,
    goal: goal,
    status: status,
    photo: photo,
  );
}

/// Data model for the login/register response.
class AuthResponseModel {
  final String token;
  final UserModel user;
  final MemberModel? member;

  const AuthResponseModel({
    required this.token,
    required this.user,
    this.member,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      token: json['token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      member: json['member'] != null
          ? MemberModel.fromJson(json['member'] as Map<String, dynamic>)
          : null,
    );
  }

  AuthResultEntity toEntity() => AuthResultEntity(
    token: token,
    user: user.toEntity(),
    member: member?.toEntity(),
  );
}
