import 'package:flutter/material.dart';

class AttendancePage extends StatefulWidget {
  final bool isDarkMode;
  const AttendancePage({super.key, required this.isDarkMode});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  Map<int, bool> attendanceStatus = {};

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDarkMode ? Colors.white : Colors.black;
    final cardColor = widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: widget.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF4F7F5),
      appBar: AppBar(
        title: const Text("Worker Attendance"),
        backgroundColor: const Color(0xFF2D5A27),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Summary Card
            Card(
              color: cardColor,
              child: ListTile(
                leading: const Icon(Icons.analytics, color: Color(0xFF2D5A27), size: 40),
                title: Text("Today's Attendance Stats", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                subtitle: const Text("Present: 86% | Date: Live", style: TextStyle(color: Colors.grey)),
              ),
            ),
            const SizedBox(height: 10),
            // Worker List Checkbox
            Expanded(
              child: ListView.builder(
                itemCount: 15,
                itemBuilder: (context, index) {
                  attendanceStatus[index] ??= true;
                  return Card(
                    color: cardColor,
                    child: CheckboxListTile(
                      title: Text("Worker #${index + 101}", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                      subtitle: const Text("Section: North Garden", style: TextStyle(color: Colors.grey)),
                      activeColor: const Color(0xFF2D5A27),
                      value: attendanceStatus[index],
                      onChanged: (val) {
                        setState(() {
                          attendanceStatus[index] = val!;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D5A27), padding: const EdgeInsets.symmetric(vertical: 14)),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Attendance Sheet Saved Successfully!"), backgroundColor: Colors.green),
                      );
                    },
                    child: const Text("Save Attendance", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.explicit_outlined, color: Colors.green, size: 36), // Excel Placeholder Icon
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Exported to Excel successfully!"), backgroundColor: Colors.blue),
                    );
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}