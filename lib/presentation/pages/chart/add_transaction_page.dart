import 'package:flutter/material.dart';

class Transaction {
  final String title;
  final double amount;
  final bool isIncome;
  final String category;
  final DateTime date;

  Transaction({
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.category,
    required this.date,
  });
}

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  double _amount = 0.0;
  bool _isIncome = true;
  String _selectedCategory = 'Gaji';

  final List<String> incomeCategories = ['Gaji', 'Bonus', 'Investasi', 'Lain-lain'];
  final List<String> expenseCategories = ['Makanan', 'Transportasi', 'Tagihan', 'Hiburan', 'Lain-lain'];

  @override
  void initState() {
    super.initState();
    _selectedCategory = incomeCategories.first;
  }

  void _submitData() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // >>> LOGIC FIREBASE: Buat objek dan kirim ke database <<<
      // final newTransaction = Transaction( ... );

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_isIncome ? "Pemasukan" : "Pengeluaran"} berhasil ditambahkan!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Transaksi', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Toggle Income/Expense
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTypeButton('Pemasukan', true),
                  _buildTypeButton('Pengeluaran', false),
                ],
              ),
              const SizedBox(height: 20),

              // Input Judul
              TextFormField(
                decoration: const InputDecoration(labelText: 'Judul/Keterangan', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Judul tidak boleh kosong' : null,
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 16),

              // Input Jumlah
              TextFormField(
                decoration: const InputDecoration(labelText: 'Jumlah (Rp)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Jumlah tidak boleh kosong';
                  if (double.tryParse(value) == null || double.parse(value) <= 0) return 'Masukkan jumlah yang valid';
                  return null;
                },
                onSaved: (value) => _amount = double.parse(value!),
              ),
              const SizedBox(height: 16),

              // Dropdown Kategori
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Kategori', border: OutlineInputBorder()),
                value: _selectedCategory,
                items: (_isIncome ? incomeCategories : expenseCategories)
                    .map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                onSaved: (value) => _selectedCategory = value!,
              ),
              const SizedBox(height: 30),

              // Tombol Simpan
              ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Simpan Transaksi', style: TextStyle(fontSize: 16, fontFamily: 'Poppins')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton(String title, bool isIncome) {
    bool isSelected = _isIncome == isIncome;
    return GestureDetector(
      onTap: () {
        setState(() {
          _isIncome = isIncome;
          _selectedCategory = isIncome ? incomeCategories.first : expenseCategories.first;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1565C0) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? const Color(0xFF1565C0) : Colors.transparent),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}