import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:intl/intl.dart';

import 'workers_page.dart';
import 'collection_page.dart';
import 'settings_page.dart';
import 'attendance_page.dart';
import 'water_management_page.dart';
import 'reports_screen.dart';

const String cloudinaryCloudName = 'dcmsvxrww';
const String cloudinaryUploadPreset = 'profile_preset';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? _currentUser = FirebaseAuth.instance.currentUser;
  int _selectedIndex = 0;
  bool _isUploading = false;
  String? _uploadedImageUrl;
  bool _isDarkMode = false; // গ্লোবাল ডার্ক মোড স্টেট

  // নোটিফিকেশন কাউন্টার ট্র্যাকিং (রিয়েল-টাইম চেঞ্জের জন্য ডেমো ডাটা)
  int _notificationCount = 3;

  // Centralized App State Management (Dynamic Data)
  final List<WorkerModel> _globalWorkers = [];
  final List<AttendanceModel> _globalAttendance = [];
  final List<Map<String, dynamic>> _globalCollections = [];

  // Water Records Tracking States
  double totalWaterCapacity = 5000.0; // Dynamic available water capacity in liters
  double morningWaterGiven = 0.0;
  double afternoonWaterGiven = 0.0;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeDefaultData();
  }

  void _initializeDefaultData() {
    _globalWorkers.clear();
    _globalAttendance.clear();
    _globalCollections.clear();
  }

  // Cloudinary Upload Implementation
  Future<void> _uploadProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() {
        _isUploading = true;
      });

      final cloudinary = CloudinaryPublic(cloudinaryCloudName, cloudinaryUploadPreset, cache: false);

      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(image.path, resourceType: CloudinaryResourceType.Image),
      );

      setState(() {
        _uploadedImageUrl = response.secureUrl;
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Image uploaded to Cloudinary successfully!"), backgroundColor: Colors.green),
      );
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e"), backgroundColor: Colors.red),
      );
    }
  }

  // Cloudinary Remove Implementation
  void _deleteProfileImage() {
    setState(() {
      _uploadedImageUrl = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile Image link detached successfully."), backgroundColor: Colors.orange),
    );
  }

  // প্রোফাইল অপশন দেখার জন্য বটম শীট মেনু
  void _showProfileOptions(BuildContext context) {
    final sheetBgColor = _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final tileTextColor = _isDarkMode ? Colors.white : Colors.black87;

    showModalBottomSheet(
      context: context,
      backgroundColor: sheetBgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                child: Text(
                  "Profile Photo Actions",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _isDarkMode ? Colors.white60 : Colors.black54,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: Color(0xFF2D5A27)),
                title: Text('Upload New Image', style: TextStyle(color: tileTextColor, fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(context);
                  _uploadProfileImage();
                },
              ),
              if (_uploadedImageUrl != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  title: const Text('Remove Image', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500)),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteProfileImage();
                  },
                ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  // Live Metrics Calculations for Cards
  String get _attendancePercentage {
    if (_globalAttendance.isEmpty) return "0%";
    int presentCount = _globalAttendance.where((a) => a.status == 'Present').length;
    double percentage = (presentCount / _globalAttendance.length) * 100;
    return "${percentage.toStringAsFixed(1)}%";
  }

  String get _totalCollectionWeight {
    double total = 0;
    for (var col in _globalCollections) {
      total += (col['weight'] as num).toDouble();
    }
    return "${total.toStringAsFixed(1)} kg";
  }

  String get _waterSavedVolume {
    double used = morningWaterGiven + afternoonWaterGiven;
    double saved = totalWaterCapacity - used;
    if (saved < 0) saved = 0;
    return "${saved.toStringAsFixed(1)} L";
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return "Good Morning,";
    if (hour >= 12 && hour < 17) return "Good Afternoon,";
    if (hour >= 17 && hour < 20) return "Good Evening,";
    return "Good Night,";
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _isDarkMode ? const Color(0xFF121212) : const Color(0xFFFBFBF9);
    final textColor = _isDarkMode ? Colors.white : Colors.black;

    final List<Widget> _screens = [
      _buildHomeDashboard(backgroundColor, textColor),
      WorkersPage(
        isDarkMode: _isDarkMode,
        registeredWorkers: _globalWorkers,
        onWorkersUpdated: (updatedList) {
          setState(() {
            for (var worker in updatedList) {
              bool alreadyInAttendance = _globalAttendance.any((a) => a.id == worker.id);
              if (!alreadyInAttendance) {
                _globalAttendance.add(AttendanceModel(
                  id: worker.id,
                  name: worker.name,
                  section: worker.department,
                  status: 'Present',
                  checkInTime: '7:45 AM',
                  checkOutTime: '—',
                ));
              }

              bool alreadyInCollection = _globalCollections.any((c) => c['id'] == worker.id);
              if (!alreadyInCollection) {
                _globalCollections.add({
                  'id': worker.id,
                  'name': worker.name,
                  'weight': 0.0,
                  'quality': 'Good',
                  'time': '—',
                });
              }
            }
          });
        },
      ),
      AttendancePage(
        isDarkMode: _isDarkMode,
        attendanceList: _globalAttendance,
        onAttendanceSaved: () {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Attendance sheet synced to dashboard!"), backgroundColor: Colors.green),
          );
        },
      ),
      CollectionPage(
        isDarkMode: _isDarkMode,
        collectionsList: _globalCollections,
        onCollectionUpdated: () {
          setState(() {});
        },
      ),
      SettingsPage(
        isDarkMode: _isDarkMode,
        onDarkModeChanged: (val) => setState(() => _isDarkMode = val),
        onProfileTap: () {},
        onLogoutTap: () => Navigator.pop(context), globalWorkers: [], globalAttendance: [], totalWaterCapacity:0.0, morningWaterGiven: 0.0, afternoonWaterGiven: 0.0,
      ),
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(child: _screens[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        selectedItemColor: const Color(0xFF2D5A27),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: "Workers"),
          BottomNavigationBarItem(icon: Icon(Icons.how_to_reg_outlined), label: "Attendance"),
          BottomNavigationBarItem(icon: Icon(Icons.eco_outlined), label: "Collection"),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: "Settings"),
        ],
      ),
    );
  }

  Widget _buildHomeDashboard(Color bgColor, Color textColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // টপ হেডার লেআউট
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _showProfileOptions(context),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFF2D5A27),
                      backgroundImage: _uploadedImageUrl != null ? NetworkImage(_uploadedImageUrl!) : null,
                      child: _isUploading
                          ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                          : _uploadedImageUrl == null
                          ? Text((_currentUser?.displayName ?? "M")[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_getGreeting(), style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      Text(
                        _currentUser?.displayName ?? "Manager Node",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                      ),
                    ],
                  ),
                ],
              ),

              Row(
                children: [
                  Stack(
                    children: [
                      IconButton(
                        icon: Icon(Icons.notifications_none_outlined, color: textColor, size: 26),
                        onPressed: () {
                          setState(() {
                            _notificationCount = 0;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("No new system alerts.")),
                          );
                        },
                      ),
                      if (_notificationCount > 0)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                            child: Text(
                              '$_notificationCount',
                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(
                      _isDarkMode ? Icons.wb_sunny_outlined : Icons.nightlight_round_outlined,
                      color: textColor,
                      size: 24,
                    ),
                    onPressed: () {
                      setState(() {
                        _isDarkMode = !_isDarkMode;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),

          // রিয়েল-টাইম অ্যানালিটিক্স গ্রিড কার্ড
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.4,
            children: [
              _buildStatCard(Icons.people, _globalWorkers.length.toString(), "Active Workers", const Color(0xFFE3F2FD), Colors.blue, textColor),
              _buildStatCard(Icons.done_all, _attendancePercentage, "Attendance Rate", const Color(0xFFE8F5E9), Colors.green, textColor),
              _buildStatCard(Icons.eco, _totalCollectionWeight, "Total Leaf Collected", const Color(0xFFFFF8E1), Colors.orange, textColor),
              _buildStatCard(Icons.opacity, _waterSavedVolume, "Water Resources Saved", const Color(0xFFE0F7FA), Colors.cyan, textColor),
            ],
          ),
          const SizedBox(height: 25),

          Text("Quick Actions Management", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 16),

          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 18,
            childAspectRatio: 0.95,
            children: [
              _buildActionButton(Icons.assessment_outlined, "Reports Hub", textColor, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReportsScreen(
                      attendanceList: _globalAttendance,
                      collectionsList: _globalCollections,
                      morningWater: morningWaterGiven,
                      afternoonWater: afternoonWaterGiven,
                      savedWater: totalWaterCapacity - (morningWaterGiven + afternoonWaterGiven),
                    ),
                  ),
                );
              }),
              _buildActionButton(Icons.water_drop_outlined, "Water Matrix", textColor, () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WaterManagementPage(
                      isDarkMode: _isDarkMode,
                      initialMorningWater: morningWaterGiven,
                      initialAfternoonWater: afternoonWaterGiven,
                      initialCapacity: totalWaterCapacity,
                      onWaterSaved: (morning, afternoon, capacity) {
                        setState(() {
                          morningWaterGiven = morning;
                          afternoonWaterGiven = afternoon;
                          totalWaterCapacity = capacity;
                        });
                      },
                    ),
                  ),
                );
              }),
              _buildActionButton(Icons.people_outline, "Workers", textColor, () {
                setState(() => _selectedIndex = 1);
              }),
              _buildActionButton(Icons.how_to_reg_outlined, "Attendance", textColor, () {
                setState(() => _selectedIndex = 2);
              }),
              _buildActionButton(Icons.eco_outlined, "Collection", textColor, () {
                setState(() => _selectedIndex = 3);
              }),
              _buildActionButton(Icons.settings_outlined, "Settings", textColor, () {
                setState(() => _selectedIndex = 4);
              }),
            ],
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String title, Color bg, Color iconColor, Color textCol) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _isDarkMode ? const Color(0xFF1E1E1E) : bg.withOpacity(0.4),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textCol)),
          Text(title, style: TextStyle(color: _isDarkMode ? Colors.white60 : Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color textCol, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
              border: _isDarkMode ? Border.all(color: Colors.white12) : null,
            ),
            child: Icon(icon, color: const Color(0xFF2D5A27), size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: textCol),
          ),
        ],
      ),
    );
  }
}