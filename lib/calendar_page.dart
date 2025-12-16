import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'daily_transaction_page.dart';
import 'add_notes_page.dart';
import 'no_records_page.dart';  // ← TAMBAHAN
import 'services/firestore_service.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final FirestoreService _firestoreService = FirestoreService();
  
  String _selectedMonth = 'Aug';
  int _selectedYear = 2025;
  int? _selectedDay;
  
  final List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  
  List<int> _datesWithTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    _selectedMonth = _months[now.month - 1];
    _selectedYear = now.year;
    _loadTransactionDates();
  }

  Future<void> _loadTransactionDates() async {
    setState(() {
      _isLoading = true;
    });

    int monthIndex = _months.indexOf(_selectedMonth) + 1;
    List<int> dates = await _firestoreService.getTransactionDates(_selectedYear, monthIndex);
    
    if (mounted) {
      setState(() {
        _datesWithTransactions = dates;
        _isLoading = false;
      });
    }
  }

  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  int _getFirstDayOfMonth(int year, int month) {
    return DateTime(year, month, 1).weekday % 7;
  }

  String _formatDate(int day) {
    final monthIndex = _months.indexOf(_selectedMonth) + 1;
    return DateFormat('MMM dd, yyyy').format(DateTime(_selectedYear, monthIndex, day));
  }

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
                    
                    if (showYearPicker)
                      Container(
                        height: 200,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListView.builder(
                          itemCount: 21,
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
                            _loadTransactionDates();
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
    final monthIndex = _months.indexOf(_selectedMonth) + 1;
    final daysInMonth = _getDaysInMonth(_selectedYear, monthIndex);
    final firstDayOfWeek = _getFirstDayOfMonth(_selectedYear, monthIndex);
    final today = DateTime.now();
    final isCurrentMonth = today.year == _selectedYear && today.month == monthIndex;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        toolbarHeight: 100,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white, size: 32),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Calendar',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: _showMonthPicker,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  Text(
                    '$_selectedMonth $_selectedYear',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.white,
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1976D2),
              ),
            )
          : Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          children: [
                            _buildDayHeader('Sun'),
                            _buildDayHeader('Mon'),
                            _buildDayHeader('Tue'),
                            _buildDayHeader('Wed'),
                            _buildDayHeader('Thu'),
                            _buildDayHeader('Fri'),
                            _buildDayHeader('Sat'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      Expanded(
                        child: GridView.builder(
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            mainAxisSpacing: 6,
                            crossAxisSpacing: 6,
                            childAspectRatio: 0.95,
                          ),
                          itemCount: 42,
                          itemBuilder: (context, index) {
                            final dayNumber = index - firstDayOfWeek + 1;
                            
                            if (index < firstDayOfWeek) {
                              return const SizedBox();
                            }
                            
                            if (dayNumber > daysInMonth) {
                              return const SizedBox();
                            }
                            
                            final isSelected = dayNumber == _selectedDay;
                            final isToday = isCurrentMonth && dayNumber == today.day;
                            final hasTransaction = _datesWithTransactions.contains(dayNumber);
                            
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedDay = dayNumber;
                                });
                                
                                if (hasTransaction) {
                                  // Navigate to daily transaction page
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DailyTransactionPage(
                                        selectedDate: DateTime(_selectedYear, monthIndex, dayNumber),
                                      ),
                                    ),
                                  ).then((_) => _loadTransactionDates());
                                } else {
                                  // ✅ Navigate to no records page
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NoRecordsPage(
                                        selectedDate: _formatDate(dayNumber),
                                        selectedDateTime: DateTime(_selectedYear, monthIndex, dayNumber),
                                      ),
                                    ),
                                  ).then((_) => _loadTransactionDates());
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: hasTransaction
                                      ? const Color(0xFF66BB6A) // Dark green
                                      : isToday 
                                          ? const Color(0xFFA5D6A7) // Medium green for today
                                          : const Color(0xFFE8F5E9), // Light green
                                  borderRadius: BorderRadius.circular(8),
                                  border: isSelected
                                      ? Border.all(
                                          color: const Color(0xFF1976D2),
                                          width: 2,
                                        )
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '$dayNumber',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: hasTransaction || isToday
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF003D82),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddNotesPage(),
                ),
              ).then((_) => _loadTransactionDates());
            },
            icon: const Icon(
              Icons.add,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayHeader(String day) {
    return Expanded(
      child: Text(
        day,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}