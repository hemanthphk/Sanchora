import 'package:sanchora/features/auth/models/linked_account.dart';

abstract class AuthRepository {
  Future<void> changePassword(String currentPassword, String newPassword);
  
  Future<List<LinkedAccount>> getConnectedAccounts();
  
  Future<bool> connectAccount(AccountProvider provider);
  
  Future<bool> disconnectAccount(AccountProvider provider);
}
