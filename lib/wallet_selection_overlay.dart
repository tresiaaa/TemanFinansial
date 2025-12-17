import 'package:flutter/material.dart';

class WalletSelectionOverlay extends StatelessWidget {
  final List<Map<String, dynamic>> wallets;
  final Function(Map<String, dynamic>) onWalletSelected;
  final String? excludeWalletId;

  const WalletSelectionOverlay({
    super.key,
    required this.wallets,
    required this.onWalletSelected,
    this.excludeWalletId,
  });

  IconData _getWalletIcon(String iconName) {
    switch (iconName) {
      case 'wallet':
        return Icons.account_balance_wallet;
      case 'gopay':
        return Icons.payment;
      case 'ovo':
        return Icons.account_balance;
      default:
        return Icons.account_balance_wallet;
    }
  }

  Color _getWalletColor(String type) {
    switch (type) {
      case 'cash':
        return const Color(0xFF4CAF50);
      case 'digital':
        return const Color(0xFF2196F3);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  @override
  Widget build(BuildContext context) {
    final filteredWallets = wallets.where((wallet) {
      return wallet['id'] != excludeWalletId;
    }).toList();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pilih Akun',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          
          // Wallet list
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: filteredWallets.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final wallet = filteredWallets[index];
                return _buildWalletItem(context, wallet);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletItem(BuildContext context, Map<String, dynamic> wallet) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onWalletSelected(wallet);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _getWalletColor(wallet['type']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getWalletIcon(wallet['icon']),
                color: _getWalletColor(wallet['type']),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            
            // Name and balance
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wallet['name'] ?? '',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatCurrency(wallet['balance'] ?? 0.0),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // Arrow icon
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}