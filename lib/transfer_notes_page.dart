import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/account_service.dart';

class TransferNotesPage extends StatefulWidget {
  final Map<String, dynamic> sourceAccount;
  final Map<String, dynamic> destinationAccount;

  const TransferNotesPage({
    super.key,
    required this.sourceAccount,
    required this.destinationAccount,
  });

  @override
  State<TransferNotesPage> createState() => _TransferNotesPageState();
}

class _TransferNotesPageState extends State<TransferNotesPage> {
  final TextEditingController _noteController = TextEditingController();
  final AccountService _accountService = AccountService();
  double _amount = 0;
  String _displayAmount = '0';

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _onNumberTap(String value) {
    setState(() {
      if (value == '.' && _displayAmount.contains('.')) return;
      
      if (_displayAmount == '0' && value != '.') {
        _displayAmount = value;
      } else {
        _displayAmount += value;
      }
      _amount = double.tryParse(_displayAmount) ?? 0;
    });
  }

  void _onBackspace() {
    setState(() {
      if (_displayAmount.length > 1) {
        _displayAmount = _displayAmount.substring(0, _displayAmount.length - 1);
      } else {
        _displayAmount = '0';
      }
      _amount = double.tryParse(_displayAmount) ?? 0;
    });
  }

  void _onClear() {
    setState(() {
      _displayAmount = '0';
      _amount = 0;
    });
  }

  void _onToday() {
    // Set today's date - you can customize this behavior
    setState(() {});
  }

  Future<void> _saveTransfer() async {
    if (_amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan jumlah yang valid'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not authenticated. Please login first.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF017282)),
          ),
        ),
      );

      final transferData = {
        'userId': user.uid,
        'type': 'transfer',
        'sourceAccount': widget.sourceAccount['name'],
        'sourceAccountId': widget.sourceAccount['id'],
        'destinationAccount': widget.destinationAccount['name'],
        'destinationAccountId': widget.destinationAccount['id'],
        'amount': _amount,
        'note': _noteController.text.trim(),
        'date': Timestamp.now(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      print('Saving transfer data: $transferData'); // Debug log

      // Save to nested path: users/{userId}/transactions
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .add(transferData);

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Transfer berhasil: Rp ${_amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );

        // Navigate back to home
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
          (route) => false,
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString()}',
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _buildTransferCard(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _buildBottomSection(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 80,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF017282), Color(0xFF001645)],
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
    );
  }

  Widget _buildTransferCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Source Account
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: widget.sourceAccount['color'],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    widget.sourceAccount['icon'],
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.sourceAccount['name'],
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // Arrow Icon
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(
              Icons.swap_horiz,
              size: 32,
              color: Color(0xFF017282),
            ),
          ),
          // Destination Account
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: widget.destinationAccount['color'],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    widget.destinationAccount['icon'],
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.destinationAccount['name'],
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          // Amount Display
          const Text(
            'Jumlah',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _amount.toStringAsFixed(0).replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (Match m) => '${m[1]},'),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          // Note Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  hintText: 'Note: Enter a note...',
                  hintStyle: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.grey[400],
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  suffixIcon: const Icon(
                    Icons.camera_alt_outlined,
                    color: Color(0xFF666666),
                  ),
                ),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Calculator Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildCalcButton('7'),
                    const SizedBox(width: 8),
                    _buildCalcButton('8'),
                    const SizedBox(width: 8),
                    _buildCalcButton('9'),
                    const SizedBox(width: 8),
                    _buildCalcButton('Today', isSpecial: true, icon: Icons.calendar_today),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildCalcButton('4'),
                    const SizedBox(width: 8),
                    _buildCalcButton('5'),
                    const SizedBox(width: 8),
                    _buildCalcButton('6'),
                    const SizedBox(width: 8),
                    _buildCalcButton('+', isSpecial: true),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildCalcButton('1'),
                    const SizedBox(width: 8),
                    _buildCalcButton('2'),
                    const SizedBox(width: 8),
                    _buildCalcButton('3'),
                    const SizedBox(width: 8),
                    _buildCalcButton('-', isSpecial: true),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildCalcButton('.'),
                    const SizedBox(width: 8),
                    _buildCalcButton('0'),
                    const SizedBox(width: 8),
                    _buildCalcButton('⌫', isSpecial: true),
                    const SizedBox(width: 8),
                    _buildCalcButton('✓', isSpecial: true, isCheck: true),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCalcButton(String text, {bool isSpecial = false, bool isCheck = false, IconData? icon}) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (isCheck) {
            _saveTransfer();
          } else if (text == '⌫') {
            _onBackspace();
          } else if (text == 'Today') {
            _onToday();
          } else if (text == '+' || text == '-') {
            // Handle operations if needed
          } else {
            _onNumberTap(text);
          }
        },
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: isCheck ? const Color(0xFF017282) : const Color(0xFF0277BD),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: icon != null
              ? Icon(icon, color: Colors.white, size: 20)
              : Text(
                  text,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}