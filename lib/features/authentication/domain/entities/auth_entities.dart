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
  final String code;
  final String name;
  final String goal;
  final String status;
  final String? photo;

  const MemberEntity({
    required this.id,
    required this.code,
    required this.name,
    required this.goal,
    required this.status,
    this.photo,
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
