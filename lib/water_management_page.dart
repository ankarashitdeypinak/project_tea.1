import 'package:flutter/material.dart';

class WaterManagementPage extends StatelessWidget {
  final String waterSaved;
  final bool isDarkMode;

  const WaterManagementPage({super.key, required this.waterSaved, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF4F7F5),
      appBar: AppBar(
        title: const Text("Water Management"),
        backgroundColor: const Color(0xFF2D5A27),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: cardColor,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    const Icon(Icons.water_drop, color: Colors.cyan, size: 50),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Water Saved Today", style: const TextStyle(color: Colors.grey, fontSize: 14)),
                        Text(waterSaved, style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text("Statistics & Usage", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 10),
            _buildWaterStatTile("Daily Water Usage", "4,500 Liters", cardColor, textColor),
            _buildWaterStatTile("Monthly Savings", "75,000 Liters", cardColor, textColor),
            _buildWaterStatTile("Usage Report Status", "Normal (Optimized)", cardColor, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterStatTile(String label, String value, Color bg, Color valColor) {
    return Card(
      color: bg,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(label, style: const TextStyle(color: Colors.grey)),
        trailing: Text(value, style: TextStyle(color: valColor, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}