import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'calendar_page.dart';
import 'profile_screen.dart';
import 'widgets/month_picker_dialog.dart';
import 'widgets/transaction_list_item.dart';
import 'models/transaction_model.dart';
import 'services/firestore_service.dart';
import 'category_selection_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _firestoreService = FirestoreService();
  
  int _selectedIndex = 0;
  String _selectedMonth = 'Sep';
  int _selectedYear = 2025;
  int _refreshKey = 0;
  
  double _totalExpense = 0;
  double _totalIncome = 0;
  double _balance = 0;
  
  final List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    _selectedMonth = _months[now.month - 1];
    _selectedYear = now.year;
    _loadMonthlyData();
  }

  // ✅ FIXED: Tambahkan listener untuk lifecycle changes
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload data setiap kali widget di-rebuild
    _loadMonthlyData();
  }

  Future<void> _loadMonthlyData() async {
    int monthIndex = _months.indexOf(_selectedMonth) + 1;
    
    double expense = await _firestoreService.getTotalExpenseByMonth(_selectedYear, monthIndex);
    double income = await _firestoreService.getTotalIncomeByMonth(_selectedYear, monthIndex);
    
    if (mounted) {
      setState(() {
        _totalExpense = expense;
        _totalIncome = income;
        _balance = income - expense;
        _refreshKey++;
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CategorySelectionPage(),
        ),
      ).then((_) {
        // ✅ FIXED: Selalu reload data setelah kembali dari add transaction
        _loadMonthlyData();
        
        if (mounted) {
          setState(() {
            _selectedIndex = 0;
          });
        }
      });
    } 
    else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
        ),
      ).then((_) {
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
            _loadMonthlyData();
          },
        );
      },
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
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
          // ✅ FIXED: Header dengan data yang ter-update otomatis
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
                        ).then((_) {
                          _loadMonthlyData();
                        });
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
                
                Row(
                  children: [
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
                    
                    // ✅ FIXED: Display real-time calculated values
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildAmountColumn(label: 'Expenses', amount: _totalExpense),
                            const SizedBox(width: 24),
                            _buildAmountColumn(label: 'Income', amount: _totalIncome),
                            const SizedBox(width: 24),
                            _buildAmountColumn(label: 'Balance', amount: _balance),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
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
          
          Expanded(
            child: StreamBuilder<List<TransactionModel>>(
              key: ValueKey(_refreshKey),
              stream: _firestoreService.getTransactionsByMonth(
                _selectedYear,
                _months.indexOf(_selectedMonth) + 1,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF1976D2),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada transaksi',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap tombol + untuk menambah transaksi',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                List<TransactionModel> transactions = snapshot.data!;
                
                Map<String, List<TransactionModel>> groupedTransactions = {};
                for (var transaction in transactions) {
                  String dateKey = DateFormat('EEEE dd MMM', 'id_ID').format(transaction.date);
                  if (!groupedTransactions.containsKey(dateKey)) {
                    groupedTransactions[dateKey] = [];
                  }
                  groupedTransactions[dateKey]!.add(transaction);
                }

                return ListView(
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
                    
                    ...groupedTransactions.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 8),
                            child: Text(
                              entry.key,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          ...entry.value.map((transaction) {
                            String amountStr;
                            if (transaction.type == 'expense') {
                              amountStr = '-${_formatCurrency(transaction.amount)}';
                            } else if (transaction.type == 'income') {
                              amountStr = '+${_formatCurrency(transaction.amount)}';
                            } else {
                              amountStr = _formatCurrency(transaction.amount);
                            }

                            return TransactionListItem(
                              icon: transaction.icon,
                              color: transaction.color,
                              title: transaction.category,
                              amount: amountStr,
                              isExpense: transaction.type == 'expense',
                              date: DateFormat('MMM dd, yyyy').format(transaction.date),
                              transactionId: transaction.id,
                              note: transaction.note,
                              onRefresh: () {
                                _loadMonthlyData();
                              },
                            );
                          }).toList(),
                        ],
                      );
                    }).toList(),
                    
                    const SizedBox(height: 80),
                    
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
                            _loadMonthlyData();
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
                            _loadMonthlyData();
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
                );
              },
            ),
          ),
        ],
      ),
      
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

  Widget _buildAmountColumn({required String label, required double amount}) {
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
          _formatCurrency(amount),
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