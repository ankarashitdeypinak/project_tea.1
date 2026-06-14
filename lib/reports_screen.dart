import 'package:flutter/material.dart';

/// =========================================================================
/// 1. REPORTS SCREEN (Matching WhatsApp Image 2026-06-08 at 11.38.16 PM.jpeg)
/// =========================================================================
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBF9),
      appBar: AppBar(
        title: const Text(
          'Reports',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFBFBF9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        children: [
          _buildReportTile(
            context,
            icon: Icons.calendar_today_outlined,
            bgColor: const Color(0xFFF3E8FF),
            iconColor: Colors.purple,
            title: 'Attendance Report',
            subtitle: 'Daily, Weekly, Monthly',
          ),
          _buildReportTile(
            context,
            icon: Icons.access_time,
            bgColor: const Color(0xFFE0F2FE),
            iconColor: Colors.blue,
            title: 'Work Hours Report',
            subtitle: 'Detailed work hours and overtime',
          ),
          _buildReportTile(
            context,
            icon: Icons.assignment_outlined,
            bgColor: const Color(0xFFFEF3C7),
            iconColor: Colors.orange,
            title: 'Leaf Collection Report',
            subtitle: 'Daily, Weekly, Monthly',
          ),
          _buildReportTile(
            context,
            icon: Icons.request_quote_outlined,
            bgColor: const Color(0xFFE0E7FF),
            iconColor: Colors.indigo,
            title: 'Wage Report',
            subtitle: 'Payments and earnings',
          ),
          _buildReportTile(
            context,
            icon: Icons.opacity,
            bgColor: const Color(0xFFE0F2FE),
            iconColor: Colors.lightBlue,
            title: 'Water Usage Report',
            subtitle: 'Usage and savings',
          ),
          _buildReportTile(
            context,
            icon: Icons.leaderboard_outlined,
            bgColor: const Color(0xFFDCFCE7),
            iconColor: Colors.green,
            title: 'Productivity Report',
            subtitle: 'Overall productivity analysis',
          ),
        ],
      ),
    );
  }

  Widget _buildReportTile(
      BuildContext context, {
        required IconData icon,
        required Color bgColor,
        required Color iconColor,
        required String title,
        required String subtitle,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
        onTap: () {
          // Click korle ekhon eita specific report detail page-e niye jabe
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportDetailPage(reportTitle: title),
            ),
          );
        },
      ),
    );
  }
}

/// =========================================================================
/// 2. DYNAMIC REPORT DETAIL SCREEN (Click korle ja open hobe)
/// =========================================================================
class ReportDetailPage extends StatelessWidget {
  final String reportTitle;

  const ReportDetailPage({super.key, required this.reportTitle});

  TextAlign? get center => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(reportTitle),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bar_chart_rounded, size: 80, color: Colors.green),
              const SizedBox(height: 16),
              Text(
                '$reportTitle Details',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: center,
              ),
              const SizedBox(height: 10),
              Text(
                'Real-time data visualization and charts for $reportTitle will be integrated here.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}