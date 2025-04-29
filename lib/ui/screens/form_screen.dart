import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class FormFillingAssessment extends StatefulWidget {
  const FormFillingAssessment({super.key});

  @override
  _FormFillingAssessmentState createState() => _FormFillingAssessmentState();
}

class _FormFillingAssessmentState extends State<FormFillingAssessment> {
  final _formKey = GlobalKey<FormState>();
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

  File? _image;
  final picker = ImagePicker();

  Map<String, dynamic> formData = {};

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Income Tax Dept. Co-operative Society'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey.shade200,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 8,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with Background
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          //  color: Colors.blue.shade50,
                          border: Border.all(color: Colors.blue.shade800),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Logo and Title Row - Centered as a unit
                            Center(
                              child: Row(
                                mainAxisSize:
                                    MainAxisSize
                                        .min, // Important for centering the row content
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Logo
                                  SizedBox(
                                    width: 160,
                                    height: 160,
                                    child: Image.asset(
                                      'assets/images/logo.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Organization details
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: const [
                                      Text(
                                        'The Income Tax Department Co-operative Society Limited',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        '(REGD.No. MSCS/CR-11/90)',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '121, MAHATHMA GANDHI SALAI, CHENNAI - 600 034.',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Application Title
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 24,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade700,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.shade200,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
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

                      const SizedBox(height: 24),

                      // To Address Section
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.shade200,
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'To',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        'The President / Chief Executive',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        'The Income Tax Dept. Co-operative Society Ltd.,',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        'Chennai - 600 034',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Request Text Section
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.shade200,
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Sir,',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        'I request you to kindly admit me as a Regular Member.',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),

                          // Photo Upload Section - Enhanced
                          Container(
                            width: 200,
                            height: 250,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.shade400,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey.shade50,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade300,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child:
                                _image == null
                                    ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.photo_camera,
                                            size: 40,
                                            color: Colors.blue.shade700,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Passport Size Photo',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 14),
                                        ElevatedButton.icon(
                                          onPressed: getImage,
                                          icon: const Icon(
                                            Icons.upload_file,
                                            size: 18,
                                          ),
                                          label: const Text('Upload'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.blue.shade700,
                                            foregroundColor: Colors.white,
                                            elevation: 2,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                    : Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            7,
                                          ),
                                          child: Image.file(
                                            _image!,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          right: 6,
                                          top: 6,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(
                                                0.6,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: IconButton(
                                              iconSize: 20,
                                              padding: const EdgeInsets.all(4),
                                              constraints:
                                                  const BoxConstraints(),
                                              icon: const Icon(
                                                Icons.edit,
                                                color: Colors.white,
                                              ),
                                              onPressed: getImage,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Form Fields in Table Format - Styled like a paper form
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          children: [
                            // 1. NAME
                            _buildTableRow(
                              '1. NAME\n(IN BLOCK LETTERS)',
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
                                  hintText: 'Enter your full name',
                                  fillColor: Colors.white,
                                  filled: true,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                              ),
                              hasBorder: true,
                            ),

                            // 2. Sex
                            _buildTableRow(
                              '2. Sex',
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
                              '3. Marital Status',
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
                                    _maritalOptions.map((String status) {
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
                              "4. Father's / Husband's Name",
                              TextFormField(
                                controller: _fatherHusbandNameController,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 10,
                                  ),
                                  hintText: "Enter father's/husband's name",
                                  fillColor: Colors.white,
                                  filled: true,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter father's/husband's name";
                                  }
                                  return null;
                                },
                              ),
                              hasBorder: true,
                            ),

                            // 5. Date Details
                            _buildTableRow(
                              '5. (a) Date of Birth\n\n    (b) Date of Appointment\n\n    (c) Govt. Service\n\n    (d) Income Tax Dept.\n\n    (e) Date of Retirement',
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Date of Birth
                                  _buildDateField(
                                    controller: _dobController,
                                    hintText: 'Select Date of Birth',
                                    onTap: () async {
                                      final DateTime?
                                      picked = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now().subtract(
                                          const Duration(days: 365 * 30),
                                        ),
                                        firstDate: DateTime(1940),
                                        lastDate: DateTime.now(),
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          _dobController.text = DateFormat(
                                            'dd/MM/yyyy',
                                          ).format(picked);
                                        });
                                      }
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Required';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 10),

                                  // Date of Appointment
                                  _buildDateField(
                                    controller: _appointmentDateController,
                                    hintText: 'Select Date of Appointment',
                                    onTap: () async {
                                      final DateTime? picked =
                                          await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now()
                                                .subtract(
                                                  const Duration(days: 365),
                                                ),
                                            firstDate: DateTime(1960),
                                            lastDate: DateTime.now(),
                                          );
                                      if (picked != null) {
                                        setState(() {
                                          _appointmentDateController
                                              .text = DateFormat(
                                            'dd/MM/yyyy',
                                          ).format(picked);
                                        });
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 10),

                                  // Govt. Service
                                  TextFormField(
                                    controller: _govtServiceController,
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 10,
                                      ),
                                      hintText:
                                          'Enter details of Govt. Service',
                                      fillColor: Colors.white,
                                      filled: true,
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Income Tax Dept
                                  TextFormField(
                                    controller: _incomeTaxDeptController,
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 10,
                                      ),
                                      hintText:
                                          'Enter Income Tax Dept. details',
                                      fillColor: Colors.white,
                                      filled: true,
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Date of Retirement
                                  _buildDateField(
                                    controller: _retirementDateController,
                                    hintText: 'Select Date of Retirement',
                                    onTap: () async {
                                      final DateTime? picked =
                                          await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now().add(
                                              const Duration(days: 365),
                                            ),
                                            firstDate: DateTime.now(),
                                            lastDate: DateTime(2050),
                                          );
                                      if (picked != null) {
                                        setState(() {
                                          _retirementDateController
                                              .text = DateFormat(
                                            'dd/MM/yyyy',
                                          ).format(picked);
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                              hasBorder: true,
                              isVerticalAlignTop: true,
                            ),

                            // 6. Office in Which at present Working
                            _buildTableRow(
                              '6. Office in Which at present Working',
                              TextFormField(
                                controller: _officeController,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 10,
                                  ),
                                  hintText: 'Enter current office',
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your current office';
                                  }
                                  return null;
                                },
                              ),
                              hasBorder: true,
                            ),

                            // 7. Designation
                            _buildTableRow(
                              '7. Designation',
                              TextFormField(
                                controller: _designationController,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 10,
                                  ),
                                  hintText: 'Enter your designation',
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your designation';
                                  }
                                  return null;
                                },
                              ),
                              hasBorder: true,
                            ),

                            // 8. Whether Temporary / Under Probation / Permanent
                            _buildTableRow(
                              '8. Whether Temporary / Under Probation / Permanent',
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 10,
                                  ),
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(),
                                ),
                                value: _employmentStatus,
                                items:
                                    _employmentOptions.map((String status) {
                                      return DropdownMenuItem<String>(
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
                              hasBorder: true,
                            ),

                            // 9. Details of Salary
                            _buildTableRow(
                              '9. Details of Salary',
                              Row(
                                children: [
                                  const Text(
                                    'Basic Pay     Rs. ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _basicPayController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: 10,
                                        ),
                                        hintText: 'Enter amount',
                                        fillColor: Colors.white,
                                        filled: true,
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Required';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              hasBorder: false,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Declaration text
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DECLARATION',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'I hereby declare that the information provided above is true to the best of my knowledge and belief. I agree to abide by the rules and regulations of the Society.',
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Date: _______________',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  'Signature: ___________________',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Submit and Save Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: _saveForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'SAVE',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade800,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'SUBMIT',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableRow(
    String label,
    Widget content, {
    bool hasBorder = true,
    bool isVerticalAlignTop = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border:
            hasBorder
                ? Border(bottom: BorderSide(color: Colors.grey.shade400))
                : null,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment:
              isVerticalAlignTop
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
          children: [
            // Label column
            Container(
              width: 150,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border(right: BorderSide(color: Colors.grey.shade400)),
              ),
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            // Content column
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: content,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String hintText,
    required VoidCallback onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 10,
        ),
        hintText: hintText,
        fillColor: Colors.white,
        filled: true,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today, size: 18),
      ),
      readOnly: true,
      onTap: onTap,
      validator: validator,
    );
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _collectFormData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Form saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _collectFormData();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmationScreen(formData: formData),
        ),
      );
    }
  }

  void _collectFormData() {
    formData = {
      'name': _nameController.text,
      'gender': _selectedGender,
      'maritalStatus': _maritalStatus,
      'fatherHusbandName': _fatherHusbandNameController.text,
      'dateOfBirth': _dobController.text,
      'dateOfAppointment': _appointmentDateController.text,
      'govtService': _govtServiceController.text,
      'incomeTaxDept': _incomeTaxDeptController.text,
      'dateOfRetirement': _retirementDateController.text,
      'currentOffice': _officeController.text,
      'designation': _designationController.text,
      'employmentStatus': _employmentStatus,
      'basicPay': _basicPayController.text,
      'submissionDate': DateFormat('dd/MM/yyyy').format(DateTime.now()),
    };
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

class ConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> formData;

  const ConfirmationScreen({super.key, required this.formData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Submitted'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey.shade200,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Application Submitted Successfully!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Submission Date: ${formData['submissionDate']}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Reference Number: ITD-${DateTime.now().millisecondsSinceEpoch.toString().substring(5, 13)}',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Your membership application has been submitted for review. Please keep this confirmation for your records.',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Application Details:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow('Name', formData['name']),
                          _buildDivider(),
                          _buildInfoRow('Gender', formData['gender']),
                          _buildDivider(),
                          _buildInfoRow(
                            'Marital Status',
                            formData['maritalStatus'],
                          ),
                          _buildDivider(),
                          _buildInfoRow(
                            'Father\'s/Husband\'s Name',
                            formData['fatherHusbandName'],
                          ),
                          _buildDivider(),
                          _buildInfoRow(
                            'Date of Birth',
                            formData['dateOfBirth'],
                          ),
                          _buildDivider(),
                          _buildInfoRow(
                            'Date of Appointment',
                            formData['dateOfAppointment'],
                          ),
                          _buildDivider(),
                          _buildInfoRow(
                            'Government Service',
                            formData['govtService'],
                          ),
                          _buildDivider(),
                          _buildInfoRow(
                            'Income Tax Department',
                            formData['incomeTaxDept'],
                          ),
                          _buildDivider(),
                          _buildInfoRow(
                            'Date of Retirement',
                            formData['dateOfRetirement'],
                          ),
                          _buildDivider(),
                          _buildInfoRow(
                            'Current Office',
                            formData['currentOffice'],
                          ),
                          _buildDivider(),
                          _buildInfoRow('Designation', formData['designation']),
                          _buildDivider(),
                          _buildInfoRow(
                            'Employment Status',
                            formData['employmentStatus'],
                          ),
                          _buildDivider(),
                          _buildInfoRow(
                            'Basic Pay',
                            'Rs. ${formData['basicPay']}',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        // Handle print functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Printing application...'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.print),
                      label: const Text('PRINT'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        side: BorderSide(color: Colors.blue.shade700),
                        foregroundColor: Colors.blue.shade700,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('RETURN TO FORM'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade800,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.grey.shade300, height: 1);
  }
}
