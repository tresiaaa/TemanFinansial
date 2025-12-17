import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/category_grid.dart';
import 'transfer_notes_page.dart';
import '../services/account_service.dart';
import '../models/account_model.dart';

class CategorySelectionPage extends StatefulWidget {
  const CategorySelectionPage({super.key});

  @override
  State<CategorySelectionPage> createState() => _CategorySelectionPageState();
}

class _CategorySelectionPageState extends State<CategorySelectionPage> {
  int _selectedTab = 0;
  String? _selectedCategory;
  IconData? _selectedIcon;
  final ScrollController _scrollController = ScrollController();
  final AccountService _accountService = AccountService();
  
  // Transfer variables
  Map<String, dynamic>? _sourceAccount;
  Map<String, dynamic>? _destinationAccount;
  
  List<AccountModel> _accounts = [];
  bool _isLoadingAccounts = true;

  // Default account IDs
  static const Set<String> _defaultAccountIds = {
    'gopay',
    'dana',
    'cash',
  };

  static const List<Map<String, dynamic>> _expenseCategories = [
    {'icon': Icons.shopping_cart, 'label': 'Shopping'},
    {'icon': Icons.restaurant, 'label': 'Food'},
    {'icon': Icons.phone_android, 'label': 'Phone'},
    {'icon': Icons.school, 'label': 'Education'},
    {'icon': Icons.content_cut, 'label': 'Beauty'},
    {'icon': Icons.directions_run, 'label': 'Sport'},
    {'icon': Icons.group, 'label': 'Social'},
    {'icon': Icons.checkroom, 'label': 'Clothing'},
    {'icon': Icons.directions_car, 'label': 'Car'},
    {'icon': Icons.local_bar, 'label': 'Alcohol'},
    {'icon': Icons.smoking_rooms, 'label': 'Cigarettes'},
    {'icon': Icons.directions_bus, 'label': 'Transport'},
    {'icon': Icons.power_settings_new, 'label': 'Electronics'},
    {'icon': Icons.home_repair_service, 'label': 'Repairs'},
    {'icon': Icons.flight, 'label': 'Travel'},
    {'icon': Icons.pets, 'label': 'Pets'},
    {'icon': Icons.local_hospital, 'label': 'Health'},
    {'icon': Icons.home_work, 'label': 'Housing'},
    {'icon': Icons.card_giftcard, 'label': 'Gifts'},
    {'icon': Icons.volunteer_activism, 'label': 'Donations'},
    {'icon': Icons.confirmation_number, 'label': 'Lottery'},
    {'icon': Icons.fastfood, 'label': 'Snacks'},
    {'icon': Icons.child_care, 'label': 'Kids'},
    {'icon': Icons.eco, 'label': 'Vegetables'},
    {'icon': Icons.apple, 'label': 'Fruits'},
    {'icon': Icons.theater_comedy, 'label': 'Entertainment'},
    {'icon': Icons.cottage, 'label': 'Home'},
    {'icon': Icons.add_circle_outline, 'label': 'Settings'},
  ];

  static const List<Map<String, dynamic>> _incomeCategories = [
    {'icon': Icons.credit_card, 'label': 'Salary'},
    {'icon': Icons.trending_up, 'label': 'Investment'},
    {'icon': Icons.access_time, 'label': 'Part-Time'},
    {'icon': Icons.monetization_on, 'label': 'Bonus'},
    {'icon': Icons.more_horiz, 'label': 'Others'},
    {'icon': Icons.add_circle_outline, 'label': 'Settings'},
  ];

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    setState(() => _isLoadingAccounts = true);

