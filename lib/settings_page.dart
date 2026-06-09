import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;
  final VoidCallback onProfileTap;
  final VoidCallback onLogoutTap;

  const SettingsPage({
    super.key,
    required this.isDarkMode,
    required this.onDarkModeChanged,
    required this.onProfileTap,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Settings", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 25),
          Card(
            color: cardColor,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.dark_mode, color: Color(0xFF2D5A27)),
                  title: Text("Dark Mode", style: TextStyle(color: textColor)),
                  trailing: Switch(
                    value: isDarkMode,
                    activeThumbColor: const Color(0xFF2D5A27),
                    onChanged: onDarkModeChanged,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.person_outline, color: Color(0xFF2D5A27)),
                  title: Text("Profile Management", style: TextStyle(color: textColor)),
                  onTap: onProfileTap,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline, color: Color(0xFF2D5A27)),
                  title: Text("About TeaPlus", style: TextStyle(color: textColor)),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: "TeaPlus",
                      applicationVersion: "1.0.0",
                      applicationIcon: const Icon(Icons.eco, color: Color(0xFF2D5A27)),
                      children: [const Text("Smart Solution for Productive Tea Gardens.")],
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text("Logout from TeaPlus", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  onTap: onLogoutTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}