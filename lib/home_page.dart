import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'calendar_page.dart';
import 'add_notes_page.dart';
import 'profile_screen.dart';
import 'widgets/month_picker_dialog.dart';
import 'widgets/financial_summary_widget.dart';
import 'widgets/transaction_list_item.dart';

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
    } 
    // Navigate to Profile Screen when Profile button is tapped
    else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
        ),
      ).then((_) {
        // Setelah kembali dari Profile, set selected index ke Records (0)
        setState(() {
          _selectedIndex = 0;
        });
      });
    } 
    else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // Show Month Picker Dialog
  void _showMonthPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MonthPickerDialog(
          initialMonth: _selectedMonth,
          initialYear: _selectedYear,
          months: _months,
          onConfirm: (month, year) {
            setState(() {
              _selectedMonth = month;
              _selectedYear = year;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ubah warna status bar jadi transparan dengan icon putih
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      body: Column(
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
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 10,
              20,
              20,
            ),
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
                    const Expanded(
                      child: FinancialSummaryWidget(),
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
                const DateHeader(date: 'Selasa 30 Sep'),
                const TransactionListItem(
                  icon: Icons.school,
                  color: Color(0xFFFFF59D),
                  title: 'Education',
                  amount: '-250,000',
                  isExpense: true,
                  date: 'Sep 30, 2025',
                ),
                const TransactionListItem(
                  icon: Icons.monetization_on,
                  color: Color(0xFFB39DDB),
                  title: 'Bonus',
                  amount: '750,000',
                  isExpense: false,
                  date: 'Sep 30, 2025',
                ),
                
                // Senin 29 Sep
                const DateHeader(date: 'Senin 29 Sep'),
                const TransactionListItem(
                  icon: Icons.directions_bus,
                  color: Color(0xFFA5D6A7),
                  title: 'Transportation',
                  amount: '-25,000',
                  isExpense: true,
                  date: 'Sep 29, 2025',
                ),
                const TransactionListItem(
                  icon: Icons.cake,
                  color: Color(0xFFCE93D8),
                  title: 'Snacks',
                  amount: '-20,000',
                  isExpense: true,
                  date: 'Sep 29, 2025',
                ),
                
                // Kamis 25 Sep
                const DateHeader(date: 'Kamis 25 Sep'),
                const TransactionListItem(
                  icon: Icons.directions_run,
                  color: Color(0xFFA5D6A7),
                  title: 'Sports',
                  amount: '-100,000',
                  isExpense: true,
                  date: 'Sep 25, 2025',
                ),
                const TransactionListItem(
                  icon: Icons.shopping_cart,
                  color: Color(0xFFFFCC80),
                  title: 'Shopping',
                  amount: '-200,000',
                  isExpense: true,
                  date: 'Sep 25, 2025',
                ),
                const TransactionListItem(
                  icon: Icons.sync_alt,
                  color: Color(0xFFB0BEC5),
                  title: 'Mandiri → GoPay',
                  amount: '25,000 → 25,000',
                  isExpense: false,
                  isTransfer: true,
                  date: 'Sep 25, 2025',
                ),
                
                // Senin 29 Sep (kedua)
                const DateHeader(date: 'Senin 29 Sep'),
                const TransactionListItem(
                  icon: Icons.restaurant,
                  color: Color(0xFFB3E5FC),
                  title: 'Food',
                  amount: '15,000',
                  isExpense: true,
                  date: 'Sep 29, 2025',
                ),
                const TransactionListItem(
                  icon: Icons.cake,
                  color: Color(0xFFCE93D8),
                  title: 'Snacks',
                  amount: '10,000',
                  isExpense: true,
                  date: 'Sep 29, 2025',
                ),
                
                // Minggu 29 Sep
                const DateHeader(date: 'Minggu 29 Sep'),
                const TransactionListItem(
                  icon: Icons.restaurant,
                  color: Color(0xFFB3E5FC),
                  title: 'Food',
                  amount: '15,000',
                  isExpense: true,
                  date: 'Sep 29, 2025',
                ),
                const TransactionListItem(
                  icon: Icons.cake,
                  color: Color(0xFFCE93D8),
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
}