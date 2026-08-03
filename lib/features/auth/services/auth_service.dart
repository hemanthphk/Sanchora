import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sanchora/features/auth/models/linked_account.dart';
import 'package:sanchora/features/auth/repositories/auth_repository.dart';

class MockAuthService implements AuthRepository {
  static const String _accountsKey = 'mock_connected_accounts';
  
  MockAuthService._();
  
  static final MockAuthService instance = MockAuthService._();

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // In a real app, this would make an API call to change the password.
    // For the mock, we just pretend it succeeds.
  }

  @override
  Future<List<LinkedAccount>> getConnectedAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? accountsJson = prefs.getString(_accountsKey);
    
    if (accountsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(accountsJson);
        return decoded.map((e) => LinkedAccount.fromJson(e)).toList();
      } catch (e) {
        // Fallback to default if corrupted
      }
    }
    
    // Default mock data for first launch
    final defaultAccounts = [
      const LinkedAccount(
        provider: AccountProvider.google, 
        isConnected: true, 
        isPrimary: true, 
        identifier: 'hemanth@example.com'
      ),
      const LinkedAccount(provider: AccountProvider.apple, isConnected: false),
      const LinkedAccount(provider: AccountProvider.facebook, isConnected: false),
      const LinkedAccount(provider: AccountProvider.github, isConnected: false),
      const LinkedAccount(provider: AccountProvider.microsoft, isConnected: false),
      const LinkedAccount(provider: AccountProvider.phone, isConnected: false),
    ];
    
    await _saveAccounts(defaultAccounts);
    return defaultAccounts;
  }

  @override
  Future<bool> connectAccount(AccountProvider provider) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    final accounts = await getConnectedAccounts();
    final index = accounts.indexWhere((a) => a.provider == provider);
    
    if (index >= 0) {
      accounts[index] = accounts[index].copyWith(
        isConnected: true,
        identifier: 'connected@example.com', // Mock identifier
      );
      await _saveAccounts(accounts);
      return true;
    }
    return false;
  }

  @override
  Future<bool> disconnectAccount(AccountProvider provider) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    final accounts = await getConnectedAccounts();
    final index = accounts.indexWhere((a) => a.provider == provider);
    
    if (index >= 0) {
      final connectedCount = accounts.where((a) => a.isConnected).length;
      
      // Ensure at least one account remains connected
      if (connectedCount <= 1 && accounts[index].isConnected) {
        throw Exception('Cannot disconnect the only login method.');
      }
      
      accounts[index] = accounts[index].copyWith(
        isConnected: false,
        identifier: null,
      );
      
      // If we disconnected the primary, assign primary to the first available connected account
      if (accounts[index].isPrimary) {
        accounts[index] = accounts[index].copyWith(isPrimary: false);
        final firstConnected = accounts.firstWhere((a) => a.isConnected);
        final newPrimaryIndex = accounts.indexOf(firstConnected);
        accounts[newPrimaryIndex] = accounts[newPrimaryIndex].copyWith(isPrimary: true);
      }
      
      await _saveAccounts(accounts);
      return true;
    }
    return false;
  }
  
  Future<void> _saveAccounts(List<LinkedAccount> accounts) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonStr = jsonEncode(accounts.map((a) => a.toJson()).toList());
    await prefs.setString(_accountsKey, jsonStr);
  }
}
