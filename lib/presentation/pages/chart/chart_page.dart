import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'add_transaction_page.dart';

enum ChartFilter { all, income, expense }
enum TimeFilter { daily, weekly, monthly, yearly }

class ChartsPage extends StatefulWidget {
  const ChartsPage({super.key});

  @override
  State<ChartsPage> createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  double totalIncome = 0;
  double totalExpense = 0;
  List<TransactionSummary> monthlyData = [];

  ChartFilter _selectedFilter = ChartFilter.all;
  TimeFilter _selectedTimeFilter = TimeFilter.monthly;

  @override
  Widget build(BuildContext context) {
    final filteredData = monthlyData.where((item) {
      if (_selectedFilter == ChartFilter.all) return true;
      if (_selectedFilter == ChartFilter.income) return item.isIncome;
      if (_selectedFilter == ChartFilter.expense) return !item.isIncome;
      return false;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          '${_getTimeFilterLabel(_selectedTimeFilter)} Charts',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          // TOMBOL TAMBAH TRANSAKSI (+)
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddTransactionPage(),
                ),
              );
            },
          ),
          // END TOMBOL TAMBAH
          PopupMenuButton<TimeFilter>(
            icon: const Icon(Icons.menu, color: Colors.white),
            onSelected: (TimeFilter result) {
              setState(() {
                _selectedTimeFilter = result;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<TimeFilter>>[
              _buildPopupMenuItem(TimeFilter.daily),
              _buildPopupMenuItem(TimeFilter.weekly),
              _buildPopupMenuItem(TimeFilter.monthly),
              _buildPopupMenuItem(TimeFilter.yearly),
            ],
          ),
        ],
        centerTitle: true,
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFilterButtons(),
            const SizedBox(height: 16),

            // Bar Chart Container
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: _buildBarChart(),
            ),
            const SizedBox(height: 20),

            // Daftar Ringkasan Transaksi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: filteredData.map((data) => _buildSummaryTile(data)).toList(),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }


  PopupMenuEntry<TimeFilter> _buildPopupMenuItem(TimeFilter filter) {
    final bool isSelected = filter == _selectedTimeFilter;
    return PopupMenuItem<TimeFilter>(
      value: filter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _getTimeFilterLabel(filter),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFF1565C0) : Colors.black87,
            ),
          ),
          if (isSelected)
            const Icon(Icons.check, size: 18, color: Color(0xFF1565C0)),
        ],
      ),
    );
  }

  String _getTimeFilterLabel(TimeFilter filter) {
    switch (filter) {
      case TimeFilter.daily:
        return 'Daily';
      case TimeFilter.weekly:
        return 'Weekly';
      case TimeFilter.monthly:
        return 'Monthly';
      case TimeFilter.yearly:
        return 'Yearly';
    }
  }

  Widget _buildFilterButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF1565C0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildFilterButton('All', ChartFilter.all),
          _buildFilterButton('Income', ChartFilter.income),
          _buildFilterButton('Expense', ChartFilter.expense),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String title, ChartFilter filter) {
    bool isSelected = _selectedFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFF1565C0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? const Color(0xFF1565C0) : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    double maxY = [totalIncome, totalExpense].reduce((a, b) => a > b ? a : b) * 1.2;
    if (maxY < 1000000) maxY = 1000000; // Minimal 1M jika data kosong

    // Tampilkan pesan jika data kosong
    if (totalIncome == 0 && totalExpense == 0) {
      return const Center(
        child: Text(
          'Belum ada data transaksi untuk ditampilkan.',
          style: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                String text = '';
                if (value == 0) {
                  text = 'Expense'; // Harus dinamis berdasarkan kategori
                } else if (value == 1) {
                  text = 'Income'; // Harus dinamis berdasarkan kategori
                }
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 4,
                  child: Text(text, style: const TextStyle(fontSize: 12, fontFamily: 'Poppins')),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                // Logika pembagian sumbu Y
                if (value % (maxY / 5).floorToDouble() == 0 && value != 0) {
                  // Menampilkan dalam format 'M' (Juta)
                  return Text((value / 1000000).toStringAsFixed(0) + 'M', style: const TextStyle(fontSize: 10));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade400, width: 1),
            left: BorderSide(color: Colors.grey.shade400, width: 1),
          ),
        ),
        barGroups: [
          // Group 0: Expense
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: totalExpense,
                color: Colors.red.shade300,
                width: 30,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
          ),
          // Group 1: Income
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: totalIncome,
                color: Colors.blue.shade300,
                width: 30,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTile(TransactionSummary data) {
    Color color = data.isIncome ? Colors.green.shade700 : Colors.red.shade700;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
              const SizedBox(width: 8),
              Text(
                data.isIncome ? 'Income' : 'Expense',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.folder_outlined, color: Colors.blueGrey),
                  const SizedBox(width: 10),
                  Text(
                    data.title,
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 16),
                  ),
                ],
              ),
              Text(
                // Format angka Rupiah
                'Rp ${data.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Model Transaksi Summary
class TransactionSummary {
  final String title;
  final double amount;
  final bool isIncome;
  final String category;
  final Color color;

  TransactionSummary({
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.category,
    required this.color,
  });
}