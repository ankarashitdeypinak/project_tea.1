import 'package:flutter/material.dart';

class WaterManagementPage extends StatefulWidget {
  final bool isDarkMode;
  final double initialMorningWater;
  final double initialAfternoonWater;
  final double initialCapacity;
  final Function(double, double, double) onWaterSaved;

  const WaterManagementPage({
    super.key,
    required this.isDarkMode,
    required this.initialMorningWater,
    required this.initialAfternoonWater,
    required this.initialCapacity,
    required this.onWaterSaved,
  });

  @override
  State<WaterManagementPage> createState() => _WaterManagementPageState();
}

class _WaterManagementPageState extends State<WaterManagementPage> {
  late TextEditingController _capacityController;
  late TextEditingController _morningController;
  late TextEditingController _afternoonController;

  @override
  void initState() {
    super.initState();
    _capacityController = TextEditingController(text: widget.initialCapacity.toString());
    _morningController = TextEditingController(text: widget.initialMorningWater.toString());
    _afternoonController = TextEditingController(text: widget.initialAfternoonWater.toString());
  }

  void _calculateAndSave() {
    double cap = double.tryParse(_capacityController.text) ?? 0.0;
    double morn = double.tryParse(_morningController.text) ?? 0.0;
    double aft = double.tryParse(_afternoonController.text) ?? 0.0;

    widget.onWaterSaved(morn, aft, cap);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Water database parameters saved successfully!"), backgroundColor: Colors.cyan),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDarkMode ? Colors.white : Colors.black;
    final cardColor = widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    double totalUsed = (double.tryParse(_morningController.text) ?? 0.0) + (double.tryParse(_afternoonController.text) ?? 0.0);
    double availableStock = (double.tryParse(_capacityController.text) ?? 0.0) - totalUsed;

    return Scaffold(
      backgroundColor: widget.isDarkMode ? const Color(0xFF121212) : const Color(0xFFFBFBF9),
      appBar: AppBar(
        title: const Text("Water Matrix Logger"),
        backgroundColor: const Color(0xFF2D5A27),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: cardColor,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text("Current Analytics Metrics Status", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total Supply Available:", style: TextStyle(color: textColor)),
                        Text("${_capacityController.text} L", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total Discharged Usage:", style: TextStyle(color: textColor)),
                        Text("$totalUsed L", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Net Remaining Savings:", style: TextStyle(color: textColor)),
                        Text("$availableStock L", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text("Update Today's Operational Logs Data", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _capacityController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: textColor),
              decoration: const InputDecoration(labelText: "Total Storage Available Tank (Liters)", border: OutlineInputBorder()),
              onChanged: (v) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _morningController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: textColor),
              decoration: const InputDecoration(labelText: "Morning Session Discharge (Liters)", border: OutlineInputBorder()),
              onChanged: (v) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _afternoonController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: textColor),
              decoration: const InputDecoration(labelText: "Afternoon Session Discharge (Liters)", border: OutlineInputBorder()),
              onChanged: (v) => setState(() {}),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D5A27), minimumSize: const Size(double.infinity, 50)),
              onPressed: _calculateAndSave,
              child: const Text("Save Operational Updates", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}