    try {
      final accounts = await _accountService.getUserAccountsFuture();

      if (accounts.isEmpty) {
        await _accountService.createDefaultAccounts();
        final newAccounts = await _accountService.getUserAccountsFuture();
        setState(() {
          _accounts = _sortAccounts(newAccounts);
          _isLoadingAccounts = false;
        });
      } else {
        setState(() {
          _accounts = _sortAccounts(accounts);
          _isLoadingAccounts = false;
        });
      }

      print('✅ Loaded ${_accounts.length} accounts');
    } catch (e) {
      print('❌ Error loading accounts: $e');
      setState(() => _isLoadingAccounts = false);
      
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

  // Sort accounts: default accounts first, then others
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

  void _onCategorySelected(String label, IconData icon) {
    setState(() {
      _selectedCategory = label;
      _selectedIcon = icon;
    });
    
    Navigator.pushNamed(
      context,
      '/add-notes',
      arguments: {
        'category': label,
        'icon': icon,
        'type': _selectedTab == 0 ? 'expense' : 'income',
      },
    );
  }

  void _showAccountSelectionOverlay(String type) {
    if (_isLoadingAccounts) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Loading accounts...'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF003D82), Color(0xFF001645)],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const Text(
                    'Pilih Akun',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white, size: 28),
                    onPressed: () async {
                      Navigator.pop(context); // Close overlay first
                      final result = await Navigator.pushNamed(context, '/manage-accounts');
                      if (result == true) {
                        _loadAccounts(); // Reload accounts if changes were made
                      }
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _accounts.isEmpty
                  ? const Center(
                      child: Text(
                        'No accounts found',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white70,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _accounts.length,
                      itemBuilder: (context, index) {
                        final account = _accounts[index];
                        final isDisabled = type == 'destination' &&
                            _sourceAccount != null &&
                            _sourceAccount!['id'] == account.id;
                        final isDefault = _isDefaultAccount(account.id);

                        return Opacity(
                          opacity: isDisabled ? 0.5 : 1.0,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF004A7F),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDefault 
                                    ? Colors.amber.withOpacity(0.5)
                                    : Colors.white.withOpacity(0.1),
                                width: isDefault ? 2 : 1,
                              ),
                            ),
                            child: Stack(
                              children: [
                                ListTile(
                                  enabled: !isDisabled,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  leading: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: account.color.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      account.icon,
                                      color: Colors.white,
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
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      if (isDefault) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.amber.shade400,
                                                Colors.amber.shade600,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            'DEFAULT',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  subtitle: account.balance > 0
                                      ? Text(
                                          'Rp ${account.balance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 14,
                                            color: Colors.white.withOpacity(0.8),
                                          ),
                                        )
                                      : Text(
                                          'Belum ada saldo',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 14,
                                            fontStyle: FontStyle.italic,
                                            color: Colors.white.withOpacity(0.5),
                                          ),
                                        ),
                                  onTap: isDisabled
                                      ? null
                                      : () {
                                          setState(() {
                                            if (type == 'source') {
                                              _sourceAccount = account.toSelectionMap();
                                            } else {
                                              _destinationAccount = account.toSelectionMap();
                                            }
                                          });
                                          Navigator.pop(context);
                                        },
                                ),
                                // Star icon for default accounts
                                if (isDefault)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Icon(
                                      Icons.star,
                                      color: Colors.amber.shade400,
                                      size: 20,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTransferNotes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransferNotesPage(
          sourceAccount: _sourceAccount!,
          destinationAccount: _destinationAccount!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _selectedTab == 2 
          ? _buildTransferContent() 
          : _buildCategoryContent(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 100,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF017282), Color(0xFF001645)],
          ),
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: const Text(
        'Add Notes',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF003D82),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildTabButton('Expense', 0),
                _buildTabButton('Income', 1),
                _buildTabButton('Transfer', 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isSelected ? const Color(0xFF017282) : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryContent() {
    final categories = _selectedTab == 0 
        ? _expenseCategories 
        : _incomeCategories;
    
    return CategoryGrid(
      categories: categories,
      selectedCategory: _selectedCategory,
      scrollController: _scrollController,
      onCategoryTap: _onCategorySelected,
    );
  }

  Widget _buildTransferContent() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTransferSection('Akun Sumber', 'source', _sourceAccount),
                const SizedBox(height: 32),
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0277BD),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.swap_horiz,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _buildTransferSection('Akun Tujuan', 'destination', _destinationAccount),
              ],
            ),
          ),
        ),
        if (_sourceAccount != null && _destinationAccount != null)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
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
                  onPressed: _navigateToTransferNotes,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF017282),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Lanjutkan',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTransferSection(
    String title, 
    String type, 
    Map<String, dynamic>? selectedAccount,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => _showAccountSelectionOverlay(type),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: selectedAccount != null 
                  ? selectedAccount['color'].withOpacity(0.1)
                  : const Color(0xFFB0BEC5),
              borderRadius: BorderRadius.circular(16),
              border: selectedAccount != null
                  ? Border.all(
                      color: selectedAccount['color'],
                      width: 2,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    selectedAccount?['icon'] ?? Icons.add,
                    size: 28,
                    color: selectedAccount?['color'] ?? const Color(0xFF37474F),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedAccount?['name'] ?? 'Select',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      if (selectedAccount != null && selectedAccount['balance'] > 0)
                        Text(
                          'Rp ${selectedAccount['balance'].toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        )
                      else if (selectedAccount != null)
                        Text(
                          'Belum ada saldo',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[400],
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}