import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '/domain/entities/candidate_entity.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedGender;

  // Regex patterns for validation
  final RegExp _aadharPattern = RegExp(r'^\d{12}$');
  final RegExp _emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  final RegExp _phonePattern = RegExp(r'^[6-9]\d{9}$');

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

  Future<String> getLocalIpAddress() async {
    String systemIp = "";
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
          debugPrint('Local IP Address: ${addr.address}');
          systemIp = addr.address;
        }
      }
    }
    return systemIp;
  }

  Future<void> _registerCandidate() async {
    String systemIp = await getLocalIpAddress();
    if (_formKey.currentState!.validate()) {
      final candidate = CandidateEntity(
        aadhar: _aadharController.text,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        dob: _dobController.text,
        gender: _selectedGender!,
        candidateId: '',
        systemIp: systemIp,
      );

      // Dispatch registration event to the Bloc
      context.read<AuthBloc>().add(RegisterCandidateEvent(candidate));
    }
  }

  void _showSuccessDialog(String candidateId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[600]),
                const SizedBox(width: 10),
                const Text('Registration Successful'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('You have been registered successfully.'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.badge, color: Colors.blue),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your Candidate ID',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              candidateId,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, color: Colors.blue),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: candidateId));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Candidate ID copied to clipboard'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Please remember this ID for login.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: const Text('Go to Login'),
              ),
            ],
          ),
    );
  }

  void _resetForm() {
    _aadharController.clear();
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _dobController.clear();
    setState(() {
      _selectedDate = null;
      _selectedGender = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is RegisterFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Registration failed: ${state.error}'),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is RegisterSuccess) {
              _resetForm();
              // Assuming the candidate has an ID property
              _showSuccessDialog(state.candidateDetails.candidateId ?? 'N/A');
            }
          },
          builder: (context, state) {
            return Row(
              children: [
                // Left side - Image and branding
                if (screenSize.width > 600) // Only show on wider screens
                  Expanded(
                    flex: 5,
                    child: Container(
                      color: Colors.blue[800],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.app_shortcut,
                            size: 80,
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
                            'Candidate Registration',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.blue[50],
                            ),
                          ),
                          const SizedBox(height: 40),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.people_alt,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Join Our Assessment Platform',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Register now to access our comprehensive assessment tools and demonstrate your skills.',
                                    style: TextStyle(color: Colors.blue[50]),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const LoginScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Back to Login',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Right side - Registration form
                Expanded(
                  flex: screenSize.width > 600 ? 5 : 5,
                  child: Container(
                    color: Colors.white,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 500),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (screenSize.width <=
                                      600) // Show on small screens
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
                                    'Create Account',
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Fill in your details to register for assessments',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 32),

                                  // Registration form fields
                                  TextFormField(
                                    controller: _aadharController,
                                    decoration: InputDecoration(
                                      labelText: 'Aadhar Number',
                                      hintText: '12-digit Aadhar number',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      prefixIcon: const Icon(Icons.credit_card),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                      helperText:
                                          'Enter only digits, no spaces or hyphens',
                                    ),
                                    keyboardType: TextInputType.number,
                                    maxLength: 12,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your Aadhar number';
                                      }
                                      if (!_aadharPattern.hasMatch(value)) {
                                        return 'Aadhar number must be exactly 12 digits';
                                      }
                                      // You can add Verhoeff algorithm validation here for more robust Aadhar validation
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _nameController,
                                    decoration: InputDecoration(
                                      labelText: 'Full Name',
                                      hintText: 'Enter your full name',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      prefixIcon: const Icon(Icons.person),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your name';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                      hintText: 'Enter your email address',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      prefixIcon: const Icon(Icons.email),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                      helperText: 'Format: example@domain.com',
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      if (!_emailPattern.hasMatch(value)) {
                                        return 'Please enter a valid email address';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _phoneController,
                                    decoration: InputDecoration(
                                      labelText: 'Phone Number',
                                      hintText: '10-digit mobile number',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      prefixIcon: const Icon(Icons.phone),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                      helperText:
                                          'Indian mobile number starting with 6-9',
                                    ),
                                    keyboardType: TextInputType.phone,
                                    maxLength: 10,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your phone number';
                                      }
                                      if (!_phonePattern.hasMatch(value)) {
                                        return 'Please enter a valid 10-digit mobile number starting with 6-9';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  DropdownButtonFormField<String>(
                                    value: _selectedGender,
                                    decoration: InputDecoration(
                                      labelText: 'Gender',
                                      border: OutlineInputBorder(),
                                      prefixIcon: const Icon(
                                        Icons.person_pin_outlined,
                                      ),
                                    ),
                                    items:
                                        ['Male', 'Female', 'Transgender']
                                            .map(
                                              (gender) => DropdownMenuItem(
                                                value: gender,
                                                child: Text(gender),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedGender = value;
                                      });
                                    },
                                    validator:
                                        (value) =>
                                            value == null || value.isEmpty
                                                ? 'Please select gender'
                                                : null,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _dobController,
                                    decoration: InputDecoration(
                                      labelText: 'Date of Birth',
                                      hintText: 'YYYY-MM-DD',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.calendar_today,
                                      ),
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
                                      onPressed:
                                          state is AuthLoading
                                              ? null
                                              : _registerCandidate,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue[700],
                                        foregroundColor: Colors.white,
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child:
                                          state is AuthLoading
                                              ? const SizedBox(
                                                width: 24,
                                                height: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                              : const Text(
                                                'REGISTER',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                    ),
                                  ),

                                  const SizedBox(height: 24),
                                  if (screenSize.width <=
                                      600) // Only show on small screens
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Already registered?',
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) =>
                                                        const LoginScreen(),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            'Login here',
                                            style: TextStyle(
                                              color: Colors.blue[700],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                  const SizedBox(height: 20),
                                  const Divider(),
                                  const SizedBox(height: 16),
                                  Center(
                                    child: Text(
                                      '© ${DateTime.now().year} Screenify. All rights reserved.',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
