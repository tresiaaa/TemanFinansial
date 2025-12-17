// lib/add_edit_account_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/account_service.dart';
import '../models/account_model.dart';

class AddEditAccountPage extends StatefulWidget {
  final AccountModel? account;

  const AddEditAccountPage({super.key, this.account});

  @override
  State<AddEditAccountPage> createState() => _AddEditAccountPageState();
}

class _AddEditAccountPageState extends State<AddEditAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _accountService = AccountService();
  
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  
  String _selectedIconName = 'account_balance_wallet';
  String _selectedColorHex = '#4CAF50';
  String _selectedAccountType = 'Default';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _availableIcons = [
    {'name': 'account_balance_wallet', 'icon': Icons.account_balance_wallet},
    {'name': 'account_balance', 'icon': Icons.account_balance},
    {'name': 'money', 'icon': Icons.attach_money},
    {'name': 'credit_card', 'icon': Icons.credit_card},
    {'name': 'savings', 'icon': Icons.savings},
    {'name': 'paid', 'icon': Icons.paid},
    {'name': 'currency_exchange', 'icon': Icons.currency_exchange},
    {'name': 'wallet', 'icon': Icons.wallet},
    {'name': 'payment', 'icon': Icons.payment},
    {'name': 'account_circle', 'icon': Icons.account_circle},
  ];

  final List<String> _availableColors = [
    '#4CAF50', '#2196F3', '#9C27B0', '#FF9800', '#F44336',
    '#03A9F4', '#1565C0', '#00BCD4', '#E91E63', '#795548',
  ];

  final List<String> _accountTypes = [
    'Default',
    'Cash',
    'Debit Card',
    'Virtual Account',
    'Credit Card',
    'E-Wallet',
  ];

  @override
  void initState() {
    super.initState();
    
    if (widget.account != null) {
      print('🔍 Edit mode - Document ID: ${widget.account!.docId}');
      print('🔍 Edit mode - Account Name: ${widget.account!.name}');
      print('🔍 Edit mode - Account Type: ${widget.account!.accountType}');
    }
    
    _nameController = TextEditingController(text: widget.account?.name ?? '');
    _amountController = TextEditingController(
      text: widget.account != null && widget.account!.balance > 0
          ? widget.account!.balance.toStringAsFixed(0)
          : '',
    );
    _noteController = TextEditingController();

    if (widget.account != null) {
      _selectedIconName = widget.account!.iconName;
      _selectedColorHex = widget.account!.colorHex;
      
      // ✅ Validasi account type dengan fallback
      final accountType = widget.account!.accountType;
      if (_accountTypes.contains(accountType)) {
        _selectedAccountType = accountType;
      } else {
        _selectedAccountType = 'Default';
        print('⚠️ Invalid account type "$accountType", using "Default"');
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool get _isEditMode => widget.account != null;

  Color _getColorFromHex(String hexColor) {
    return Color(int.parse(hexColor.substring(1), radix: 16) + 0xFF000000);
  }

  Future<void> _deleteAccount() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Delete Account',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete "${widget.account?.name}"?\n\nThis action cannot be undone.',
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      setState(() => _isLoading = true);

      try {
        if (widget.account!.docId == null || widget.account!.docId!.isEmpty) {
          throw Exception('Document ID is missing');
        }

        await _accountService.deleteAccount(widget.account!.docId!);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account deleted successfully'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        print('❌ Error deleting account: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting account: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _saveAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      final amount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0;

      if (_isEditMode) {
        if (widget.account!.docId == null || widget.account!.docId!.isEmpty) {
          throw Exception('Document ID is missing');
        }

        print('🔍 Updating account with docId: ${widget.account!.docId}');

        await _accountService.updateAccount(widget.account!.docId!, {
          'name': name,
          'balance': amount,
          'iconName': _selectedIconName,
          'colorHex': _selectedColorHex,
          'accountType': _selectedAccountType,
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account updated successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        final customId = name.toLowerCase().replaceAll(' ', '_');
        
        print('🔍 Creating new account with custom ID: $customId');
        
        final newAccount = AccountModel(
          docId: null,
          userId: '',
          id: customId,
          name: name,
          iconName: _selectedIconName,
          colorHex: _selectedColorHex,
          balance: amount,
          accountType: _selectedAccountType,
        );
        
        await _accountService.createAccount(newAccount);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      print('❌ Error saving account: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
        title: Text(
          _isEditMode ? 'Edit Account' : 'Add Account',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
              onPressed: _isLoading ? null : _deleteAccount,
            ),
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white, size: 28),
            onPressed: _isLoading ? null : _saveAccount,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF017282)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('ACCOUNT INFORMATION'),
                    const SizedBox(height: 20),
                    _buildAccountNameField(),
                    const SizedBox(height: 20),
                    _buildDefaultCurrencyField(),
                    const SizedBox(height: 20),
                    _buildAccountTypeField(),
                    const SizedBox(height: 20),
                    _buildAmountField(),
                    const SizedBox(height: 32),
                    _buildIconSelector(),
                    const SizedBox(height: 32),
                    _buildColorSelector(),
                    const SizedBox(height: 32),
                    _buildNoteField(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.grey[600],
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildAccountNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Account Name',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          style: const TextStyle(fontFamily: 'Poppins'),
          decoration: InputDecoration(
            hintText: 'Enter account name',
            hintStyle: TextStyle(fontFamily: 'Poppins', color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF017282), width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter account name';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDefaultCurrencyField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Default Currency',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Text(
                'IDR (Rp) Indonesian Rupiah',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Account Type',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedAccountType,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Color(0xFF1A1A1A),
              ),
              items: _accountTypes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedAccountType = newValue;
                  });
                  print('✅ Account type changed to: $newValue');
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amount',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(fontFamily: 'Poppins'),
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: TextStyle(fontFamily: 'Poppins', color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF017282), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Icon',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _availableIcons.map((iconData) {
            final iconName = iconData['name'] as String;
            final icon = iconData['icon'] as IconData;
            final isSelected = _selectedIconName == iconName;

            return GestureDetector(
              onTap: () => setState(() => _selectedIconName = iconName),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF017282) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF017282) : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.grey[700],
                  size: 28,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _availableColors.map((colorHex) {
            final color = _getColorFromHex(colorHex);
            final isSelected = _selectedColorHex == colorHex;

            return GestureDetector(
              onTap: () => setState(() => _selectedColorHex = colorHex),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 24)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNoteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Note',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _noteController,
          maxLines: 3,
          style: const TextStyle(fontFamily: 'Poppins'),
          decoration: InputDecoration(
            hintText: 'Optional note...',
            hintStyle: TextStyle(fontFamily: 'Poppins', color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF017282), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}