import 'package:flutter/material.dart';
import 'package:sanchora/core/widgets/sanchora_page_header.dart';
import 'package:sanchora/features/auth/models/linked_account.dart';
import 'package:sanchora/features/auth/services/auth_service.dart';
import 'package:sanchora/features/auth/widgets/connected_account_tile.dart';

class ConnectedAccountsScreen extends StatefulWidget {
  const ConnectedAccountsScreen({super.key});

  @override
  State<ConnectedAccountsScreen> createState() => _ConnectedAccountsScreenState();
}

class _ConnectedAccountsScreenState extends State<ConnectedAccountsScreen> {
  List<LinkedAccount> _accounts = [];
  bool _isLoading = true;
  AccountProvider? _processingProvider;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() => _isLoading = true);
    try {
      final accounts = await MockAuthService.instance.getConnectedAccounts();
      if (mounted) {
        setState(() {
          _accounts = accounts;
        });
      }
    } catch (e) {
      _showError('Failed to load accounts');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _handleConnect(AccountProvider provider) async {
    if (_processingProvider != null) return;
    setState(() => _processingProvider = provider);

    try {
      final success = await MockAuthService.instance.connectAccount(provider);
      if (success) {
        await _loadAccounts(); // Refresh
        _showSuccess('${provider.displayName} connected successfully.');
      } else {
        _showError('Failed to connect ${provider.displayName}.');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _processingProvider = null);
      }
    }
  }

  Future<void> _handleDisconnect(AccountProvider provider) async {
    if (_processingProvider != null) return;
    
    final shouldDisconnect = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Disconnect ${provider.displayName}?'),
        content: const Text('You will no longer be able to use this account to log in.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );

    if (shouldDisconnect != true) return;

    setState(() => _processingProvider = provider);

    try {
      final success = await MockAuthService.instance.disconnectAccount(provider);
      if (success) {
        await _loadAccounts(); // Refresh
        _showSuccess('${provider.displayName} disconnected.');
      } else {
        _showError('Failed to disconnect ${provider.displayName}.');
      }
    } catch (e) {
      // e.g. Cannot disconnect the only login method
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _processingProvider = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SanchoraPageHeader(title: 'Connected Accounts'),
      body: _isLoading && _accounts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              physics: const BouncingScrollPhysics(),
              itemCount: _accounts.length,
              itemBuilder: (context, index) {
                final account = _accounts[index];
                return ConnectedAccountTile(
                  account: account,
                  isLoading: _processingProvider == account.provider,
                  onConnect: () => _handleConnect(account.provider),
                  onDisconnect: () => _handleDisconnect(account.provider),
                );
              },
            ),
    );
  }
}
