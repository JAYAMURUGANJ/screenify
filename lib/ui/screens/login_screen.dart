// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../domain/local/candidate_helper.dart';
import '../../utils/app_route.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _candidateIdController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  final CandidateDatabaseHelper _dbHelper = CandidateDatabaseHelper();
  DateTime? _selectedDate;
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[700]!, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Calendar text color
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final candidate = await _dbHelper.validateLogin(
          _candidateIdController.text,
          _dobController.text,
        );

        if (candidate != null) {
          // Use AppRouter for navigation instead of direct context
          AppRouter.navigateAndReplace(
            AppRouter.assessments,
            arguments: _candidateIdController.text,
          );
        } else {
          // Show error message using the context-safe way
          if (mounted) {
            // Check if widget is still mounted
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid Candidate ID or Date of Birth'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        // Show error with safety check
        if (mounted) {
          // Check if widget is still mounted
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        // Only update state if widget is still mounted
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: Row(
          children: [
            // Left side - Image and branding
            if (screenSize.width > 600) // Only show on wider screens
              Expanded(
                flex: 5,
                child: Container(
                  color: Colors.blue[700],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.app_shortcut,
                        size: 100,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Screenify',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Exam Assessment Platform',
                        style: TextStyle(fontSize: 20, color: Colors.blue[50]),
                      ),
                      const SizedBox(height: 40),
                      Container(
                        width: 300,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.security, color: Colors.white, size: 32),
                            SizedBox(height: 10),
                            Text(
                              'Secure Assessment Environment',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Our platform provides a controlled environment for fair and secure examinations.',
                              style: TextStyle(color: Colors.white70),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Right side - Login form
            Expanded(
              flex: screenSize.width > 600 ? 4 : 5,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Center(
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (screenSize.width <=
                                600) // Show only on small screens
                              Center(
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[700],
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.app_shortcut,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Screenify',
                                      style: TextStyle(
                                        fontSize: 28,
                                        color: Color(0xFF2C3E50),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                  ],
                                ),
                              ),

                            const Text(
                              'Candidate Login',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Enter your credentials to access assessments',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 32),
                            TextFormField(
                              controller: _candidateIdController,
                              decoration: InputDecoration(
                                labelText: 'Candidate ID',
                                hintText: 'Enter your ID',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.badge),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your Candidate ID';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _dobController,
                              decoration: InputDecoration(
                                labelText: 'Date of Birth',
                                hintText: 'YYYY-MM-DD',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.calendar_today),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              readOnly: true,
                              onTap: () => _selectDate(context),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select your date of birth';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[700],
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child:
                                    _isLoading
                                        ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : const Text(
                                          'LOGIN',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'New candidate?',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/register',
                                    );
                                  },
                                  child: Text(
                                    'Register here',
                                    style: TextStyle(
                                      color: Colors.blue[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            const Divider(),
                            const SizedBox(height: 20),
                            Center(
                              child: Text(
                                '© ${DateTime.now().year} Screenify. All rights reserved.',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
