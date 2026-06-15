import 'package:flutter/material.dart';

class CollectionPage extends StatefulWidget {
  final List<Map<String, dynamic>> collectionsList;
  final bool isDarkMode;
  final VoidCallback onCollectionUpdated;

  const CollectionPage({
    super.key,
    required this.collectionsList,
    required this.isDarkMode,
    required this.onCollectionUpdated,
  });

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  double targetAvgPerWorker = 15.0; // User adjustable limit variable

  double get totalKg {
    double sum = 0.0;
    for (var c in widget.collectionsList) {
      sum += (c['weight'] as num).toDouble();
    }
    return sum;
  }

  int get goodQualityCount => widget.collectionsList.where((c) => c['quality'] == 'Good').length;
  int get standardQualityCount => widget.collectionsList.where((c) => c['quality'] == 'Standard').length;

  void _showUpdateWeightDialog(int index) {
    final weightController = TextEditingController(text: widget.collectionsList[index]['weight'].toString());
    String selectedQuality = widget.collectionsList[index]['quality'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
        title: const Text("Update Worker Collection"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Collected Weight (kg)"),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedQuality,
              dropdownColor: widget.isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
              items: ["Good", "Standard", "Low"].map((q) => DropdownMenuItem(value: q, child: Text(q))).toList(),
              onChanged: (val) => selectedQuality = val!,
              decoration: const InputDecoration(labelText: "Quality Grade"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                widget.collectionsList[index]['weight'] = double.tryParse(weightController.text) ?? 0.0;
                widget.collectionsList[index]['quality'] = selectedQuality;
                widget.collectionsList[index]['time'] = "Just Now";
                widget.onCollectionUpdated();
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.isDarkMode ? const Color(0xFF121212) : const Color(0xFFFBFBF9);
    final cardColor = widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = widget.isDarkMode ? Colors.white : Colors.black;

    double dynamicAvg = widget.collectionsList.isEmpty ? 0.0 : totalKg / widget.collectionsList.length;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text("Collection Summary", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dynamic Cards Layout Counters Header
            Row(
              children: [
                Expanded(child: _buildInfoCard("Total Weight", "${totalKg.toStringAsFixed(1)} kg", cardColor, textColor)),
                const SizedBox(width: 8),
                Expanded(child: _buildInfoCard("Workers Active", widget.collectionsList.length.toString(), cardColor, textColor)),
                const SizedBox(width: 8),
                Expanded(child: _buildInfoCard("Calculated Avg", "${dynamicAvg.toStringAsFixed(1)} kg", cardColor, textColor)),
              ],
            ),
            const SizedBox(height: 15),

            // Dynamic Target Adjustment Slider Layout Bar
            Card(
              color: cardColor,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Text("Target Avg: ${targetAvgPerWorker.toStringAsFixed(0)} kg", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Slider(
                        value: targetAvgPerWorker,
                        min: 5,
                        max: 40,
                        divisions: 7,
                        activeColor: const Color(0xFF2D5A27),
                        onChanged: (val) => setState(() => targetAvgPerWorker = val),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Quality Pie Graph Breakdown Indicator Block Box
            Text("Quality Wise Distribution Counts", style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Chip(label: Text("Good: $goodQualityCount"), backgroundColor: Colors.green.shade100),
                Chip(label: Text("Standard: $standardQualityCount"), backgroundColor: Colors.orange.shade100),
              ],
            ),
            const SizedBox(height: 20),

            Text("Recent Worker Logs", style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            widget.collectionsList.isEmpty
                ? const Center(child: Text("No data found. Register worker details."))
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.collectionsList.length,
              itemBuilder: (context, index) {
                final data = widget.collectionsList[index];
                return ListTile(
                  title: Text(data['name'], style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                  subtitle: Text("Grade: ${data['quality']} • ${data['time']}", style: const TextStyle(color: Colors.grey)),
                  trailing: Text("${data['weight']} kg", style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15)),
                  onTap: () => _showUpdateWeightDialog(index),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String val, Color bg, Color txt) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          const SizedBox(height: 4),
          Text(val, style: TextStyle(color: txt, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}