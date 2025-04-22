import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _pathController = TextEditingController();
  static const String officePathKey = 'ms_office_path';

  @override
  void initState() {
    super.initState();
    _loadOfficePath();
  }

  Future<void> _loadOfficePath() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(officePathKey) ?? '';
    setState(() {
      _pathController.text = path;
    });
  }

  Future<void> _saveOfficePath() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(officePathKey, _pathController.text.trim());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("MS Office path saved successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Application Settings")),
      body: Center(
        // Center the entire column
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 600,
            ), // Limit the max width
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center the content vertically
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Center the content horizontally
              children: [
                const Text(
                  "Enter your MS Office installation path:",
                  textAlign: TextAlign.center, // Center the title text
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _pathController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText:
                        'e.g. C:\\Program Files (x86)\\Microsoft Office\\Office12',
                  ),
                  textAlign:
                      TextAlign.center, // Center the text inside the text field
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveOfficePath,
                  child: Text(
                    "Save",
                    style: TextStyle(fontSize: 16, color: Colors.blue[700]),
                  ), // Center the button text
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
