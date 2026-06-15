import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WorkerModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String department;
  final String position;
  final DateTime joiningDate;
  final String waterTarget;
  final String status;
  final String? imagePath;

  WorkerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.department,
    required this.position,
    required this.joiningDate,
    required this.waterTarget,
    required this.status,
    this.imagePath,
  });
}

class WorkersPage extends StatefulWidget {
  final bool isDarkMode;
  final List<WorkerModel> registeredWorkers;
  final ValueChanged<List<WorkerModel>> onWorkersUpdated;

  const WorkersPage({
    super.key,
    required this.isDarkMode,
    required this.registeredWorkers,
    required this.onWorkersUpdated,
  });

  @override
  State<WorkersPage> createState() => _WorkersPageState();
}

class _WorkersPageState extends State<WorkersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDarkMode ? Colors.white : Colors.black;

    final filteredWorkers = widget.registeredWorkers.where((worker) {
      return worker.name.toLowerCase().contains(_searchQuery) ||
          worker.id.toLowerCase().contains(_searchQuery);
    }).toList();

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
                onPressed: () async {
                  final WorkerModel? newWorker = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddWorkerScreen(isDarkMode: widget.isDarkMode),
                    ),
                  );

                  if (newWorker != null) {
                    setState(() {
                      widget.registeredWorkers.add(newWorker);
                      widget.onWorkersUpdated(widget.registeredWorkers);
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text("Total Active Workers: ${widget.registeredWorkers.length}", style: const TextStyle(color: Colors.grey, fontSize: 16)),
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
            child: filteredWorkers.isEmpty
                ? Center(
              child: Text(
                _searchQuery.isEmpty ? "No workers added yet!" : "No workers match your search.",
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
                : ListView.builder(
              itemCount: filteredWorkers.length,
              itemBuilder: (context, index) {
                final worker = filteredWorkers[index];
                return Card(
                  color: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF2D5A27),
                      backgroundImage: worker.imagePath != null ? FileImage(File(worker.imagePath!)) : null,
                      child: worker.imagePath == null ? const Icon(Icons.person, color: Colors.white) : null,
                    ),
                    title: Text(worker.name, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                    subtitle: Text("ID: ${worker.id} • ${worker.position}", style: const TextStyle(color: Colors.grey)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
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

class AddWorkerScreen extends StatefulWidget {
  final bool isDarkMode;
  const AddWorkerScreen({super.key, required this.isDarkMode});

  @override
  State<AddWorkerScreen> createState() => _AddWorkerScreenState();
}

class _AddWorkerScreenState extends State<AddWorkerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _idController = TextEditingController();
  final _targetController = TextEditingController();

  String _selectedDept = "Production";
  String _selectedPosition = "Plucker";
  String _selectedStatus = "Active";

  @override
  Widget build(BuildContext context) {
    final inputBg = widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey.shade100;
    final textThemeColor = widget.isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: widget.isDarkMode ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: const Text("Add New Worker", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2D5A27),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_nameController, "Full Name", inputBg, textThemeColor),
              const SizedBox(height: 12),
              _buildTextField(_idController, "Worker ID (e.g. WG1050)", inputBg, textThemeColor),
              const SizedBox(height: 12),
              _buildTextField(_phoneController, "Phone Number", inputBg, textThemeColor, keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              _buildTextField(_emailController, "Email Address (Optional)", inputBg, textThemeColor, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _buildTextField(_targetController, "Daily Water Target (Liters)", inputBg, textThemeColor, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedDept,
                dropdownColor: inputBg,
                style: TextStyle(color: textThemeColor),
                decoration: InputDecoration(filled: true, fillColor: inputBg, labelText: "Department"),
                items: ["Production", "North Garden", "South Garden", "Irrigation"].map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (val) => setState(() => _selectedDept = val!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedPosition,
                dropdownColor: inputBg,
                style: TextStyle(color: textThemeColor),
                decoration: InputDecoration(filled: true, fillColor: inputBg, labelText: "Position"),
                items: ["Plucker", "Water Supervisor", "Field Laborer"].map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value));
                }).toList(),
                onChanged: (val) => setState(() => _selectedPosition = val!),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D5A27),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (_nameController.text.isNotEmpty && _idController.text.isNotEmpty) {
                    final worker = WorkerModel(
                      id: _idController.text,
                      name: _nameController.text,
                      phone: _phoneController.text,
                      email: _emailController.text,
                      department: _selectedDept,
                      position: _selectedPosition,
                      joiningDate: DateTime.now(),
                      waterTarget: _targetController.text.isNotEmpty ? _targetController.text : "15",
                      status: _selectedStatus,
                    );
                    Navigator.pop(context, worker);
                  }
                },
                child: const Text("Save Worker Details", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, Color fill, Color text, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: text, fontSize: 15),
      decoration: InputDecoration(
        labelText: hint,
        filled: true,
        fillColor: fill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}