import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot/screenshot.dart';

import '../../domain/local/assessment_helper.dart';
import '../../domain/model/assessment_question.dart';
import '../../ui/widgets/candidate_profile.dart';
import '../../ui/widgets/global_timer.dart';
import '../../utils/extension.dart';

class FormFillingAssessmentScreen extends StatefulWidget {
  final String candidateId;
  final Assessment formFillingData;

  const FormFillingAssessmentScreen({
    super.key,
    required this.candidateId,
    required this.formFillingData,
  });

  @override
  _FormFillingAssessmentScreenState createState() =>
      _FormFillingAssessmentScreenState();
}

class _FormFillingAssessmentScreenState
    extends State<FormFillingAssessmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final ScreenshotController _screenshotController = ScreenshotController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _fatherHusbandNameController =
      TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _appointmentDateController =
      TextEditingController();
  final TextEditingController _govtServiceController = TextEditingController();
  final TextEditingController _incomeTaxDeptController =
      TextEditingController();
  final TextEditingController _retirementDateController =
      TextEditingController();
  final TextEditingController _officeController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _basicPayController = TextEditingController();

  String _selectedGender = 'Male';
  final List<String> _genderOptions = ['Male', 'Female', 'Transgender'];

  String _maritalStatus = 'Yes';
  final List<String> _maritalOptions = ['Yes', 'No'];

  String _employmentStatus = 'Permanent';
  final List<String> _employmentOptions = [
    'Temporary',
    'Under Probation',
    'Permanent',
  ];

  final AssessmentDatabaseHelper _dbHelper = AssessmentDatabaseHelper();

  bool _isSubmitting = false;

  // Define blue color to use throughout the app
  final Color primaryBlue = Colors.blue;
  final MaterialColor blueColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    _loadAssessmentStatus();
  }

  Future<void> _loadAssessmentStatus() async {
    try {
      final status = await _dbHelper.getAssessmentStatus(
        widget.candidateId,
        widget.formFillingData.type,
      );

      // If assessment is not started yet, update to pending
      if (status == AssessmentDatabaseHelper.STATUS_NOT_OPENED) {
        await _dbHelper.updateAssessmentStatus(
          widget.candidateId,
          widget.formFillingData.type,
          AssessmentDatabaseHelper.STATUS_PENDING,
        );
      }
    } catch (e) {
      debugPrint('Error loading assessment status: $e');
    }
  }

  Map<String, dynamic> _calculateScore() {
    var employmentInfo = widget.formFillingData.employmentInfo;
    if (_formKey.currentState!.validate()) {
      List<String> mismatchFields = [];
      int totalFields = 8;
      int correctCount = 0;

      if (_nameController.text.trim().toUpperCase() ==
          employmentInfo!.name!.toUpperCase()) {
        correctCount++;
      } else {
        mismatchFields.add('Name');
      }

      if (_fatherHusbandNameController.text.trim().toUpperCase() ==
          employmentInfo.fatherName!.toUpperCase()) {
        correctCount++;
      } else {
        mismatchFields.add('Father\'s/Husband\'s Name');
      }

      if (_dobController.text.trim() == employmentInfo.dateOfBirth!.trim()) {
        correctCount++;
      } else {
        mismatchFields.add('Date of Birth');
      }

      if (_appointmentDateController.text.trim() ==
          employmentInfo.dateOfAppointment!.trim()) {
        correctCount++;
      } else {
        mismatchFields.add('Date of Appointment');
      }

      if (_retirementDateController.text.trim() ==
          employmentInfo.dateOfRetirement!.trim()) {
        correctCount++;
      } else {
        mismatchFields.add('Date of Retirement');
      }

      if (_officeController.text.trim().toUpperCase() ==
          employmentInfo.currentOffice!.toUpperCase()) {
        correctCount++;
      } else {
        mismatchFields.add('Current Office');
      }

      if (_designationController.text.trim().toUpperCase() ==
          employmentInfo.designation!.toUpperCase()) {
        correctCount++;
      } else {
        mismatchFields.add('Designation');
      }

      if (_basicPayController.text.trim() == employmentInfo.basicPay!.trim()) {
        correctCount++;
      } else {
        mismatchFields.add('Basic Pay');
      }

      double score = (correctCount / totalFields) * 100;

      setState(() {
        _isSubmitting = true;
      });

      Map<String, dynamic> assessmentResult = {
        'submissionDate': DateTime.now().toIso8601String(),
        'formDetails': {
          'name': _nameController.text,
          'gender': _selectedGender,
          'maritalStatus': _maritalStatus,
          'fatherHusbandName': _fatherHusbandNameController.text,
          'dob': _dobController.text,
          'appointmentDate': _appointmentDateController.text,
          'govtService': _govtServiceController.text,
          'incomeTaxDept': _incomeTaxDeptController.text,
          'retirementDate': _retirementDateController.text,
          'office': _officeController.text,
          'designation': _designationController.text,
          'employmentStatus': _employmentStatus,
          'basicPay': _basicPayController.text,
        },
        'validation': {
          'score': score,
          'totalFields': totalFields,
          'correctFields': correctCount,
          'mismatchFields': mismatchFields,
        },
        'status': 'submitted',
      };

      return assessmentResult;
    }
    throw Exception('Form validation failed. Please fill all required fields.');
  }

  Future<void> _handleSubmit() async {
    // Get evaluation results
    final Map<String, dynamic> results = _calculateScore();
    // Print results to terminal as a single string
    debugPrint(results.toString());
    // Show confirmation dialog
    _showSubmissionConfirmation(results);
  }

  Future<void> _saveResults(Map<String, dynamic> results) async {
    try {
      // Update assessment status to completed
      await _dbHelper.updateAssessmentStatus(
        widget.candidateId,
        widget.formFillingData.type,
        AssessmentDatabaseHelper.STATUS_COMPLETED,
      );

      // Save assessment results
      await _dbHelper.saveAssessmentResult(
        widget.candidateId,
        widget.formFillingData.type,
        results,
      );
    } catch (e) {
      debugPrint('Error saving assessment results: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save results to database: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSubmissionConfirmation(Map<String, dynamic> results) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (BuildContext dialogContext) => AlertDialog(
            title: Text(
              'Submit Assessment?',
              style: TextStyle(
                color: blueColor[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Are you sure you want to submit this assessment? You cannot make changes after submission.',
              style: TextStyle(color: Colors.grey[700]),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext); // Close dialog
                  setState(() {
                    _isSubmitting = false; // Allow further editing
                  });
                },
                child: Text(
                  'CANCEL',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              TextButton(
                onPressed: () async {
                  // Save results
                  await _saveResults(results);

                  Navigator.pop(dialogContext); // Close dialog
                  if (mounted) {
                    Navigator.pop(
                      context,
                      true,
                    ); // Return to assessment list with result
                  }
                },
                child: Text(
                  'SUBMIT',
                  style: TextStyle(
                    color: blueColor[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _resetTest() {
    setState(() {
      _isSubmitting = false;
      _nameController.clear();
      _fatherHusbandNameController.clear();
      _dobController.clear();
      _appointmentDateController.clear();
      _govtServiceController.clear();
      _incomeTaxDeptController.clear();
      _retirementDateController.clear();
      _officeController.clear();
      _designationController.clear();
      _basicPayController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        appBar: _assessmentAppBar(),
        body: Screenshot(
          controller: _screenshotController,
          child: Container(color: Colors.grey[50], child: _buildWideLayout()),
        ),
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder:
          (BuildContext dialogContext) => AlertDialog(
            title: Text(
              'Exit Form?',
              style: TextStyle(color: blueColor, fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'You can continue this form later. Are you sure you want to exit?',
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  'CANCEL',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.pop(context);
                },
                child: Text(
                  'EXIT',
                  style: TextStyle(
                    color: blueColor[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  AppBar _assessmentAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: blueColor[700],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.app_shortcut,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Screenify',
            style: GoogleFonts.poppins(
              color: blueColor[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        const GlobalTimerWidget(),
        const SizedBox(width: 5),
        CandidateProfile(
          name: widget.candidateId,
          candidateId: widget.candidateId,
        ),
        const SizedBox(width: 5),
        IconButton(
          icon: Icon(Icons.close, color: Colors.grey[700]),
          onPressed: () {
            _showExitConfirmation();
          },
        ),
      ],
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        // Left sidebar - Branding and instructions
        Container(
          width: 300,
          color: blueColor[700],
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      getIconFromString(
                        widget.formFillingData.icon ?? 'description',
                      ),
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.formFillingData.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Instructions',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 15),
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.formFillingData.description,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.formFillingData.instructions ??
                          'Fill in all required fields marked with *',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                'Hint',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemBuilder: (_, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb,
                            color: Colors.amber[700],
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.formFillingData.hints[index],
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  itemCount: widget.formFillingData.hints.length,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),

        // Main form content area
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Form Header Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Logo and Title
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.rectangle,
                                ),
                                child: Image.asset(
                                  'assets/images/company_logo.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'The Income Tax Department Co-operative Society Limited',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: blueColor[800],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      '(REGD.No. MSCS/CR-11/90)',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      '121, MAHATHMA GANDHI SALAI, CHENNAI - 600 034.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Application Title
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 24,
                            ),
                            decoration: BoxDecoration(
                              color: blueColor[700],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Application for Admission as Regular Membership\n(Under Rule 19 of the M.S.C.S. Act, 2002)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Form Fields Card
                  SizedBox(
                    height: MediaQuery.of(context).size.height - 400,
                    child: SingleChildScrollView(
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.assignment, color: blueColor[700]),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Personal Information',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: blueColor[700],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Column(
                                  children: [
                                    // 1. NAME
                                    _buildTableRow(
                                      '1. NAME *\n(IN BLOCK LETTERS)',
                                      TextFormField(
                                        controller: _nameController,
                                        textCapitalization:
                                            TextCapitalization.characters,
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 10,
                                          ),
                                          fillColor: Colors.white,
                                          filled: true,
                                        ),
                                      ),
                                      hasBorder: true,
                                    ),

                                    // 2. Sex
                                    _buildTableRow(
                                      '2. Sex *',
                                      DropdownButtonFormField<String>(
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 10,
                                          ),
                                          fillColor: Colors.white,
                                          filled: true,
                                        ),
                                        value: _selectedGender,
                                        items:
                                            _genderOptions.map((String gender) {
                                              return DropdownMenuItem<String>(
                                                value: gender,
                                                child: Text(gender),
                                              );
                                            }).toList(),
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            setState(() {
                                              _selectedGender = newValue;
                                            });
                                          }
                                        },
                                      ),
                                      hasBorder: true,
                                    ),

                                    // 3. Marital Status
                                    _buildTableRow(
                                      '3. Marital Status *',
                                      DropdownButtonFormField<String>(
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 10,
                                          ),
                                          fillColor: Colors.white,
                                          filled: true,
                                        ),
                                        value: _maritalStatus,
                                        items:
                                            _maritalOptions.map((
                                              String status,
                                            ) {
                                              return DropdownMenuItem<String>(
                                                value: status,
                                                child: Text(status),
                                              );
                                            }).toList(),
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            setState(() {
                                              _maritalStatus = newValue;
                                            });
                                          }
                                        },
                                      ),
                                      hasBorder: true,
                                    ),

                                    // 4. Father's / Husband's Name
                                    _buildTableRow(
                                      "4. Father's / Husband's Name *",
                                      TextFormField(
                                        controller:
                                            _fatherHusbandNameController,
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 10,
                                          ),
                                          fillColor: Colors.white,
                                          filled: true,
                                        ),
                                      ),
                                      hasBorder: true,
                                    ),

                                    // 5. Date Details
                                    _buildTableRow(
                                      '5. (a) Date of Birth *\n\n    (b) Date of Appointment *\n\n    (c) Govt. Service *\n\n    (d) Income Tax Dept. *\n\n    (e) Date of Retirement *',
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Date of Birth
                                          TextFormField(
                                            controller: _dobController,

                                            decoration: const InputDecoration(
                                              isDense: true,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 10,
                                                  ),
                                              fillColor: Colors.white,
                                              filled: true,
                                            ),
                                          ),
                                          const SizedBox(height: 12),

                                          // Date of Appointment
                                          TextFormField(
                                            controller:
                                                _appointmentDateController,
                                            decoration: const InputDecoration(
                                              isDense: true,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 10,
                                                  ),
                                              fillColor: Colors.white,
                                              filled: true,
                                            ),
                                          ),

                                          const SizedBox(height: 12),

                                          // Govt. Service
                                          TextFormField(
                                            controller: _govtServiceController,
                                            decoration: const InputDecoration(
                                              isDense: true,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 10,
                                                  ),
                                              fillColor: Colors.white,
                                              filled: true,
                                            ),
                                          ),
                                          const SizedBox(height: 12),

                                          // Income Tax Dept
                                          TextFormField(
                                            controller:
                                                _incomeTaxDeptController,
                                            decoration: const InputDecoration(
                                              isDense: true,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 10,
                                                  ),
                                              fillColor: Colors.white,
                                              filled: true,
                                            ),
                                          ),
                                          const SizedBox(height: 12),

                                          // Date of Retirement
                                          TextFormField(
                                            controller:
                                                _retirementDateController,
                                            decoration: const InputDecoration(
                                              isDense: true,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 10,
                                                  ),
                                              fillColor: Colors.white,
                                              filled: true,
                                            ),
                                          ),
                                        ],
                                      ),
                                      hasBorder: true,
                                    ),

                                    // 6. Office & Designation
                                    _buildTableRow(
                                      '6. (a) Office *\n\n    (b) Designation *\n\n    (c) Employment Status *\n\n    (d) Basic Pay *',
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Office
                                          TextFormField(
                                            controller: _officeController,
                                            decoration: const InputDecoration(
                                              isDense: true,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 10,
                                                  ),
                                              fillColor: Colors.white,
                                              filled: true,
                                            ),
                                          ),
                                          const SizedBox(height: 12),

                                          // Designation
                                          TextFormField(
                                            controller: _designationController,
                                            decoration: const InputDecoration(
                                              isDense: true,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 10,
                                                  ),
                                              fillColor: Colors.white,
                                              filled: true,
                                            ),
                                          ),
                                          const SizedBox(height: 12),

                                          // Employment Status
                                          DropdownButtonFormField<String>(
                                            decoration: const InputDecoration(
                                              isDense: true,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 10,
                                                  ),
                                              fillColor: Colors.white,
                                              filled: true,
                                            ),
                                            value: _employmentStatus,
                                            items:
                                                _employmentOptions.map((
                                                  String status,
                                                ) {
                                                  return DropdownMenuItem<
                                                    String
                                                  >(
                                                    value: status,
                                                    child: Text(status),
                                                  );
                                                }).toList(),
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  _employmentStatus = newValue;
                                                });
                                              }
                                            },
                                          ),
                                          const SizedBox(height: 12),

                                          // Basic Pay
                                          TextFormField(
                                            controller: _basicPayController,
                                            decoration: const InputDecoration(
                                              isDense: true,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 10,
                                                  ),
                                              fillColor: Colors.white,
                                              filled: true,
                                              prefixText: '₹ ',
                                            ),
                                          ),
                                        ],
                                      ),
                                      hasBorder: true,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? _resetTest : _handleSubmit,
                      icon: const Icon(Icons.check_circle),
                      label: const Text(
                        'SUBMIT ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blueColor[700],
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Footer
                  Text(
                    '© ${DateTime.now().year} Screenify. All rights reserved.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to build a table row
  Widget _buildTableRow(String label, Widget field, {required bool hasBorder}) {
    return Container(
      decoration: BoxDecoration(
        border:
            hasBorder
                ? Border(bottom: BorderSide(color: Colors.grey.shade400))
                : null,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Label column
            Container(
              width: 230,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border(right: BorderSide(color: Colors.grey.shade400)),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: blueColor[800],
                ),
              ),
            ),
            // Field column
            Expanded(
              child: Padding(padding: const EdgeInsets.all(12), child: field),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fatherHusbandNameController.dispose();
    _dobController.dispose();
    _appointmentDateController.dispose();
    _govtServiceController.dispose();
    _incomeTaxDeptController.dispose();
    _retirementDateController.dispose();
    _officeController.dispose();
    _designationController.dispose();
    _basicPayController.dispose();
    super.dispose();
  }
}
