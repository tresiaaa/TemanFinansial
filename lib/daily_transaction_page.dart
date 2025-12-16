import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/firestore_service.dart';
import 'models/transaction_model.dart';
import 'widgets/transaction_list_item.dart';
import 'category_selection_page.dart';

class DailyTransactionPage extends StatefulWidget {
  final DateTime selectedDate;

  const DailyTransactionPage({
    super.key,
    required this.selectedDate,
  });

  @override
  State<DailyTransactionPage> createState() => _DailyTransactionPageState();
}

class _DailyTransactionPageState extends State<DailyTransactionPage> {
  final FirestoreService _firestoreService = FirestoreService();
  
  double _totalExpense = 0;
  double _totalIncome = 0;
  double _balance = 0;
  bool _isLoading = true;
  int _refreshKey = 0; // ✅ Key untuk force refresh stream

  @override
  void initState() {
    super.initState();
    _loadDailyData();
  }

  // ✅ FIXED: Tambahkan didChangeDependencies untuk auto-reload
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadDailyData();
  }

  Future<void> _loadDailyData() async {
    setState(() {
      _isLoading = true;
    });

    double expense = await _firestoreService.getTotalExpenseByDate(widget.selectedDate);
    double income = await _firestoreService.getTotalIncomeByDate(widget.selectedDate);
    
    if (mounted) {
      setState(() {
        _totalExpense = expense;
        _totalIncome = income;
        _balance = income - expense;
        _isLoading = false;
        _refreshKey++; // ✅ Increment key untuk trigger rebuild stream
      });
    }
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
    final formattedDate = DateFormat('MMM dd, yyyy').format(widget.selectedDate);
    final dayOfWeek = DateFormat('EEEE').format(widget.selectedDate);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        toolbarHeight: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white, size: 32),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          formattedDate,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1976D2),
              ),
            )
          : Column(
              children: [
                // Summary Cards
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          label: 'Income',
                          amount: _totalIncome,
                          color: const Color(0xFF4CAF50),
                          icon: Icons.trending_up,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          label: 'Expense',
                          amount: _totalExpense,
                          color: const Color(0xFFEF5350),
                          icon: Icons.trending_down,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          label: 'Balance',
                          amount: _balance,
                          color: const Color(0xFF42A5F5),
                          icon: Icons.account_balance_wallet,
                        ),
                      ),
                    ],
                  ),
                ),

                // Transaction List Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        "${dayOfWeek.toUpperCase()}'S TRANSACTION",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Transaction List
                Expanded(
                  child: StreamBuilder<List<TransactionModel>>(
                    key: ValueKey(_refreshKey), // ✅ Force rebuild saat key berubah
                    stream: _firestoreService.getTransactionsByDate(widget.selectedDate),
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
                                'No transactions',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap + button to add transaction',
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

                      return ListView.builder(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 88),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = transactions[index];
                          
                          String amountStr;
                          if (transaction.type == 'expense') {
                            amountStr = '-${_formatCurrency(transaction.amount)}';
                          } else if (transaction.type == 'income') {
                            amountStr = '+${_formatCurrency(transaction.amount)}';
                          } else {
                            amountStr = _formatCurrency(transaction.amount);
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: TransactionListItem(
                              icon: transaction.icon,
                              color: transaction.color,
                              title: transaction.category,
                              amount: amountStr,
                              isExpense: transaction.type == 'expense',
                              date: DateFormat('MMM dd, yyyy').format(transaction.date),
                              transactionId: transaction.id,
                              note: transaction.note,
                              onRefresh: () {
                                // ✅ Reload data setelah edit/delete
                                _loadDailyData();
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: Container(
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
            // ✅ FIXED: Navigate dan set tanggal default, lalu reload data
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CategorySelectionPage(),
              ),
            ).then((_) {
              // ✅ Setelah kembali dari add transaction, reload data
              _loadDailyData();
            });
          },
          icon: const Icon(
            Icons.add,
            color: Colors.white,
            size: 36,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Rp ${_formatCurrency(amount)}',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}