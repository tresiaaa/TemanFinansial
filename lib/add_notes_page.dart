import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/transaction_model.dart';
import '../widgets/transaction_calculator.dart';
import '../widgets/category_grid.dart';

class AddNotesPage extends StatefulWidget {
  final bool isEditMode;
  final String? initialCategory;
  final IconData? initialIcon;
  final String? initialAmount;
  final String? initialTransactionType;
  final String? initialDate;
  final String? transactionId;
  final String? initialNote;

  const AddNotesPage({
    super.key,
    this.isEditMode = false,
    this.initialCategory,
    this.initialIcon,
    this.initialAmount,
    this.initialTransactionType,
    this.initialDate,
    this.transactionId,
    this.initialNote,
  });

  @override
  State<AddNotesPage> createState() => _AddNotesPageState();
}

class _AddNotesPageState extends State<AddNotesPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _noteController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  int _selectedTab = 0;
  String? _selectedCategory;
  IconData? _selectedIcon;
  String _amount = '0';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

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
    _initializeEditMode();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeEditMode() {
    if (!widget.isEditMode) return;

    _selectedCategory = widget.initialCategory;
    _selectedIcon = widget.initialIcon;
    
    if (widget.initialAmount?.isNotEmpty ?? false) {
      _amount = widget.initialAmount!;
    }
    
    if (widget.initialDate?.isNotEmpty ?? false) {
      _selectedDate = _parseDate(widget.initialDate!);
    }
    
    if (widget.initialNote?.isNotEmpty ?? false) {
      _noteController.text = widget.initialNote!;
    }
    
    _selectedTab = _getTabIndex(widget.initialTransactionType);
  }

  DateTime _parseDate(String dateString) {
    try {
      return DateFormat('MMM dd, yyyy').parse(dateString);
    } catch (e) {
      try {
        return DateFormat('dd MMM yyyy').parse(dateString);
      } catch (e2) {
        return DateTime.now();
      }
    }
  }

  int _getTabIndex(String? type) {
    switch (type) {
      case 'income': return 1;
      case 'transfer': return 2;
      default: return 0;
    }
  }

  void _onNumberPressed(String value) {
    setState(() => _amount == '0' ? _amount = value : _amount += value);
  }
  
  void _onOperatorPressed(String operator) {
    setState(() {
      if (_amount.isNotEmpty && 
          !_amount.endsWith('+') && 
          !_amount.endsWith('-')) {
        _amount += operator;
      }
    });
  }
  
  void _onClearPressed() {
    setState(() {
      if (_amount.isNotEmpty) {
        _amount = _amount.substring(0, _amount.length - 1);
        if (_amount.isEmpty) _amount = '0';
      }
    });
  }
  
  void _onDecimalPressed() {
    setState(() {
      if (!_amount.contains('.')) _amount += '.';
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF017282),
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _onSaveTransaction() async {
    if (_amount == '0' || _amount.isEmpty) {
      _showError('Please enter an amount');
      return;
    }

    if (_selectedCategory == null || _selectedIcon == null) {
      _showError('Please select a category');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final finalAmount = _calculateAmount(_amount);
      final transactionType = _selectedTab == 0 ? 'expense' : 'income';

      final transaction = TransactionModel(
        id: widget.transactionId ?? '',
        userId: user.uid,
        amount: finalAmount,
        category: _selectedCategory!,
        type: transactionType,
        date: _selectedDate,
        note: _noteController.text.isEmpty ? null : _noteController.text,
        iconCodePoint: _selectedIcon!.codePoint,
        colorValue: transactionType == 'expense' ? 0xFFB0BEC5 : 0xFFC8E6C9,
      );

      if (widget.isEditMode && widget.transactionId?.isNotEmpty == true) {
        await _firestoreService.updateTransaction(widget.transactionId!, transaction);
        if (mounted) {
          // ✅ Pop semua routes dan kembali ke HomePage
          Navigator.of(context).popUntil((route) => route.isFirst);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaction updated successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        await _firestoreService.addTransaction(transaction);
        if (mounted) {
          // ✅ Pop semua routes dan kembali ke HomePage dengan result true
          Navigator.of(context).popUntil((route) => route.isFirst);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaction added successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double _calculateAmount(String expression) {
    try {
      double result = 0;
      String currentNumber = '';
      String currentOperator = '+';
      
      for (int i = 0; i < expression.length; i++) {
        String char = expression[i];
        
        if (char == '+' || char == '-') {
          if (currentNumber.isNotEmpty) {
            double number = double.parse(currentNumber);
            result = currentOperator == '+' ? result + number : result - number;
            currentNumber = '';
          }
          currentOperator = char;
        } else {
          currentNumber += char;
        }
      }
      
      if (currentNumber.isNotEmpty) {
        double number = double.parse(currentNumber);
        result = currentOperator == '+' ? result + number : result - number;
      }
      
      return result.abs();
    } catch (e) {
      throw Exception('Invalid amount format');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(),
      body: _selectedTab == 2 
          ? _buildTransferContent() 
          : _buildMainContent(),
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
      title: Text(
        widget.isEditMode ? 'Edit' : 'Add Notes',
        style: const TextStyle(
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

  Widget _buildMainContent() {
    final categories = _selectedTab == 0 
        ? _expenseCategories 
        : _incomeCategories;
    
    return SingleChildScrollView(
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 
               AppBar().preferredSize.height - 
               MediaQuery.of(context).padding.top - 160,
        child: Column(
          children: [
            Expanded(
              child: CategoryGrid(
                categories: categories,
                selectedCategory: _selectedCategory,
                scrollController: _scrollController,
                onCategoryTap: (label, icon) {
                  setState(() {
                    _selectedCategory = label;
                    _selectedIcon = icon;
                  });
                },
              ),
            ),
            TransactionCalculator(
              amount: _amount,
              noteController: _noteController,
              selectedDate: _selectedDate,
              isLoading: _isLoading,
              onNumberPressed: _onNumberPressed,
              onOperatorPressed: _onOperatorPressed,
              onClearPressed: _onClearPressed,
              onDecimalPressed: _onDecimalPressed,
              onDateSelect: _selectDate,
              onSave: _onSaveTransaction,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTransferSection('Akun Sumber', 'source'),
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
          _buildTransferSection('Akun Tujuan', 'destination'),
        ],
      ),
    );
  }

  Widget _buildTransferSection(String title, String type) {
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
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Select $type account'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFB0BEC5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 28,
                    color: Color(0xFF37474F),
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Select',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}