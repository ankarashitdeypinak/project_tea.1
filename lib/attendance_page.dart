import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendanceModel {
  final String id;
  final String name;
  final String section;
  String status;
  String checkInTime;
  String checkOutTime;

  AttendanceModel({
    required this.id,
    required this.name,
    required this.section,
    this.status = 'Present',
    this.checkInTime = '7:45 AM',
    this.checkOutTime = '—',
  });
}

class AttendancePage extends StatefulWidget {
  final bool isDarkMode;
  final List<AttendanceModel> attendanceList;
  final VoidCallback onAttendanceSaved;

  const AttendancePage({
    super.key,
    required this.isDarkMode,
    required this.attendanceList,
    required this.onAttendanceSaved,
  });

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  DateTime _selectedDate = DateTime.now();

  int get totalPresent => widget.attendanceList.where((w) => w.status == 'Present').length;
  int get totalAbsent => widget.attendanceList.where((w) => w.status == 'Absent').length;
  int get totalLeave => widget.attendanceList.where((w) => w.status == 'Leave').length;

  void _manualCheckIn(int index) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        widget.attendanceList[index].checkInTime = picked.format(context);
        widget.attendanceList[index].status = 'Present';
      });
    }
  }

  void _manualCheckOut(int index) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        widget.attendanceList[index].checkOutTime = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDarkMode ? Colors.white : Colors.black;
    final cardColor = widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: widget.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9FAF7),
      appBar: AppBar(
        title: const Text("Attendance Sheet", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2D5A27),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(DateFormat('MMMM dd, yyyy').format(_selectedDate), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildStatCard("Present", totalPresent.toString(), const Color(0xFFE8F5E9), Colors.green),
                const SizedBox(width: 8),
                _buildStatCard("Absent", totalAbsent.toString(), const Color(0xFFFFEBEE), Colors.red),
                const SizedBox(width: 8),
                _buildStatCard("Leave", totalLeave.toString(), const Color(0xFFFFF3E0), Colors.orange),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: widget.attendanceList.isEmpty
                ? Center(child: Text("No workers available. Add workers first.", style: TextStyle(color: textColor)))
                : ListView.builder(
              itemCount: widget.attendanceList.length,
              itemBuilder: (context, index) {
                final item = widget.attendanceList[index];
                return Card(
                  color: cardColor,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item.name, style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 16)),
                            DropdownButton<String>(
                              value: item.status,
                              dropdownColor: cardColor,
                              style: TextStyle(color: textColor),
                              items: ["Present", "Absent", "Leave"].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                              onChanged: (val) {
                                setState(() {
                                  item.status = val!;
                                  if (val != 'Present') {
                                    item.checkInTime = "—";
                                    item.checkOutTime = "—";
                                  }
                                });
                              },
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.login, size: 16),
                              label: Text("In: ${item.checkInTime}"),
                              onPressed: item.status == 'Present' ? () => _manualCheckIn(index) : null,
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.logout, size: 16),
                              label: Text("Out: ${item.checkOutTime}"),
                              onPressed: item.status == 'Present' ? () => _manualCheckOut(index) : null,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D5A27),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: widget.onAttendanceSaved,
              child: const Text("Save Attendance Status", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String count, Color bg, Color textThemeColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(count, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textThemeColor)),
            Text(label, style: TextStyle(fontSize: 12, color: textThemeColor.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }
}