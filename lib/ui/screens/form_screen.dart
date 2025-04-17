import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class MembershipForm extends StatefulWidget {
  const MembershipForm({super.key});

  @override
  _MembershipFormState createState() => _MembershipFormState();
}

class _MembershipFormState extends State<MembershipForm> {
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        height: 150, // Adjust height as needed
                        fit: BoxFit.contain,
                      ),
                      Column(
                        children: [
                          const Text(
                            'The Income Tax Department Co-operative Society Limited',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '(REGD.No. MSCS/CR-11/90)',
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '121, MAHATHMA GANDHI SALAI, CHENNAI - 600 034.',
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Application for Admission as Regular Membership\n(Under Rule 19 of the M.S.C.S. Act, 2002)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // To Address Section
                const Text('To', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                const Text(
                  'The President / Chief Executive',
                  style: TextStyle(fontSize: 16),
                ),
                const Text(
                  'The Income Tax Dept. Co-operative Society Ltd.,',
                  style: TextStyle(fontSize: 16),
                ),
                const Text('Chennai - 600 034', style: TextStyle(fontSize: 16)),

                const SizedBox(height: 16),

                // Photo Upload Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 150,
                      height: 180,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                      ),
                      child:
                          _image == null
                              ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Photo',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: getImage,
                                    child: const Text('Upload'),
                                  ),
                                ],
                              )
                              : Image.file(_image!, fit: BoxFit.cover),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Request Text
                const Text('Sir,', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                const Text(
                  'I request you to kindly admit me as a Regular Member.',
                  style: TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 20),

                // Form Fields in Table Format
                Table(
                  border: TableBorder.all(color: Colors.grey.shade300),
                  columnWidths: const {
                    0: FlexColumnWidth(1.5),
                    1: FlexColumnWidth(2.5),
                  },
                  children: [
                    // 1. NAME
                    TableRow(
                      children: [
                        const TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              '1. NAME\n(IN BLOCK LETTERS)',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: _nameController,
                              textCapitalization: TextCapitalization.characters,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Enter your full name',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    // 2. Sex
                    TableRow(
                      children: [
                        const TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              '2. Sex',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                border: InputBorder.none,
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
                          ),
                        ),
                      ],
                    ),

                    // 3. Marital Status
                    TableRow(
                      children: [
                        const TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              '3. Marital Status',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                border: InputBorder.none,
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
                          ),
                        ),
                      ],
                    ),

                    // 4. Father's / Husband's Name
                    TableRow(
                      children: [
                        const TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "4. Father's / Husband's Name",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: _fatherHusbandNameController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "Enter father's/husband's name",
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter father's/husband's name";
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    // 5. Date Details
                    TableRow(
                      children: [
                        const TableCell(
                          verticalAlignment: TableCellVerticalAlignment.top,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              '5. (a) Date of Birth\n\n    (b) Date of Appointment\n\n    (c) Govt. Service\n\n    (d) Income Tax Dept.\n\n    (e) Date of Retirement',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                // Date of Birth
                                TextFormField(
                                  controller: _dobController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'DD/MM/YYYY',
                                  ),
                                  readOnly: true,
                                  onTap: () async {
                                    final DateTime? picked =
                                        await showDatePicker(
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
                                      return 'Please enter your date of birth';
                                    }
                                    return null;
                                  },
                                ),

                                // Date of Appointment
                                TextFormField(
                                  controller: _appointmentDateController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'DD/MM/YYYY',
                                  ),
                                  readOnly: true,
                                  onTap: () async {
                                    final DateTime? picked =
                                        await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now().subtract(
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

                                // Govt. Service
                                TextFormField(
                                  controller: _govtServiceController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Enter details',
                                  ),
                                ),

                                // Income Tax Dept
                                TextFormField(
                                  controller: _incomeTaxDeptController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Enter details',
                                  ),
                                ),

                                // Date of Retirement
                                TextFormField(
                                  controller: _retirementDateController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'DD/MM/YYYY',
                                  ),
                                  readOnly: true,
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
                          ),
                        ),
                      ],
                    ),

                    // 6. Office in Which at present Working
                    TableRow(
                      children: [
                        const TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              '6. Office in Which at present Working',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: _officeController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Enter current office',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your current office';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    // 7. Designation
                    TableRow(
                      children: [
                        const TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              '7. Designation',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: _designationController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Enter your designation',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your designation';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    // 8. Whether Temporary / Under Probation / Permanent
                    TableRow(
                      children: [
                        const TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              '8. Whether Temporary / Under Probation / Permanent',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                border: InputBorder.none,
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
                          ),
                        ),
                      ],
                    ),

                    // 9. Details of Salary
                    TableRow(
                      children: [
                        const TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              '9. Details of Salary',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                const Text('Basic Pay     Rs. '),
                                Expanded(
                                  child: TextFormField(
                                    controller: _basicPayController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Enter amount',
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter basic pay';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Submit and Save Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _saveForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('SAVE', style: TextStyle(fontSize: 16)),
                    ),
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Application Submitted Successfully!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Submission Date: ${formData['submissionDate']}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Application Details:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Name', formData['name']),
                        _buildInfoRow('Gender', formData['gender']),
                        _buildInfoRow(
                          'Marital Status',
                          formData['maritalStatus'],
                        ),
                        _buildInfoRow(
                          'Father\'s/Husband\'s Name',
                          formData['fatherHusbandName'],
                        ),
                        _buildInfoRow('Date of Birth', formData['dateOfBirth']),
                        _buildInfoRow(
                          'Date of Appointment',
                          formData['dateOfAppointment'],
                        ),
                        _buildInfoRow(
                          'Government Service',
                          formData['govtService'],
                        ),
                        _buildInfoRow(
                          'Income Tax Department',
                          formData['incomeTaxDept'],
                        ),
                        _buildInfoRow(
                          'Date of Retirement',
                          formData['dateOfRetirement'],
                        ),
                        _buildInfoRow(
                          'Current Office',
                          formData['currentOffice'],
                        ),
                        _buildInfoRow('Designation', formData['designation']),
                        _buildInfoRow(
                          'Employment Status',
                          formData['employmentStatus'],
                        ),
                        _buildInfoRow(
                          'Basic Pay',
                          'Rs. ${formData['basicPay']}',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Return to Form',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
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
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
