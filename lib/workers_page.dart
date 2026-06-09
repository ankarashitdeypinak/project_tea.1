import 'package:flutter/material.dart';

class WorkersPage extends StatefulWidget {
  final String totalWorkers;
  final bool isDarkMode;

  const WorkersPage({super.key, required this.totalWorkers, required this.isDarkMode});

  @override
  State<WorkersPage> createState() => _WorkersPageState();
}

class _WorkersPageState extends State<WorkersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  void _showAddWorkerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
        title: Text("Add New Worker", style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black),
              decoration: const InputDecoration(labelText: "Worker Name", labelStyle: TextStyle(color: Colors.grey)),
            ),
            TextField(
              style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black),
              decoration: const InputDecoration(labelText: "Section (e.g., North Garden)", labelStyle: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Add", style: TextStyle(color: Color(0xFF2D5A27), fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDarkMode ? Colors.white : Colors.black;
    int count = int.tryParse(widget.totalWorkers) ?? 5;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Workers Directory", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
              IconButton(
                icon: const Icon(Icons.person_add, color: Color(0xFF2D5A27), size: 28),
                onPressed: _showAddWorkerDialog,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text("Total Active Workers: ${widget.totalWorkers}", style: const TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 15),
          TextField(
            controller: _searchController,
            style: TextStyle(color: textColor),
            onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            decoration: InputDecoration(
              hintText: "Search workers...",
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const Divider(height: 30),
          Expanded(
            child: ListView.builder(
              itemCount: count,
              itemBuilder: (context, index) {
                String workerName = "Worker #${index + 101}";
                if (_searchQuery.isNotEmpty && !workerName.toLowerCase().contains(_searchQuery)) {
                  return const SizedBox.shrink();
                }
                return Card(
                  color: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: const CircleAvatar(backgroundColor: Color(0xFF2D5A27), child: Icon(Icons.person, color: Colors.white)),
                    title: Text(workerName, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                    subtitle: const Text("Section: North Garden", style: TextStyle(color: Colors.grey)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                        builder: (context) => Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(workerName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                              const SizedBox(height: 10),
                              Text("ID: WP${index + 1001}", style: const TextStyle(color: Colors.grey)),
                              Text("Section: North Garden", style: const TextStyle(color: Colors.grey)),
                              Text("Status: Active", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}