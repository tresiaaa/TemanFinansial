import 'package:flutter/material.dart';
import 'add_saving_goal_page.dart';
import 'saving_goal_detail_page.dart';

class SavingGoal {
  final String name;
  final double targetAmount;
  final double currentAmount;
  final String startDate;
  final String endDate;

  SavingGoal({
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.startDate,
    required this.endDate,
  });
}

class SavingPage extends StatefulWidget {
  const SavingPage({super.key});

  @override
  State<SavingPage> createState() => _SavingPageState();
}

class _SavingPageState extends State<SavingPage> {
  // Data Tujuan Tabungan Kosong (Siap diisi dari Firebase)
  final List<SavingGoal> _goals = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Tujuan Tabungan',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1565C0),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              // Panggil AddSavingGoalPage
              Navigator.push(
                context,
                MaterialPageRoute(
                  // Asumsi: AddSavingGoalPage adalah widget yang ada
                  builder: (context) => const AddSavingGoalPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: _goals.isEmpty
          ? const Center(
        child: Text(
          'Belum ada tujuan tabungan.',
          style: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _goals.length,
        itemBuilder: (context, index) {
          final goal = _goals[index];
          return _buildGoalCard(goal);
        },
      ),
    );
  }

  Widget _buildGoalCard(SavingGoal goal) {
    double progress = goal.currentAmount / goal.targetAmount;
    if (progress > 1.0) progress = 1.0;

    return GestureDetector(
      onTap: () {
        // Panggil SavingGoalDetailsPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SavingGoalDetailsPage(goal: goal),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                goal.name,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'Rp ${goal.targetAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),

              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade300,
                color: const Color(0xFF1565C0),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Terkumpul: Rp ${goal.currentAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: progress >= 1.0 ? Colors.green : Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}