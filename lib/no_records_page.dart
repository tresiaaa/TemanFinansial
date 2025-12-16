import 'package:flutter/material.dart';
import 'add_notes_page.dart';

class NoRecordsPage extends StatelessWidget {
  final String selectedDate;
  final DateTime? selectedDateTime;
  
  const NoRecordsPage({
    super.key,
    required this.selectedDate,
    this.selectedDateTime,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          selectedDate,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty State Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Document 1
                  Transform.rotate(
                    angle: -0.2,
                    child: Container(
                      width: 60,
                      height: 75,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.grey.shade400,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 30,
                            height: 3,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 30,
                            height: 3,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 20,
                            height: 3,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Document 2
                  Transform.rotate(
                    angle: 0.2,
                    child: Container(
                      width: 60,
                      height: 75,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.grey.shade400,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 30,
                            height: 3,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 30,
                            height: 3,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 20,
                            height: 3,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // "No records" Text
            const Text(
              'No records',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            
            // Subtitle hint
            Text(
              'Tap + to add a transaction',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF003D82),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IconButton(
          onPressed: () {
            // Navigate ke AddNotesPage (yang sudah ada kalkulator)
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddNotesPage(),
              ),
            ).then((result) {
              // Setelah selesai add transaksi, kembali ke CalendarPage
              if (result == true) {
                Navigator.pop(context, true);
              }
            });
          },
          icon: const Icon(
            Icons.add,
            color: Colors.white,
            size: 36,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}