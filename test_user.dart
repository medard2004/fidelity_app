import 'lib/models/user.dart';

void main() {
  final user = AppUser(
    id: '1',
    fullName: 'Test User',
    phoneNumber: '123456789',
    joinDate: DateTime.now(),
    referralCode: 'REF123',
  );
  print('User is social: ${user.isSocialUser}');
}
