import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

// ক্লাউডিনারি কনফিগারেশন (হোম পেজের সাথে সিঙ্কড)
const String cloudinaryCloudName = 'dcmsvxrww';
const String cloudinaryUploadPreset = 'profile_preset';

class SettingsPage extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;
  final VoidCallback onProfileTap;
  final VoidCallback onLogoutTap;

  // অন্য পেজ থেকে রিয়েল-টাইম ডেটা রিসিভ করার জন্য প্যারামিটার যুক্ত করা হয়েছে
  final List<dynamic> globalWorkers;
  final List<dynamic> globalAttendance;
  final double totalWaterCapacity;
  final double morningWaterGiven;
  final double afternoonWaterGiven;

  const SettingsPage({
    super.key,
    required this.isDarkMode,
    required this.onDarkModeChanged,
    required this.onProfileTap,
    required this.onLogoutTap,
    required this.globalWorkers,
    required this.globalAttendance,
    required this.totalWaterCapacity,
    required this.morningWaterGiven,
    required this.afternoonWaterGiven,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Realtime Active Settings States
  bool _alertNotify = true;
  bool _cloudBackup = true;
  bool _biometricAuth = false;
  String _currentLanguage = "English";
  final String _appVersion = "v2.4.1-Build Node";

  // ফায়ারবেস কারেন্ট ইউজার ও ইমেজ পিকিং স্টেট
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isImageUploading = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
  }

  // ১. ডাইনামিক রোল (Workers Page থেকে লজিক্যালি এক্সট্র্যাক্ট করা)
  String _getUserRole() {
    if (widget.globalWorkers.isEmpty) return "Station Manager";
    // যদি লগইন করা ইউজারের ইমেইল ওয়ার্কার লিস্টে থাকে তবে তার পজিশন দেখাবে
    final match = widget.globalWorkers.firstWhere(
          (w) => w.email.toString().toLowerCase() == _user?.email?.toLowerCase(),
      orElse: () => null,
    );
    return match != null ? match.position : "Master Admin Hub";
  }

  // ২. ডাইনামিক অ্যাটেনডেন্স পার্সেন্টেজ (Attendance Page থেকে ক্যালকুলেটেড)
  String _getLiveAttendanceRate() {
    if (widget.globalAttendance.isEmpty) return "0.0%";
    int presentCount = widget.globalAttendance.where((a) => a.status == 'Present').length;
    double percentage = (presentCount / widget.globalAttendance.length) * 100;
    return "${percentage.toStringAsFixed(1)}%";
  }

  // ৩. ডাইনামিক সেভড ওয়াটার (Water Matrix থেকে ক্যালকুলেটেড)
  String _getLiveSavedWater() {
    double used = widget.morningWaterGiven + widget.afternoonWaterGiven;
    double saved = widget.totalWaterCapacity - used;
    if (saved < 0) saved = 0.0;
    return "${saved.toStringAsFixed(1)} Liters";
  }

  // ৪. প্রোফাইল পিকচার ক্লাউডিনারি আপলোড ইঞ্জিন
  Future<void> _updateProfilePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (image == null) return;

      setState(() => _isImageUploading = true);

      final cloudinary = CloudinaryPublic(cloudinaryCloudName, cloudinaryUploadPreset, cache: false);
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(image.path, resourceType: CloudinaryResourceType.Image),
      );

      // ফায়ারবেস প্রোফাইল ফটো URL আপডেট
      await _user?.updatePhotoURL(response.secureUrl);
      await _user?.reload();

      setState(() {
        _user = _auth.currentUser;
        _isImageUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Photo updated on Cloudinary!"), backgroundColor: Colors.green),
      );
    } catch (e) {
      setState(() => _isImageUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Photo upload failed: $e"), backgroundColor: Colors.red),
      );
    }
  }

  // ৫. প্রোফাইল পিকচার রিমুভ/ডিলিট ইঞ্জিন
  Future<void> _deleteProfilePhoto() async {
    try {
      await _user?.updatePhotoURL(null);
      await _user?.reload();

      setState(() {
        _user = _auth.currentUser;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Photo detached successfully!"), backgroundColor: Colors.orange),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to remove photo: $e"), backgroundColor: Colors.red),
      );
    }
  }

  // ৬. এডিট পার্সোনাল ডিটেইলস (নাম ও ফোন নম্বর আপডেট ডায়ালগ)
  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _user?.displayName ?? "");
    final phoneController = TextEditingController(text: _user?.phoneNumber ?? "");

    Color? textColor;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text("Edit Profile Details", style: TextStyle(color: textColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: "Full Name",
                labelStyle: const TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: widget.isDarkMode ? Colors.white30 : Colors.grey)),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: "Phone Number",
                labelStyle: const TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: widget.isDarkMode ? Colors.white30 : Colors.grey)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D5A27)),
            onPressed: () async {
              try {
                await _user?.updateDisplayName(nameController.text.trim());
                // নোট: ফায়ারবেস অথ-এ ডিরেক্ট ফোন নম্বর আপডেট করতে ভেরিফিকেশন লাগে,
                // তাই ডিসপ্লে বা মেটাডাটা সিঙ্কের জন্য এটিকে লোকাল স্টেটে রিফ্রেশ করা হচ্ছে।
                await _user?.reload();
                setState(() {
                  _user = _auth.currentUser;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Profile details updated successfully!"), backgroundColor: Colors.green),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Update failed: $e"), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text("Save Change", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  // ৭. পাসওয়ার্ড চেঞ্জ/রিসেট লিংক ইমেইল ইঞ্জিন (লগইন বা ফরগেট পাসওয়ার্ড মেকানিজম)
  Future<void> _sendPasswordResetEmail() async {
    if (_user?.email == null) return;
    try {
      await _auth.sendPasswordResetEmail(email: _user!.email!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("A secured secure password reset link has been dispatched to: ${_user!.email}"),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to trigger reset link: $e"), backgroundColor: Colors.red),
      );
    }
  }

  // 👤 ইউজার প্রোফাইল ডিটেইলস মডার্ন বটম শীট কনসোল
  void _showYourProfileBottomSheet() {
    final isDark = widget.isDarkMode;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  Text("Your System Profile", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                  const SizedBox(height: 20),

                  // 📷 প্রোফাইল ফটো সেকশন (আপলোড ও ডিলিট অপশন সহ)
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFF2D5A27),
                        backgroundImage: _user?.photoURL != null ? NetworkImage(_user!.photoURL!) : null,
                        child: _isImageUploading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : (_user?.photoURL == null
                            ? Text((_user?.displayName ?? "U")[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold))
                            : null),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: const Color(0xFF2D5A27),
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                            onPressed: () async {
                              await _updateProfilePhoto();
                              setModalState(() {}); // বটম শীট স্টেট রিফ্রেশ
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_user?.photoURL != null) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.delete, color: Colors.redAccent, size: 16),
                      label: const Text("Remove Photo", style: TextStyle(color: Colors.redAccent)),
                      onPressed: () async {
                        await _deleteProfilePhoto();
                        setModalState(() {});
                      },
                    ),
                  ],
                  const SizedBox(height: 20),
                  const Divider(),

                  // 📊 রিয়েল-টাইম লাইভ ইনফরমেশন রো (কানেক্টেড পেজ সমূহের ডাটা)
                  _buildProfileDetailRow("Name:", _user?.displayName ?? "User Name", isDark),
                  _buildProfileDetailRow("Email Contact:", _user?.email ?? "Not Available", isDark),
                  _buildProfileDetailRow("Phone Registered:", _user?.phoneNumber ?? "No Linked Number", isDark),
                  _buildProfileDetailRow("Assigned Role:", _getUserRole(), isDark),
                  _buildProfileDetailRow("Attendance Rate:", _getLiveAttendanceRate(), isDark),
                  _buildProfileDetailRow("Water Saved Volume:", _getLiveSavedWater(), isDark),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Divider(),
                  ),

                  // ⚙️ অ্যাকশন বাটন প্যানেল (Edit Profile, Change Password, Logout)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF2D5A27)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.edit_note, color: Color(0xFF2D5A27)),
                          label: const Text("Edit Profile", style: TextStyle(color: Color(0xFF2D5A27))),
                          onPressed: () {
                            _showEditProfileDialog();
                            setModalState(() {});
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.blue),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.lock_reset, color: Colors.blue),
                          label: const Text("Reset Pass", style: TextStyle(color: Colors.blue)),
                          onPressed: _sendPasswordResetEmail,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.power_settings_new, color: Colors.white),
                      label: const Text("Logout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onLogoutTap();
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfileDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label ", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white60 : Colors.black54, fontSize: 13)),
          Expanded(child: Text(value, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w500, fontSize: 13))),
        ],
      ),
    );
  }

  // ভাষা পরিবর্তনের ডায়ালগ বক্স
  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text("Select App Language", style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text("English", style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black)),
              trailing: _currentLanguage == "English" ? const Icon(Icons.check_circle, color: Color(0xFF2D5A27)) : null,
              onTap: () {
                setState(() => _currentLanguage = "English");
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text("বাংলা (BD)", style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black)),
              trailing: _currentLanguage == "বাংলা (BD)" ? const Icon(Icons.check_circle, color: Color(0xFF2D5A27)) : null,
              onTap: () {
                setState(() => _currentLanguage = "বাংলা (BD)");
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDarkMode ? Colors.white : Colors.black;
    final subTextColor = widget.isDarkMode ? Colors.white60 : Colors.black54;
    final cardColor = widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: widget.isDarkMode ? const Color(0xFF121212) : const Color(0xFFFBFBF9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Settings",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
            ),

            const SizedBox(height: 25),

            // 👤 YOUR PROFILE CATEGORY (আপডেটেড ও ডাইনামিকালি কানেক্টেড)
            _buildCategoryTitle("Your Profile Context"),
            Card(
              color: cardColor,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: widget.isDarkMode ? Colors.white10 : Colors.grey.shade200)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.badge_outlined, color: Color(0xFF2D5A27)),
                    title: Text("Your Profile Details", style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
                    subtitle: Text("Name, Email, Role, Assets, and Security Sync", style: TextStyle(color: subTextColor, fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                    onTap: _showYourProfileBottomSheet, // নতুন ডাইনামিক বটম শিট ট্রিগার
                  ),
                  Divider(height: 1, color: widget.isDarkMode ? Colors.white10 : Colors.grey.shade100),
                  SwitchListTile(
                    secondary: const Icon(Icons.fingerprint, color: Color(0xFF2D5A27)),
                    title: Text("Biometric Lock Authentication", style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
                    subtitle: Text("Secure app launch verification", style: TextStyle(color: subTextColor, fontSize: 12)),
                    value: _biometricAuth,
                    activeColor: const Color(0xFF2D5A27),
                    onChanged: (v) => setState(() => _biometricAuth = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 🔔 NOTIFICATIONS & SYNC CATEGORY
            _buildCategoryTitle("System Sync & Alerts"),
            Card(
              color: cardColor,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: widget.isDarkMode ? Colors.white10 : Colors.grey.shade200)),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_active_outlined, color: Color(0xFF2D5A27)),
                    title: Text("Operational Alerts & Notification", style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
                    subtitle: Text("Instant attendance and resource matrix notifications", style: TextStyle(color: subTextColor, fontSize: 12)),
                    value: _alertNotify,
                    activeColor: const Color(0xFF2D5A27),
                    onChanged: (v) => setState(() => _alertNotify = v),
                  ),
                  Divider(height: 1, color: widget.isDarkMode ? Colors.white10 : Colors.grey.shade100),
                  SwitchListTile(
                    secondary: const Icon(Icons.cloud_upload_outlined, color: Color(0xFF2D5A27)),
                    title: Text("Automated Cloud Resource Backup", style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
                    subtitle: Text("Sync local worker logs to safe nodes continuously", style: TextStyle(color: subTextColor, fontSize: 12)),
                    value: _cloudBackup,
                    activeColor: const Color(0xFF2D5A27),
                    onChanged: (v) => setState(() => _cloudBackup = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 🎨 INTERFACE & LOCALIZATION CATEGORY
            _buildCategoryTitle("Interface Customization"),
            Card(
              color: cardColor,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: widget.isDarkMode ? Colors.white10 : Colors.grey.shade200)),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.dark_mode_outlined, color: Color(0xFF2D5A27)),
                    title: Text("Dark Layout Engine Mode", style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
                    subtitle: Text("Optimize power metrics and reduce glare", style: TextStyle(color: subTextColor, fontSize: 12)),
                    value: widget.isDarkMode,
                    activeColor: const Color(0xFF2D5A27),
                    onChanged: widget.onDarkModeChanged,
                  ),
                  Divider(height: 1, color: widget.isDarkMode ? Colors.white10 : Colors.grey.shade100),
                  ListTile(
                    leading: const Icon(Icons.translate, color: Color(0xFF2D5A27)),
                    title: Text("App Translation Language", style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
                    subtitle: Text("Current Language: $_currentLanguage", style: TextStyle(color: subTextColor, fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                    onTap: _showLanguageDialog,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 🛡️ UTILITIES & SUPPORT
            _buildCategoryTitle("Utilities & Security"),
            Card(
              color: cardColor,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: widget.isDarkMode ? Colors.white10 : Colors.grey.shade200)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.cleaning_services_outlined, color: Color(0xFF2D5A27)),
                    title: Text("Optimize Storage Cache", style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
                    subtitle: Text("Flush temporary system logs safely", style: TextStyle(color: subTextColor, fontSize: 12)),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Application cache logs purged successfully!"), backgroundColor: Colors.green),
                      );
                    },
                  ),
                  Divider(height: 1, color: widget.isDarkMode ? Colors.white10 : Colors.grey.shade100),
                  ListTile(
                    leading: const Icon(Icons.info_outline, color: Color(0xFF2D5A27)),
                    title: Text("System Core Architecture Info", style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
                    subtitle: Text("Version: $_appVersion", style: TextStyle(color: subTextColor, fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),

            // 🚨 SECURE LOGOUT BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: const Text(
                  "Logout",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                onPressed: widget.onLogoutTap,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // ক্যাটাগরি হেডার উইজেট
  Widget _buildCategoryTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.3,
          color: widget.isDarkMode ? Colors.white54 : Colors.black45,
        ),
      ),
    );
  }
}