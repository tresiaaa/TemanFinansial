import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddNotesPage extends StatefulWidget {
  final bool isEditMode;
  final String? initialCategory;
  final IconData? initialIcon;
  final String? initialAmount;
  final String? initialTransactionType;
  final String? initialDate;

  const AddNotesPage({
    super.key,
    this.isEditMode = false,
    this.initialCategory,
    this.initialIcon,
    this.initialAmount,
    this.initialTransactionType,
    this.initialDate,
  });

  @override
  State<AddNotesPage> createState() => _AddNotesPageState();
}

class _AddNotesPageState extends State<AddNotesPage> {
  int _selectedTab = 0; // 0: Expense, 1: Income, 2: Transfer
  String? _selectedCategory; // Track selected category
  IconData? _selectedIcon;

  @override
  void initState() {
    super.initState();
    
    // Initialize with edit data if in edit mode
    if (widget.isEditMode) {
      _selectedCategory = widget.initialCategory;
      _selectedIcon = widget.initialIcon;
      
      // Set the correct tab based on transaction type
      if (widget.initialTransactionType == 'Income') {
        _selectedTab = 1;
      } else if (widget.initialTransactionType == 'Expense') {
        _selectedTab = 0;
      }
      
      // Automatically show overlay with initial data
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_selectedCategory != null && _selectedIcon != null) {
          _showTransactionOverlay(
            categoryLabel: _selectedCategory!,
            categoryIcon: _selectedIcon!,
            transactionType: widget.initialTransactionType ?? 'Expense',
            initialAmount: widget.initialAmount,
            initialDate: widget.initialDate,
          );
        }
      });
    }
  }

  final List<Map<String, dynamic>> _expenseCategories = [
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
    {'icon': Icons.local_hospital, 'label': 'Health'},
    {'icon': Icons.flight, 'label': 'Travel'},
    {'icon': Icons.pets, 'label': 'Pets'},
    {'icon': Icons.build, 'label': 'Repairs'},
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

  final List<Map<String, dynamic>> _incomeCategories = [
    {'icon': Icons.credit_card, 'label': 'Salary'},
    {'icon': Icons.trending_up, 'label': 'Investment'},
    {'icon': Icons.access_time, 'label': 'Part-Time'},
    {'icon': Icons.monetization_on, 'label': 'Bonus'},
    {'icon': Icons.more_horiz, 'label': 'Others'},
    {'icon': Icons.add_circle_outline, 'label': 'Settings'},
  ];

  void _showTransactionOverlay({
    required String categoryLabel,
    required IconData categoryIcon,
    required String transactionType,
    String? initialAmount,
    String? initialDate,
  }) {
    setState(() {
      _selectedCategory = categoryLabel;
      _selectedIcon = categoryIcon;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => TransactionOverlay(
        categoryLabel: categoryLabel,
        categoryIcon: categoryIcon,
        transactionType: transactionType,
        isEditMode: widget.isEditMode,
        initialAmount: initialAmount,
        initialDate: initialDate,
        onCategoryChange: (newLabel, newIcon, newType) {
          setState(() {
            _selectedCategory = newLabel;
            _selectedIcon = newIcon;
          });
        },
      ),
    ).then((_) {
      if (!widget.isEditMode) {
        setState(() {
          _selectedCategory = null;
          _selectedIcon = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 100,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF017282),
                Color(0xFF001645),
              ],
              stops: [0.0, 1.0],
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
      ),
      body: _selectedTab == 2 ? _buildTransferContent() : _buildCategoriesGrid(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF017282),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
          ),
          currentIndex: 1,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: 'Records',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle, size: 32),
              label: 'Add',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart),
              label: 'Charts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.savings_outlined),
              label: 'Saving',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
          onTap: (index) {
            if (index == 0) {
              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
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

  Widget _buildCategoriesGrid() {
    final categories = _selectedTab == 0 ? _expenseCategories : _incomeCategories;
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 18,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return _buildCategoryItem(
          icon: categories[index]['icon'],
          label: categories[index]['label'],
        );
      },
    );
  }

  Widget _buildTransferContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Akun Sumber',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Select source account'),
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
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
          
          const Text(
            'Akun Tujuan',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Select destination account'),
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
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
      ),
    );
  }

  Color _getCategoryColor() {
    switch (_selectedTab) {
      case 0:
        return const Color(0xFFB0BEC5);
      case 1:
        return const Color(0xFFC8E6C9);
      default:
        return const Color(0xFFB0BEC5);
    }
  }

  Color _getIconColor() {
    switch (_selectedTab) {
      case 0:
        return const Color(0xFF37474F);
      case 1:
        return const Color(0xFF2E7D32);
      default:
        return const Color(0xFF37474F);
    }
  }

  Widget _buildCategoryItem({
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedCategory == label;
    
    return GestureDetector(
      onTap: () {
        if (label == 'Settings') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Settings'),
              duration: Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        final transactionType = _selectedTab == 0 ? 'Expense' : 'Income';
        _showTransactionOverlay(
          categoryLabel: label,
          categoryIcon: icon,
          transactionType: transactionType,
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isSelected 
                  ? (_selectedTab == 0 
                      ? const Color(0xFF0277BD) 
                      : const Color(0xFF4CAF50))
                  : _getCategoryColor(),
              shape: BoxShape.circle,
              border: isSelected 
                  ? Border.all(color: Colors.white, width: 3)
                  : null,
            ),
            child: Icon(
              icon,
              size: 26,
              color: isSelected ? Colors.white : _getIconColor(),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? const Color(0xFF0277BD) : const Color(0xFF1A1A1A),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// Transaction Overlay Widget
class TransactionOverlay extends StatefulWidget {
  final String categoryLabel;
  final IconData categoryIcon;
  final String transactionType;
  final bool isEditMode;
  final String? initialAmount;
  final String? initialDate;
  final Function(String, IconData, String)? onCategoryChange;

  const TransactionOverlay({
    super.key,
    required this.categoryLabel,
    required this.categoryIcon,
    required this.transactionType,
    this.isEditMode = false,
    this.initialAmount,
    this.initialDate,
    this.onCategoryChange,
  });

  @override
  State<TransactionOverlay> createState() => _TransactionOverlayState();
}

class _TransactionOverlayState extends State<TransactionOverlay> {
  String _amount = '0';
  final TextEditingController _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    
    // Set initial values if in edit mode
    if (widget.isEditMode) {
      if (widget.initialAmount != null && widget.initialAmount!.isNotEmpty) {
        _amount = widget.initialAmount!;
      }
      
      if (widget.initialDate != null && widget.initialDate!.isNotEmpty) {
        try {
          // Parse date string (assuming format: "DD MMM YYYY" like "15 Nov 2024")
          _selectedDate = DateFormat('dd MMM yyyy').parse(widget.initialDate!);
        } catch (e) {
          _selectedDate = DateTime.now();
        }
      }
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _onNumberPressed(String value) {
    setState(() {
      if (_amount == '0') {
        _amount = value;
      } else {
        _amount += value;
      }
    });
  }

  void _onOperatorPressed(String operator) {
    setState(() {
      if (_amount.isNotEmpty && !_amount.endsWith('+') && !_amount.endsWith('-')) {
        _amount += operator;
      }
    });
  }

  void _onClearPressed() {
    setState(() {
      if (_amount.isNotEmpty) {
        _amount = _amount.substring(0, _amount.length - 1);
        if (_amount.isEmpty) {
          _amount = '0';
        }
      }
    });
  }

  void _onDecimalPressed() {
    setState(() {
      if (!_amount.contains('.')) {
        _amount += '.';
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF017282),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _onSaveTransaction() {
    if (_amount != '0' && _amount.isNotEmpty) {
      Navigator.pop(context);
      
      final message = widget.isEditMode
          ? '${widget.transactionType} updated: ${widget.categoryLabel} - $_amount'
          : '${widget.transactionType} saved: ${widget.categoryLabel} - $_amount';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      // If in edit mode, pop back to transaction detail page
      if (widget.isEditMode) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {},
      child: Container(
        height: MediaQuery.of(context).size.height * 0.55,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 20),

                  Column(
                    children: [
                      const Text(
                        'Jumlah',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _amount,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),

            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        hintText: 'Note: Enter a note...',
                        hintStyle: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.grey[700],
                            size: 24,
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Camera feature'),
                                duration: Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.4,
                    children: [
                      _buildCalcButton('7', () => _onNumberPressed('7')),
                      _buildCalcButton('8', () => _onNumberPressed('8')),
                      _buildCalcButton('9', () => _onNumberPressed('9')),
                      _buildCalcButton(
                        DateFormat('MMM d\nyyyy').format(_selectedDate),
                        () => _selectDate(context),
                        isDate: true,
                      ),
                      _buildCalcButton('4', () => _onNumberPressed('4')),
                      _buildCalcButton('5', () => _onNumberPressed('5')),
                      _buildCalcButton('6', () => _onNumberPressed('6')),
                      _buildCalcButton('+', () => _onOperatorPressed('+')),
                      _buildCalcButton('1', () => _onNumberPressed('1')),
                      _buildCalcButton('2', () => _onNumberPressed('2')),
                      _buildCalcButton('3', () => _onNumberPressed('3')),
                      _buildCalcButton('-', () => _onOperatorPressed('-')),
                      _buildCalcButton('.', _onDecimalPressed),
                      _buildCalcButton('0', () => _onNumberPressed('0')),
                      _buildCalcButton('⌫', _onClearPressed),
                      _buildCalcButton('✓', _onSaveTransaction, isCheck: true),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalcButton(
    String label,
    VoidCallback onPressed, {
    bool isDate = false,
    bool isCheck = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0277BD),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: isDate ? 11 : (isCheck ? 28 : 20),
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: isDate ? 1.2 : 1.0,
            ),
          ),
        ),
      ),
    );
  }
}