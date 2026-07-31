/// Domain entity representing the authenticated user account.
class UserEntity {
  final int id;
  final String name;
  final String email;
  final String? photo;
  final String status;
  final String approvalStatus;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.photo,
    required this.status,
    required this.approvalStatus,
  });

  bool get isActive => status == 'active';
  bool get isApproved => approvalStatus == 'approved';
  bool get isPendingApproval => approvalStatus == 'pending';
}

/// Domain entity representing the gym member profile.
class MemberEntity {
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

  const MemberEntity({
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

  bool get isActive => status == 'active';
}

/// Combined auth result returned after login.
class AuthResultEntity {
  final String token;
  final UserEntity user;
  final MemberEntity? member;

  const AuthResultEntity({
    required this.token,
    required this.user,
    this.member,
  });
}
