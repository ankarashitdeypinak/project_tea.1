import 'package:flutter/material.dart';

class CollectionPage extends StatelessWidget {
  final String leafCollection;
  final bool isDarkMode;

  const CollectionPage({super.key, required this.leafCollection, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : Colors.black;
    double progressValue = (double.tryParse(leafCollection.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0) / 2000;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: DefaultTabController(
        length: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Leaf Collection", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 10),
            TabBar(
              labelColor: const Color(0xFF2D5A27),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF2D5A27),
              tabs: const [
                Tab(text: "Daily"),
                Tab(text: "History"),
                Tab(text: "Reports"),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                children: [
                  // Daily Collection Tab
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Today's Current Total: $leafCollection", style: const TextStyle(color: Colors.grey, fontSize: 16)),
                      const SizedBox(height: 15),
                      Card(
                        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Target Collection:", style: TextStyle(color: textColor, fontSize: 16)),
                                  Text("2,000 kg", style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              LinearProgressIndicator(
                                value: progressValue > 1.0 ? 1.0 : progressValue,
                                backgroundColor: Colors.grey.withOpacity(0.2),
                                color: const Color(0xFF2D5A27),
                                minHeight: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // History Tab
                  ListView(
                    children: [
                      _buildHistoryItem("Yesterday", "1,180 kg", isDarkMode, textColor),
                      _buildHistoryItem("June 8, 2026", "1,420 kg", isDarkMode, textColor),
                      _buildHistoryItem("June 7, 2026", "1,050 kg", isDarkMode, textColor),
                    ],
                  ),
                  // Reports Tab
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.bar_chart, size: 64, color: Color(0xFF2D5A27)),
                        const SizedBox(height: 10),
                        Text("Weekly & Monthly Reports", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                        const Text("Reports are ready to download.", style: TextStyle(color: Colors.grey)),
                        ElevatedButton.icon(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D5A27)),
                          icon: const Icon(Icons.download, color: Colors.white),
                          label: const Text("Download PDF", style: TextStyle(color: Colors.white)),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String date, String amount, bool isDark, Color textColor) {
    return Card(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.history_toggle_off, color: Colors.orange),
        title: Text(date, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        trailing: Text(amount, style: const TextStyle(color: Color(0xFF2D5A27), fontWeight: FontWeight.bold)),
      ),
    );
  }
}