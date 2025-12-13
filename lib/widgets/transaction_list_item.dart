import 'package:flutter/material.dart';
import '/transaction_detail_page.dart';

class TransactionListItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String amount;
  final bool isExpense;
  final bool isTransfer;
  final String? date;

  const TransactionListItem({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.amount,
    required this.isExpense,
    this.isTransfer = false,
    this.date,
  });

  @override
  Widget build(BuildContext context) {
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

class DateHeader extends StatelessWidget {
  final String date;

  const DateHeader({
    super.key,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
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
}