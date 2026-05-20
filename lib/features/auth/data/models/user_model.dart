// lib/features/auth/data/models/user_model.dart

import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.avatarUrl,
    required super.isPro,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isPro: json['is_pro'] as bool? ?? false,
    );
  }

  factory UserModel.fromSupabaseUser(supabase.User user, {Map? profile}) {
    final profileMap = profile is Map<String, dynamic>
        ? profile
        : <String, dynamic>{};

    return UserModel(
      id: user.id,
      email: user.email ?? '',
      displayName:
          profileMap['display_name'] as String? ??
          profileMap['displayName'] as String?,
      avatarUrl:
          profileMap['avatar_url'] as String? ??
          profileMap['avatarUrl'] as String?,
      isPro: _parseBool(profileMap['is_pro'] ?? profileMap['isPro']),
    );
  }

  Map<String, dynamic> toJson() {
    final payload = <String, dynamic>{
      'id': id,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'is_pro': isPro,
    };
    payload.removeWhere((key, value) => value == null);
    return payload;
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      displayName: displayName,
      avatarUrl: avatarUrl,
      isPro: isPro,
    );
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.toLowerCase();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }
}
