import 'package:flutter/material.dart';
import '../widgets/category_grid.dart';

class CategorySelectionPage extends StatefulWidget {
  const CategorySelectionPage({super.key});

  @override
  State<CategorySelectionPage> createState() => _CategorySelectionPageState();
}

class _CategorySelectionPageState extends State<CategorySelectionPage> {
  int _selectedTab = 0; // 0: Expense, 1: Income, 2: Transfer
  String? _selectedCategory;
  IconData? _selectedIcon;
  final ScrollController _scrollController = ScrollController();

  // ===== Categories Data =====
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onCategorySelected(String label, IconData icon) {
    setState(() {
      _selectedCategory = label;
      _selectedIcon = icon;
    });
    
    // Langsung navigasi ke AddNotesPage dengan data kategori yang dipilih
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