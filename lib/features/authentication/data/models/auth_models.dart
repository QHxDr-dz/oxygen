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

/// Data model for Member — handles JSON serialization with all API fields.
class MemberModel {
  final int id;
  final int userId;
  final String code;
  final String? qrToken;
  final String name;
  final String email;
  final String goal;
  final String status;
  final String? photo;
  final String? contact;
  final String? emergencyContact;
  final String? healthIssue;
  final String? gender;
  final String? dob;
  final String? address;
  final String? country;
  final String? city;
  final String? state;
  final String? pincode;
  final String? source;

  const MemberModel({
    required this.id,
    required this.userId,
    required this.code,
    this.qrToken,
    required this.name,
    required this.email,
    required this.goal,
    required this.status,
    this.photo,
    this.contact,
    this.emergencyContact,
    this.healthIssue,
    this.gender,
    this.dob,
    this.address,
    this.country,
    this.city,
    this.state,
    this.pincode,
    this.source,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id'] as int,
      userId: json['user_id'] as int? ?? 0,
      code: json['code'] as String? ?? '',
      qrToken: json['qr_token'] as String?,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      goal: json['goal'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      photo: json['photo'] as String?,
      contact: json['contact'] as String?,
      emergencyContact: json['emergency_contact'] as String?,
      healthIssue: json['health_issue'] as String?,
      gender: json['gender'] as String?,
      dob: json['dob'] as String?,
      address: json['address'] as String?,
      country: json['country'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
      source: json['source'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'code': code,
    'qr_token': qrToken,
    'name': name,
    'email': email,
    'goal': goal,
    'status': status,
    'photo': photo,
    'contact': contact,
    'emergency_contact': emergencyContact,
    'health_issue': healthIssue,
    'gender': gender,
    'dob': dob,
    'address': address,
    'country': country,
    'city': city,
    'state': state,
    'pincode': pincode,
    'source': source,
  };

  MemberEntity toEntity() => MemberEntity(
    id: id,
    userId: userId,
    code: code,
    qrToken: qrToken,
    name: name,
    email: email,
    goal: goal,
    status: status,
    photo: photo,
    contact: contact,
    emergencyContact: emergencyContact,
    healthIssue: healthIssue,
    gender: gender,
    dob: dob,
    address: address,
    country: country,
    city: city,
    state: state,
    pincode: pincode,
    source: source,
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
      token: json['token'] as String? ?? '',
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
