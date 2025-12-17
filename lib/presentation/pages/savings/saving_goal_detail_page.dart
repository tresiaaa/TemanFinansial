import 'package:flutter/material.dart';
import 'saving_page.dart';

// Riwayat Tabungan Kosong (Siap diisi dari Firebase)
final List<SavingGoalRecord> _records = const [];

// Class Widget Utama (Perbaikan dari error sebelumnya)
class SavingGoalDetailsPage extends StatelessWidget {
  final SavingGoal goal;

  const SavingGoalDetailsPage({
    super.key,
    required this.goal,
  });

  // Method untuk menampilkan dialog form input
  void _showAddRecordDialog(BuildContext context, SavingGoal goal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tambah Riwayat Tabungan'),
          content: _AddSavingRecordForm(goal: goal),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rincian tabungan',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [
          // TOMBOL TAMBAH RIWAYAT TABUNGAN (+)
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              _showAddRecordDialog(context, goal);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Rincian Tujuan
            _buildGoalHeader(),
            const SizedBox(height: 20),

            // Kalender
            _buildCalendarDetails(),
            const SizedBox(height: 20),

            // Riwayat Tabungan
            const Text(
              'Riwayat Tabungan',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Divider(),

            ..._records.map((record) => _buildRecordItem(record)).toList(),

            if (_records.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                      'Belum ada riwayat tabungan.',
                      style: TextStyle(fontFamily: 'Poppins', color: Colors.grey)
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            goal.name,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Target: Rp ${goal.targetAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Text(
            'Terkumpul: Rp ${goal.currentAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kalender Sederhana
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: 31,
            itemBuilder: (context, index) {
              final day = index + 1;
              final isSelected = false; // Karena data dummy sudah dihapus
              return Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF64B5F6) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$day',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            },
          ),
          const Divider(height: 30),

          _buildInfoRow('Memulai', goal.startDate),
          _buildInfoRow('Berakhir', goal.endDate),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label :',
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.black54),
          ),
          Text(
            value,
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordItem(SavingGoalRecord record) {
    String formattedAmount = record.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

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
          _buildDetailRow('Tanggal', record.date),
          _buildDetailRow('Jumlah', 'Rp $formattedAmount'),
          _buildDetailRow('Bentuk tabungan', record.type),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label :',
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.black54),
          ),
          Text(
            value,
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// Model Data SavingGoalRecord
class SavingGoalRecord {
  final String date;
  final double amount;
  final String type;

  const SavingGoalRecord({
    required this.date,
    required this.amount,
    required this.type,
  });
}

// --- FORM INPUT RIWAYAT TABUNGAN (DIPANGGIL DARI TOMBOL +) ---
class _AddSavingRecordForm extends StatefulWidget {
  final SavingGoal goal;
  const _AddSavingRecordForm({required this.goal});

  @override
  State<_AddSavingRecordForm> createState() => __AddSavingRecordFormState();
}

class __AddSavingRecordFormState extends State<_AddSavingRecordForm> {
  final _formKey = GlobalKey<FormState>();
  double _amount = 0.0;
  String _type = 'Uang tunai';
  final List<String> _types = ['Uang tunai', 'E-money (BCA)', 'E-money (BRI)', 'Transfer Bank', 'Lain-lain'];

  void _submitRecord() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // >>> LOGIC FIREBASE: Buat objek SavingGoalRecord dan update SavingGoal <<<

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tabungan Rp ${_amount.toStringAsFixed(0)} berhasil ditambahkan ke ${widget.goal.name}!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(labelText: 'Jumlah Tabungan (Rp)', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value!.isEmpty) return 'Jumlah tidak boleh kosong';
              if (double.tryParse(value) == null || double.parse(value) <= 0) return 'Masukkan jumlah yang valid';
              return null;
            },
            onSaved: (value) => _amount = double.parse(value!),
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Jenis Tabungan', border: OutlineInputBorder()),
            value: _type,
            items: _types
                .map((type) => DropdownMenuItem(
              value: type,
              child: Text(type),
            ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _type = value!;
              });
            },
            onSaved: (value) => _type = value!,
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _submitRecord,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Simpan', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}