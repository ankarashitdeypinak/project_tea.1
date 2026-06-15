import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  final List<dynamic> attendanceList;
  final List<Map<String, dynamic>> collectionsList;
  final double morningWater;
  final double afternoonWater;
  final double savedWater;

  const ReportsScreen({
    super.key,
    required this.attendanceList,
    required this.collectionsList,
    required this.morningWater,
    required this.afternoonWater,
    required this.savedWater,
  });

  // ১. উপস্থিত কর্মীর সংখ্যা ও হার ক্যালকুলেশন
  String _getAttendanceSummary() {
    if (attendanceList.isEmpty) return "No attendance records recorded today.";
    int presentCount = attendanceList.where((a) => a.status == 'Present').length;
    double percentage = (presentCount / attendanceList.length) * 100;
    return "Present: $presentCount / ${attendanceList.length} workers (${percentage.toStringAsFixed(1)}% Active Rate)";
  }

  // ২. মোট কাজের ঘণ্টা হিসাব (উপস্থিত কর্মীদের ৮ ঘণ্টা করে স্ট্যান্ডার্ড ধরে)
  String _getCalculatedWorkHours() {
    int presentCount = attendanceList.where((a) => a.status == 'Present').length;
    int totalHours = presentCount * 8;
    return "Total: $totalHours Productive Hours tracked today (Standard 8 Hours/Day scale).";
  }

  // ৩. সংগৃহীত চা-পাতার মোট ওজন হিসাব
  String _getTotalLeafWeight() {
    if (collectionsList.isEmpty) return "No crop collections registered today.";
    double totalWeight = 0.0;
    for (var col in collectionsList) {
      totalWeight += (col['weight'] as num).toDouble();
    }
    return "Total Harvested: ${totalWeight.toStringAsFixed(1)} kg from ${collectionsList.length} entries.";
  }

  // ৪. আনুমানিক মজুরি বা পারফরম্যান্স ইনডেক্স বিতরণ (ডেমো রেট ৫০০ টাকা/দিন ধরে ডাইনামিক)
  String _getWageDistribution() {
    int presentCount = attendanceList.where((a) => a.status == 'Present').length;
    double estimatedPayout = presentCount * 500.0; // Standard baseline daily wage matrix
    return "Estimated Daily Compensation Matrix: ৳${estimatedPayout.toStringAsFixed(0)} distributed.";
  }

  // ৫. প্রোডাক্টিভিটি ইনডেক্স বা পারফরম্যান্স অ্যানালিসিস
  String _getProductivityIndex() {
    if (collectionsList.isEmpty || attendanceList.isEmpty) return "Awaiting sufficient metrics to run optimization models.";
    double totalWeight = 0.0;
    for (var col in collectionsList) {
      totalWeight += (col['weight'] as num).toDouble();
    }
    int presentCount = attendanceList.where((a) => a.status == 'Present').length;
    if (presentCount == 0) return "Zero active labor factor to compute productivity index.";

    double avgYieldPerWorker = totalWeight / presentCount;
    return "Average Yield Index: ${avgYieldPerWorker.toStringAsFixed(1)} kg per active worker.";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBF9),
      appBar: AppBar(
        title: const Text('Centralized Dynamic Reports Hub', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2D5A27),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildCardReportTile(
              context,
              "Live Field Attendance Sheet Status Log",
              _getAttendanceSummary()
          ),
          _buildCardReportTile(
              context,
              "Calculated Work Hours Metrics Analysis",
              _getCalculatedWorkHours()
          ),
          _buildCardReportTile(
              context,
              "Crop Leaf Yield Harvest Weight Report",
              _getTotalLeafWeight()
          ),
          _buildCardReportTile(
              context,
              "Live Structured Compensation Wage Distributions",
              _getWageDistribution()
          ),
          _buildCardReportTile(
              context,
              "Irrigation Water Management Efficiency Matrix",
              "Morning Flow: ${morningWater.toStringAsFixed(1)} L | Afternoon Flow: ${afternoonWater.toStringAsFixed(1)} L | Saved Remaining: ${savedWater.toStringAsFixed(1)} L"
          ),
          _buildCardReportTile(
              context,
              "Organizational Unit Productivity Index",
              _getProductivityIndex()
          ),
        ],
      ),
    );
  }

  Widget _buildCardReportTile(BuildContext context, String title, String dataSubtitle) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10), // কার্ডগুলোর গ্যাপ বাড়ানো হয়েছে
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: () {
          // কার্ডে ক্লিক করলে যা ঘটবে (অ্যাকশন ফিক্সড)
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("$title\n$dataSubtitle"),
              backgroundColor: const Color(0xFF2D5A27),
              duration: const Duration(seconds: 3),
            ),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0), // ভেতরের সাইজ বড় করার জন্য প্যাডিং
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.analytics, color: Color(0xFF2D5A27), size: 32), // আইকন সাইজ বড় করা হয়েছে
            ),
            title: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black)
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                  dataSubtitle,
                  style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.3)
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16), // বাটন লুকে দেখানোর জন্য অ্যারো
          ),
        ),
      ),
    );
  }
}