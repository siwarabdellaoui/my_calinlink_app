import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/user_service.dart';

class UserProfile {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String babyName;
  final String babyGender; // M, F
  final String babyBirthDate;
  final String avatar;

  const UserProfile({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phone = '',
    this.babyName = '',
    this.babyGender = '',
    this.babyBirthDate = '',
    this.avatar = '',
  });

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? babyName,
    String? babyGender,
    String? babyBirthDate,
    String? avatar,
  }) {
    return UserProfile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      babyName: babyName ?? this.babyName,
      babyGender: babyGender ?? this.babyGender,
      babyBirthDate: babyBirthDate ?? this.babyBirthDate,
      avatar: avatar ?? this.avatar,
    );
  }
}

class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier() : super(const UserProfile());

  Future<void> fetchProfile() async {
    try {
      final profileData = await UserService.getProfile();
      print('PROFILE DATA = $profileData');
      state = state.copyWith(
        firstName: profileData['firstName'] ?? '',
        lastName: profileData['lastName'] ?? '',
        email: profileData['email'] ?? '',
        phone: profileData['phone'] ?? '',
        babyName: profileData['babyContext']?['firstName'] ?? '',
        babyGender: profileData['babyContext']?['gender'] ?? '',
        babyBirthDate: profileData['babyContext']?['birthDate'] ?? '',
        avatar: profileData['avatar'] ?? '',
      );
    } catch (e) {
      print('Erreur fetchProfile: $e');
    }
  }

  Future<void> updateProfile(UserProfile newProfile) async {
    try {
      await UserService.updateProfile({
        'firstName': newProfile.firstName,
        'lastName': newProfile.lastName,
        'phone': newProfile.phone,
        'avatar': newProfile.avatar,
        'babyContext': {
          'firstName': newProfile.babyName,
          'gender': newProfile.babyGender,
          'birthDate': newProfile.babyBirthDate,
        }
      });
      state = newProfile;
    } catch (e) {
      print('Erreur updateProfile: $e');
      rethrow;
    }
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  return UserProfileNotifier();
});
