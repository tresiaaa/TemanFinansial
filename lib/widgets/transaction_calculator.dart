import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Widget untuk calculator dan input transaksi
/// Digunakan di add_notes_page.dart
class TransactionCalculator extends StatelessWidget {
  final String amount;
  final TextEditingController noteController;
  final DateTime selectedDate;
  final bool isLoading;
  final Function(String) onNumberPressed;
  final Function(String) onOperatorPressed;
  final VoidCallback onClearPressed;
  final VoidCallback onDecimalPressed;
  final Function(BuildContext) onDateSelect;
  final VoidCallback onSave;

  const TransactionCalculator({
    super.key,
    required this.amount,
    required this.noteController,
    required this.selectedDate,
    required this.isLoading,
    required this.onNumberPressed,
    required this.onOperatorPressed,
    required this.onClearPressed,
    required this.onDecimalPressed,
    required this.onDateSelect,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Amount display
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 12),
            child: Column(
              children: [
                const Text(
                  'Jumlah',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
          
          // Note input & Calculator
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                // Note field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: noteController,
                    decoration: InputDecoration(
                      hintText: 'Note: Enter a note...',
                      hintStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.grey[700],
                          size: 24,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Camera feature coming soon'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Calculator grid
                isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF0277BD),
                        ),
                      )
                    : GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 4,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1.5,
                        children: [
                          _buildCalcButton('7', () => onNumberPressed('7')),
                          _buildCalcButton('8', () => onNumberPressed('8')),
                          _buildCalcButton('9', () => onNumberPressed('9')),
                          _buildCalcButton(
                            DateFormat('MMM d\nyyyy').format(selectedDate),
                            () => onDateSelect(context),
                            isDate: true,
                          ),
                          _buildCalcButton('4', () => onNumberPressed('4')),
                          _buildCalcButton('5', () => onNumberPressed('5')),
                          _buildCalcButton('6', () => onNumberPressed('6')),
                          _buildCalcButton('+', () => onOperatorPressed('+')),
                          _buildCalcButton('1', () => onNumberPressed('1')),
                          _buildCalcButton('2', () => onNumberPressed('2')),
                          _buildCalcButton('3', () => onNumberPressed('3')),
                          _buildCalcButton('-', () => onOperatorPressed('-')),
                          _buildCalcButton('.', onDecimalPressed),
                          _buildCalcButton('0', () => onNumberPressed('0')),
                          _buildCalcButton('⌫', onClearPressed, isDelete: true),
                          _buildCalcButton('✓', onSave, isCheck: true),
                        ],
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalcButton(
    String label,
    VoidCallback onPressed, {
    bool isDate = false,
    bool isCheck = false,
    bool isDelete = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0277BD),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: isDelete
              ? const Icon(
                  Icons.backspace_outlined,
                  color: Colors.white,
                  size: 20,
                )
              : Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: isDate ? 10 : (isCheck ? 24 : 18),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: isDate ? 1.2 : 1.0,
                  ),
                ),
        ),
      ),
    );
  }
}