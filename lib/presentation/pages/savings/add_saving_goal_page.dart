import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddSavingGoalPage extends StatefulWidget {
  const AddSavingGoalPage({super.key});

  @override
  State<AddSavingGoalPage> createState() => _AddSavingGoalPageState();
}

class _AddSavingGoalPageState extends State<AddSavingGoalPage> {
  // State diinisialisasi dengan nilai kosong/default
  String _name = '';
  String _targetAmount = '0';
  String _startDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
  // Default tanggal target adalah 1 tahun dari sekarang
  String _endDate = DateFormat('dd/MM/yyyy').format(DateTime.now().add(const Duration(days: 365)));

  final _formKey = GlobalKey<FormState>();

  void _saveGoal() {
    // Memastikan semua field divalidasi dan disimpan
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Membersihkan string jumlah tujuan (Rp, titik, koma) menjadi angka double
      double target = double.tryParse(_targetAmount.replaceAll('.', '').replaceAll(',', '')) ?? 0.0;

      if (target <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jumlah target harus lebih dari Rp 0.')),
        );
        return;
      }


      /*
      Contoh data yang siap dikirim:
      {
        'name': _name,
        'target_amount': target,
        'start_date': _startDate,
        'end_date': _endDate,
      }
      */

      // Berhasil disimpan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tujuan tabungan "$_name" berhasil dibuat!')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Buat Tujuan',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Savings',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),

              // Nama Tujuan
              _buildInputField(
                'Nama Tujuan :',
                _name,
                Icons.title,
                    (value) => _name = value!, // value! aman karena divalidasi
                isDate: false,
                initialValue: _name,
              ),
              // Jumlah Tujuan
              _buildInputField(
                'Jumlah Tujuan :',
                'Rp $_targetAmount',
                Icons.attach_money,
                    (value) => _targetAmount = value!.replaceAll('Rp ', ''), // value! aman karena divalidasi
                isDate: false,
                initialValue: _targetAmount,
                isNumeric: true,
              ),
              // Tanggal Mulai
              _buildInputField(
                'Memulai :',
                _startDate,
                Icons.calendar_today,
                    (value) => setState(() => _startDate = value!), // value! aman karena divalidasi
                isDate: true,
                initialValue: _startDate,
              ),
              // Tanggal Akhir
              _buildInputField(
                'Akhir :',
                _endDate,
                Icons.event,
                    (value) => setState(() => _endDate = value!), // value! aman karena divalidasi
                isDate: true,
                initialValue: _endDate,
              ),

              const SizedBox(height: 50),

              Center(
                child: ElevatedButton(
                  onPressed: _saveGoal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'SAVE GOAL',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // DEFINISI WIDGET _buildInputField DIPERBAIKI
  Widget _buildInputField(
      String label,
      String hintText,
      IconData icon,
      // PERBAIKAN: Menerima String? (nullable) agar cocok dengan FormFieldSetter
      Function(String?) onSavedOrChanged,
      {bool isDate = false, required String initialValue, bool isNumeric = false}
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, color: Colors.black87),
            ),
          ),
          const Text('...', style: TextStyle(color: Colors.grey)),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              // Panggilan date picker hanya untuk input tanggal
              onTap: isDate ? () => _selectDate(context, onSavedOrChanged) : null,
              child: isDate
                  ? Text(
                initialValue,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600),
              )
                  : TextFormField(
                // Menggunakan initialValue di TextFormField karena kita menggunakan FormKey
                initialValue: initialValue,
                onChanged: (value) {
                  // Jika numerik, kita panggil onChanged agar state bisa update tampilan Rp
                  if (isNumeric) {
                    onSavedOrChanged(value.replaceAll('Rp ', '').replaceAll('.', ''));
                  }
                },
                // PROPERTI INI SEKARANG BERFUNGSI DENGAN BAIK
                onSaved: onSavedOrChanged,
                keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
                validator: (value) {
                  // Validasi umum untuk memastikan field tidak kosong
                  if (value == null || value.isEmpty || value.replaceAll('Rp ', '').replaceAll('.', '').isEmpty) {
                    return 'Kolom ini wajib diisi';
                  }
                  // Validasi untuk memastikan jumlah lebih dari 0
                  if (isNumeric && (double.tryParse(value.replaceAll('Rp ', '').replaceAll('.', '')) ?? 0) <= 0) {
                    return 'Harus lebih dari 0';
                  }
                  return null;
                },
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: hintText,
                  prefixText: isNumeric ? 'Rp ' : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // DEFINISI METHOD _selectDate DIPERBAIKI
  Future<void> _selectDate(BuildContext context, Function(String?) onChanged) async {
    DateTime initialDate;
    try {
      // Coba parse tanggal awal dari state. Jika gagal, gunakan tanggal hari ini.
      initialDate = DateFormat('dd/MM/yyyy').parse(_startDate);
    } catch (_) {
      initialDate = DateTime.now();
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      // Menggunakan intl untuk format yang konsisten
      final formattedDate = DateFormat('dd/MM/yyyy').format(picked);
      onChanged(formattedDate);
    }
  }
}