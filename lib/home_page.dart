import 'package:flutter/material.dart';
import 'calendar_page.dart'; // Import CalendarPage
import 'transaction_detail_page.dart'; // Import Transaction Detail Page
import 'add_notes_page.dart'; // Import Add Notes Page

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _selectedMonth = 'Sep';
  int _selectedYear = 2025;
  
  final List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  void _onItemTapped(int index) {
    // Navigate to Add Notes page when Add button is tapped
    if (index == 1) {
      // Jangan set state dulu, biarkan tetap di index yang sekarang
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddNotesPage(),
        ),
      ).then((_) {
        // Setelah kembali dari Add Notes, set selected index ke Records (0)
        setState(() {
          _selectedIndex = 0;
        });
      });
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // Show Month Picker Dialog
  void _showMonthPicker() {
    String tempMonth = _selectedMonth;
    int tempYear = _selectedYear;
    bool showYearPicker = false;
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      '${_getFullMonthName(tempMonth)} $tempYear',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Year Selector with Dropdown
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              showYearPicker = !showYearPicker;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '$tempYear',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  showYearPicker 
                                      ? Icons.keyboard_arrow_up 
                                      : Icons.keyboard_arrow_down,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Sembunyikan tombol < > saat dropdown terbuka
                        if (!showYearPicker) ...[
                          const SizedBox(width: 16),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left),
                                onPressed: () {
                                  setDialogState(() {
                                    tempYear = tempYear - 1;
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.chevron_right),
                                onPressed: () {
                                  setDialogState(() {
                                    tempYear = tempYear + 1;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Year Picker List (Dropdown)
                    if (showYearPicker)
                      Container(
                        height: 200,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListView.builder(
                          itemCount: 21, // 10 tahun sebelum dan sesudah
                          itemBuilder: (context, index) {
                            final year = tempYear - 10 + index;
                            final isSelected = year == tempYear;
                            
                            return InkWell(
                              onTap: () {
                                setDialogState(() {
                                  tempYear = year;
                                  showYearPicker = false;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                color: isSelected 
                                    ? const Color(0xFF64B5F6).withOpacity(0.3)
                                    : Colors.transparent,
                                child: Text(
                                  '$year',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: isSelected 
                                        ? FontWeight.w600 
                                        : FontWeight.normal,
                                    color: isSelected 
                                        ? const Color(0xFF1976D2)
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    
                    // Month Grid (Tanpa Border)
                    SizedBox(
                      width: 320,
                      child: GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 4,
                        childAspectRatio: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        children: _months.map((month) {
                          final isSelected = month == tempMonth;
                          
                          return InkWell(
                            onTap: () {
                              setDialogState(() {
                                tempMonth = month;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? const Color(0xFF64B5F6)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                month,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: isSelected 
                                      ? FontWeight.w600 
                                      : FontWeight.normal,
                                  color: isSelected 
                                      ? Colors.white 
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Action Buttons dengan Jarak Lebih Lebar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              color: Color(0xFF1976D2),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedMonth = tempMonth;
                              _selectedYear = tempYear;
                            });
                            Navigator.of(dialogContext).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Confirm',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getFullMonthName(String shortMonth) {
    const monthMap = {
      'Jan': 'January',
      'Feb': 'February',
      'Mar': 'March',
      'Apr': 'April',
      'May': 'May',
      'Jun': 'June',
      'Jul': 'July',
      'Aug': 'August',
      'Sep': 'September',
      'Oct': 'October',
      'Nov': 'November',
      'Dec': 'December',
    };
    return monthMap[shortMonth] ?? shortMonth;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0D47A1),
                    Color(0xFF1565C0),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Title and Calendar Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Spacer(),
                      const Text(
                        'Teman Finansial',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CalendarPage(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.calendar_today,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Month Selector and Amount Info (Horizontal Scrollable)
                  Row(
                    children: [
                      // Month Dropdown - CLICKABLE
                      GestureDetector(
                        onTap: _showMonthPicker,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _selectedMonth,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Scrollable Amount Info
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              // Expenses Column
                              _buildAmountColumn(
                                label: 'Expenses',
                                amount: '695,000',
                              ),
                              const SizedBox(width: 24),
                              
                              // Income Column
                              _buildAmountColumn(
                                label: 'Income',
                                amount: '5,350,000',
                              ),
                              const SizedBox(width: 24),
                              
                              // Balance Column
                              _buildAmountColumn(
                                label: 'Balance',
                                amount: '4,655,000',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Year Label
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        '$_selectedYear',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Transaction List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Riwayat Transaksi',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Selasa 30 Sep
                  _buildDateHeader('Selasa 30 Sep'),
                  _buildTransactionItem(
                    icon: Icons.school,
                    color: const Color(0xFFFFF59D),
                    title: 'Education',
                    amount: '-250,000',
                    isExpense: true,
                    date: 'Sep 30, 2025',
                  ),
                  _buildTransactionItem(
                    icon: Icons.monetization_on,
                    color: const Color(0xFFB39DDB),
                    title: 'Bonus',
                    amount: '750,000',
                    isExpense: false,
                    date: 'Sep 30, 2025',
                  ),
                  
                  // Senin 29 Sep
                  _buildDateHeader('Senin 29 Sep'),
                  _buildTransactionItem(
                    icon: Icons.directions_bus,
                    color: const Color(0xFFA5D6A7),
                    title: 'Transportation',
                    amount: '-25,000',
                    isExpense: true,
                    date: 'Sep 29, 2025',
                  ),
                  _buildTransactionItem(
                    icon: Icons.cake,
                    color: const Color(0xFFCE93D8),
                    title: 'Snacks',
                    amount: '-20,000',
                    isExpense: true,
                    date: 'Sep 29, 2025',
                  ),
                  
                  // Kamis 25 Sep
                  _buildDateHeader('Kamis 25 Sep'),
                  _buildTransactionItem(
                    icon: Icons.directions_run,
                    color: const Color(0xFFA5D6A7),
                    title: 'Sports',
                    amount: '-100,000',
                    isExpense: true,
                    date: 'Sep 25, 2025',
                  ),
                  _buildTransactionItem(
                    icon: Icons.shopping_cart,
                    color: const Color(0xFFFFCC80),
                    title: 'Shopping',
                    amount: '-200,000',
                    isExpense: true,
                    date: 'Sep 25, 2025',
                  ),
                  _buildTransactionItem(
                    icon: Icons.sync_alt,
                    color: const Color(0xFFB0BEC5),
                    title: 'Mandiri → GoPay',
                    amount: '25,000 → 25,000',
                    isExpense: false,
                    isTransfer: true,
                    date: 'Sep 25, 2025',
                  ),
                  
                  // Senin 29 Sep (kedua)
                  _buildDateHeader('Senin 29 Sep'),
                  _buildTransactionItem(
                    icon: Icons.restaurant,
                    color: const Color(0xFFB3E5FC),
                    title: 'Food',
                    amount: '15,000',
                    isExpense: true,
                    date: 'Sep 29, 2025',
                  ),
                  _buildTransactionItem(
                    icon: Icons.cake,
                    color: const Color(0xFFCE93D8),
                    title: 'Snacks',
                    amount: '10,000',
                    isExpense: true,
                    date: 'Sep 29, 2025',
                  ),
                  
                  // Minggu 29 Sep
                  _buildDateHeader('Minggu 29 Sep'),
                  _buildTransactionItem(
                    icon: Icons.restaurant,
                    color: const Color(0xFFB3E5FC),
                    title: 'Food',
                    amount: '15,000',
                    isExpense: true,
                    date: 'Sep 29, 2025',
                  ),
                  _buildTransactionItem(
                    icon: Icons.cake,
                    color: const Color(0xFFCE93D8),
                    title: 'Snacks',
                    amount: '10,000',
                    isExpense: true,
                    date: 'Sep 29, 2025',
                  ),
                  
                  const SizedBox(height: 80),
                  
                  // Month Navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            int monthIndex = _months.indexOf(_selectedMonth);
                            if (monthIndex > 0) {
                              _selectedMonth = _months[monthIndex - 1];
                            } else {
                              _selectedMonth = _months[11];
                              _selectedYear--;
                            }
                          });
                        },
                        icon: const Icon(Icons.arrow_back, size: 16),
                        label: Text(
                          _getPreviousMonthLabel(),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 32),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            int monthIndex = _months.indexOf(_selectedMonth);
                            if (monthIndex < 11) {
                              _selectedMonth = _months[monthIndex + 1];
                            } else {
                              _selectedMonth = _months[0];
                              _selectedYear++;
                            }
                          });
                        },
                        child: Row(
                          children: [
                            Text(
                              _getNextMonthLabel(),
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
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
          selectedItemColor: const Color(0xFF1565C0),
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
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: 'Records',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline, size: 32),
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
        ),
      ),
    );
  }

  String _getPreviousMonthLabel() {
    int monthIndex = _months.indexOf(_selectedMonth);
    if (monthIndex > 0) {
      return '${_months[monthIndex - 1]} $_selectedYear';
    } else {
      return 'Dec ${_selectedYear - 1}';
    }
  }

  String _getNextMonthLabel() {
    int monthIndex = _months.indexOf(_selectedMonth);
    if (monthIndex < 11) {
      return '${_months[monthIndex + 1]} $_selectedYear';
    } else {
      return 'Jan ${_selectedYear + 1}';
    }
  }

  Widget _buildAmountColumn({
    required String label,
    required String amount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        date,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required Color color,
    required String title,
    required String amount,
    required bool isExpense,
    bool isTransfer = false,
    String? date,
  }) {
    return GestureDetector(
      onTap: () {
        // Navigate to transaction detail page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionDetailPage(
              icon: icon,
              color: color,
              title: title,
              amount: amount,
              isExpense: isExpense,
              date: date ?? 'Sep 30, 2025',
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.black87,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            
            // Title
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            
            // Amount
            Text(
              amount,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}