// lib/manage_accounts_page.dart
import 'package:flutter/material.dart';
import '../services/account_service.dart';
import '../models/account_model.dart';

class ManageAccountsPage extends StatefulWidget {
  const ManageAccountsPage({super.key});

  @override
  State<ManageAccountsPage> createState() => _ManageAccountsPageState();
}

class _ManageAccountsPageState extends State<ManageAccountsPage> {
  final AccountService _accountService = AccountService();
  List<AccountModel> _accounts = [];
  bool _isLoading = true;

  static const Set<String> _defaultAccountIds = {
    'gopay',
    'dana',
    'cash',
  };

  @override
  void initState() {
    super.initState();
    _loadAccounts();
    _runMigrationIfNeeded(); // ✅ Jalankan migration sekali
  }

  Future<void> _runMigrationIfNeeded() async {
    try {
      await _accountService.migrateAccountsToAddAccountType();
    } catch (e) {
      print('❌ Migration error: $e');
    }
  }

  Future<void> _loadAccounts() async {
    setState(() => _isLoading = true);

    try {
      final accounts = await _accountService.getUserAccountsFuture();
      setState(() {
        _accounts = _sortAccounts(accounts);
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading accounts: $e');
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading accounts: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<AccountModel> _sortAccounts(List<AccountModel> accounts) {
    final defaultAccounts = accounts
        .where((acc) => _defaultAccountIds.contains(acc.id))
        .toList();
    final otherAccounts = accounts
        .where((acc) => !_defaultAccountIds.contains(acc.id))
        .toList();
    
    return [...defaultAccounts, ...otherAccounts];
  }

  bool _isDefaultAccount(String accountId) {
    return _defaultAccountIds.contains(accountId);
  }

  void _navigateToAddAccount() async {
    final result = await Navigator.pushNamed(context, '/add-account');
    if (result == true) {
      _loadAccounts();
    }
  }

  void _navigateToEditAccount(AccountModel account) async {
    // ✅ Debug: cek docId sebelum navigasi
    print('🔍 Navigating to edit - docId: ${account.docId}');
    
    if (account.docId == null || account.docId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Account ID is missing'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final result = await Navigator.pushNamed(
      context,
      '/edit-account',
      arguments: account,
    );
    if (result == true) {
      _loadAccounts();
    }
  }

  Future<void> _deleteAccount(AccountModel account) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Delete Account',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${account.name}"?\nThis action cannot be undone.',
          style: const TextStyle(
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.grey,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // ✅ Gunakan docId untuk delete
        if (account.docId == null || account.docId!.isEmpty) {
          throw Exception('Document ID is missing');
        }

        await _accountService.deleteAccount(account.docId!);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${account.name} deleted successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          
          _loadAccounts();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting account: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF017282), Color(0xFF001645)],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Manage Account',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF017282),
              ),
            )
          : _accounts.isEmpty
              ? _buildEmptyState()
              : _buildAccountList(),
      bottomNavigationBar: _buildAddButton(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No accounts yet',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to add your first account',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Colors.grey[400],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _accounts.length,
      itemBuilder: (context, index) {
        final account = _accounts[index];
        final isDefault = _isDefaultAccount(account.id);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDefault 
                  ? Colors.amber.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
              width: isDefault ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            leading: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: account.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                account.icon,
                color: account.color,
                size: 28,
              ),
            ),
            title: Row(
              children: [
                Flexible(
                  child: Text(
                    account.name,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                if (isDefault) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.amber.shade400,
                          Colors.amber.shade600,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'DEFAULT',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.accountType, // ✅ Tampilkan account type
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 2),
                account.balance > 0
                    ? Text(
                        'Rp ${account.balance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      )
                    : Text(
                        'Belum ada saldo',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[400],
                        ),
                      ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  color: const Color(0xFF017282),
                  onPressed: () => _navigateToEditAccount(account),
                  tooltip: 'Edit',
                ),
                if (!isDefault)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red[400],
                    onPressed: () => _deleteAccount(account),
                    tooltip: 'Delete',
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _navigateToAddAccount,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF017282),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: Colors.white, size: 24),
                SizedBox(width: 8),
                Text(
                  'Add Account',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}