import 'package:flutter/material.dart';

class AddNotesPage extends StatefulWidget {
  const AddNotesPage({super.key});

  @override
  State<AddNotesPage> createState() => _AddNotesPageState();
}

class _AddNotesPageState extends State<AddNotesPage> {
  int _selectedTab = 0; // 0: Expense, 1: Income, 2: Transfer

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
          // Akun Sumber
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
          
          // Icon Transfer
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
          
          // Akun Tujuan
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
      case 0: // Expense
        return const Color(0xFFB0BEC5);
      case 1: // Income
        return const Color(0xFFC8E6C9);
      default:
        return const Color(0xFFB0BEC5);
    }
  }

  Color _getIconColor() {
    switch (_selectedTab) {
      case 0: // Expense
        return const Color(0xFF37474F);
      case 1: // Income
        return const Color(0xFF2E7D32);
      default:
        return const Color(0xFF37474F);
    }
  }

  Widget _buildCategoryItem({
    required IconData icon,
    required String label,
  }) {
    return GestureDetector(
      onTap: () {
        final tabName = _selectedTab == 0 ? 'Expense' : 'Income';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label $tabName selected'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _getCategoryColor(),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 26,
              color: _getIconColor(),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1A1A),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}