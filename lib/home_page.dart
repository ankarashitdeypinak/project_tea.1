import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'login_page.dart';

// নতুন পেজগুলোর ইম্পোর্ট ফাইল লিংক
import 'workers_page.dart';
import 'collection_page.dart';
import 'settings_page.dart';
import 'attendance_page.dart';
import 'water_management_page.dart';

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
  bool _isDarkMode = false;

  // 📈 লাইভ আপডেট করার জন্য স্টেট ভ্যারিয়েবলস (Upgradeable Stats)
  String _attendance = "86%";
  String _totalWorkers = "128";
  String _leafCollection = "1,253 kg";
  String _waterSaved = "2,450 L";

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return "Good Morning,";
    } else if (hour >= 12 && hour < 17) {
      return "Good Afternoon,";
    } else if (hour >= 17 && hour < 20) {
      return "Good Evening,";
    } else {
      return "Good Night,";
    }
  }

  // 🔔 নোটিফিকেশন পপআপ ডায়ালগ
  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.notifications_active, color: Color(0xFF2D5A27)),
            const SizedBox(width: 10),
            Text(
              "Notifications",
              style: TextStyle(fontWeight: FontWeight.bold, color: _isDarkMode ? Colors.white : Colors.black),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNotificationItem(
              Icons.shopping_basket_outlined,
              "Collection Update",
              "Today's total leaf collection reached $_leafCollection successfully.",
              "Just now",
            ),
            const Divider(),
            _buildNotificationItem(
              Icons.description_outlined,
              "Report Generated",
              "Weekly worker attendance and performance report is ready.",
              "20 mins ago",
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: Color(0xFF2D5A27), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(IconData icon, String title, String body, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: _isDarkMode ? const Color(0xFF3A3A3A) : const Color(0xFFE8F5E9),
            child: Icon(icon, color: const Color(0xFF2D5A27), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _isDarkMode ? Colors.white : Colors.black),
                ),
                const SizedBox(height: 2),
                Text(body, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(color: _isDarkMode ? Colors.white54 : Colors.black38, fontSize: 10, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 📝 স্ট্যাটাসগুলো আপডেট করার জন্য জেনেরিক ইনপুট ডায়ালগ ফাংশন
  void _showUpdateDialog(String title, String currentValue, Function(String) onUpdate) {
    final TextEditingController controller = TextEditingController(text: currentValue.replaceAll(RegExp(r'[^0-9.]'), ''));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Update $title", style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
          decoration: InputDecoration(
            labelText: "Enter New Value",
            labelStyle: const TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: _isDarkMode ? Colors.white54 : Colors.black26)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF2D5A27))),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  onUpdate(controller.text);
                });
              }
              Navigator.pop(context);
            },
            child: const Text("Update", style: TextStyle(color: Color(0xFF2D5A27), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ☁️ Cloudinary ইমেজ আপলোড লজিক
  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (image != null) {
      setState(() {
        _isUploading = true;
      });

      try {
        final cloudinary = CloudinaryPublic(
          cloudinaryCloudName,
          cloudinaryUploadPreset,
          cache: false,
        );

        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            image.path,
            resourceType: CloudinaryResourceType.Image,
          ),
        );

        String downloadUrl = response.secureUrl;

        await _currentUser!.updatePhotoURL(downloadUrl);
        await _currentUser!.reload();

        setState(() {
          _currentUser = FirebaseAuth.instance.currentUser;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile picture updated successfully!"), backgroundColor: Color(0xFF2D5A27)),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload failed: $e"), backgroundColor: Colors.redAccent),
        );
      } finally { // ✅ 'final' পরিবর্তন করে 'finally' ফিক্স করা হয়েছে
        if (mounted) {
          setState(() {
            _isUploading = false;
          });
        }
      }
    }
  }

  Future<void> _deleteProfileImage() async {
    if (_currentUser?.photoURL == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      await _currentUser!.updatePhotoURL(null);
      await _currentUser!.reload();

      setState(() {
        _currentUser = FirebaseAuth.instance.currentUser;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile picture removed!"), backgroundColor: Colors.orange),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error removing photo: $e"), backgroundColor: Colors.redAccent),
      );
    } finally { // ✅ 'final' পরিবর্তন করে 'finally' ফিক্স করা হয়েছে
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              title: Text(
                "Profile Photo",
                style: TextStyle(fontWeight: FontWeight.bold, color: _isDarkMode ? Colors.white : Colors.black),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF2D5A27)),
              title: Text("Upload New Photo", style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black)),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage();
              },
            ),
            if (_currentUser?.photoURL != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text("Remove Current Photo", style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteProfileImage();
                },
              ),
          ],
        ),
      ),
    );
  }

  // 🚪 লগআউট ফাংশন (সেটিংস পেজের জন্য)
  Future<void> _handleLogout() async {
    final textColor = _isDarkMode ? Colors.white : Colors.black;
    final subTextColor = _isDarkMode ? Colors.white70 : Colors.black87;

    bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
        title: Text("Logout", style: TextStyle(color: textColor)),
        content: Text("Are you sure you want to logout from TeaPlus?", style: TextStyle(color: subTextColor)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Logout", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmLogout == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
        );
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _isDarkMode ? const Color(0xFF121212) : const Color(0xFFF4F7F5);

    // 🗂️ নেভিগেশন বারের ওপর ভিত্তি করে বিভিন্ন এক্সটার্নাল স্ক্রিন রিটার্ন লজিক
    Widget getBody() {
      switch (_selectedIndex) {
        case 0:
          return _buildHomeView();
        case 1:
          return WorkersPage(totalWorkers: _totalWorkers, isDarkMode: _isDarkMode);
        case 2:
          return CollectionPage(leafCollection: _leafCollection, isDarkMode: _isDarkMode);
        case 3:
          return SettingsPage(
            isDarkMode: _isDarkMode,
            onDarkModeChanged: (val) => setState(() => _isDarkMode = val),
            onProfileTap: _showImageOptions,
            onLogoutTap: _handleLogout,
          );
        default:
          return _buildHomeView();
      }
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(child: getBody()),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        backgroundColor: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        selectedItemColor: const Color(0xFF2D5A27),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Workers"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_basket), label: "Collection"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }

  // ==================== ১. হোম ভিউ স্ক্রিন ====================
  Widget _buildHomeView() {
    final String formattedDate = DateFormat('MMMM d, yyyy').format(DateTime.now());
    final cardColor = _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = _isDarkMode ? Colors.white : Colors.black;

    String displayName = "User";
    if (_currentUser?.displayName != null && _currentUser!.displayName!.isNotEmpty) {
      displayName = _currentUser!.displayName!;
    } else if (_currentUser?.email != null && _currentUser!.email!.isNotEmpty) {
      displayName = _currentUser!.email!.split('@')[0];
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Profile Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: _isUploading ? null : _showImageOptions,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: const Color(0xFF2D5A27),
                            backgroundImage: _currentUser?.photoURL != null ? NetworkImage(_currentUser!.photoURL!) : null,
                            child: _currentUser?.photoURL == null
                                ? Text(displayName.substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20))
                                : null,
                          ),
                          if (_isUploading)
                            const CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.black45,
                              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_getGreeting(), style: const TextStyle(color: Colors.grey)),
                        Text(displayName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(icon: Icon(Icons.notifications_outlined, size: 30, color: textColor), onPressed: _showNotificationsDialog),
                    IconButton(
                      icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode, size: 28, color: _isDarkMode ? Colors.amber : const Color(0xFF2D5A27)),
                      onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 25),

            // Featured Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(colors: [Color(0xFF2D5A27), Color(0xFF4A7C44)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Today's Overview", style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 5),
                  Text(formattedDate, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  const Row(mainAxisAlignment: MainAxisAlignment.end, children: [Icon(Icons.eco, color: Colors.white54, size: 40)])
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Upgradeable Grid Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.3,
              children: [
                _buildStatCard("Attendance", _attendance, Icons.people_alt, Colors.green, cardColor, textColor, () {
                  _showUpdateDialog("Attendance", _attendance, (val) => _attendance = "$val%");
                }),
                _buildStatCard("Total Workers", _totalWorkers, Icons.groups, Colors.blue, cardColor, textColor, () {
                  _showUpdateDialog("Total Workers", _totalWorkers, (val) => _totalWorkers = val);
                }),
                _buildStatCard("Leaf Collection", _leafCollection, Icons.eco_outlined, Colors.orange, cardColor, textColor, () {
                  _showUpdateDialog("Leaf Collection", _leafCollection, (val) => _leafCollection = "$val kg");
                }),
                _buildStatCard("Water Saved", _waterSaved, Icons.water_drop, Colors.cyan, cardColor, textColor, () {
                  // ক্লিক করলে ওয়াটার ম্যানেজমেন্ট স্ক্রিনে নিয়ে যাবে
                  Navigator.push(context, MaterialPageRoute(builder: (context) => WaterManagementPage(waterSaved: _waterSaved, isDarkMode: _isDarkMode)));
                }),
              ],
            ),
            const SizedBox(height: 25),

            Text("Quick Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 15),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(Icons.assignment, "Attendance", textColor, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AttendancePage(isDarkMode: _isDarkMode)));
                }),
                _buildActionButton(Icons.analytics, "Collection", textColor, () {
                  setState(() => _selectedIndex = 2); // কন্টিনিউ উইথ নেভিগেশন ট্যাব ২
                }),
                _buildActionButton(Icons.person_add, "Workers", textColor, () {
                  setState(() => _selectedIndex = 1); // কন্টিনিউ উইথ নেভিগেশন ট্যাব ১
                }),
                _buildActionButton(Icons.description, "Reports", textColor, () {
                  _showNotificationsDialog();
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color iconColor, Color cardBg, Color textCol, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: _isDarkMode ? Colors.black.withOpacity(0.24) : Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const Spacer(),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textCol)),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color textCol, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF2D5A27)),
            ),
            const SizedBox(height: 5),
            Text(label, style: TextStyle(fontSize: 12, color: textCol)),
          ],
        ),
      ),
    );
  }
}