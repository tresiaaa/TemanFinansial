import 'package:flutter/material.dart';

class MonthPickerDialog extends StatefulWidget {
  final String initialMonth;
  final int initialYear;
  final List<String> months;
  final Function(String month, int year) onConfirm;

  const MonthPickerDialog({
    super.key,
    required this.initialMonth,
    required this.initialYear,
    required this.months,
    required this.onConfirm,
  });

  @override
  State<MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<MonthPickerDialog> {
  late String tempMonth;
  late int tempYear;
  bool showYearPicker = false;

  @override
  void initState() {
    super.initState();
    tempMonth = widget.initialMonth;
    tempYear = widget.initialYear;
  }

  String _getFullMonthName(String shortMonth) {
    const monthMap = {
      'Jan': 'January',
      'Feb': 'February',
      'Mar': 'March',
      'Apr': 'April',
      'May': 'May',
      'Jun': 'June',
      'Jul': 'July',
      'Aug': 'August',
      'Sep': 'September',
      'Oct': 'October',
      'Nov': 'November',
      'Dec': 'December',
    };
    return monthMap[shortMonth] ?? shortMonth;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              '${_getFullMonthName(tempMonth)} $tempYear',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            
            // Year Selector with Dropdown
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showYearPicker = !showYearPicker;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '$tempYear',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          showYearPicker 
                              ? Icons.keyboard_arrow_up 
                              : Icons.keyboard_arrow_down,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                // Sembunyikan tombol < > saat dropdown terbuka
                if (!showYearPicker) ...[
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () {
                          setState(() {
                            tempYear = tempYear - 1;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
                          setState(() {
                            tempYear = tempYear + 1;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            
            // Year Picker List (Dropdown)
            if (showYearPicker)
              Container(
                height: 200,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.builder(
                  itemCount: 21, // 10 tahun sebelum dan sesudah
                  itemBuilder: (context, index) {
                    final year = tempYear - 10 + index;
                    final isSelected = year == tempYear;
                    
                    return InkWell(
                      onTap: () {
                        setState(() {
                          tempYear = year;
                          showYearPicker = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        color: isSelected 
                            ? const Color(0xFF64B5F6).withOpacity(0.3)
                            : Colors.transparent,
                        child: Text(
                          '$year',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: isSelected 
                                ? FontWeight.w600 
                                : FontWeight.normal,
                            color: isSelected 
                                ? const Color(0xFF1976D2)
                                : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            
            // Month Grid (Tanpa Border)
            SizedBox(
              width: 320,
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 4,
                childAspectRatio: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: widget.months.map((month) {
                  final isSelected = month == tempMonth;
                  
                  return InkWell(
                    onTap: () {
                      setState(() {
                        tempMonth = month;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? const Color(0xFF64B5F6)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        month,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: isSelected 
                              ? FontWeight.w600 
                              : FontWeight.normal,
                          color: isSelected 
                              ? Colors.white 
                              : Colors.black87,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),
            
            // Action Buttons dengan Jarak Lebih Lebar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onConfirm(tempMonth, tempYear);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}