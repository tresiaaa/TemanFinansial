import 'package:flutter/material.dart';

class FinancialSummaryWidget extends StatelessWidget {
  const FinancialSummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
    );
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
}