import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenify/domain/entities/questions_entity.dart';
import 'package:screenshot/screenshot.dart';

import '../../../core/route/app_route.dart';
import '../../../core/utils/extension.dart';
import '../../../core/widgets/candidate_profile.dart';
import '../../../core/widgets/global_timer.dart';
import '../../dashboard/bloc/assessment_bloc.dart';
import '../bloc/form_assessment_bloc.dart';
import '../bloc/form_assessment_state.dart';

class FormFillingAssessmentScreen extends StatefulWidget {
  final String candidateId;
  final AssessmentEntity formFillingData;

  const FormFillingAssessmentScreen({
    super.key,
    required this.candidateId,
    required this.formFillingData,
  });

  @override
  State<FormFillingAssessmentScreen> createState() =>
      _FormFillingAssessmentScreenState();
}

class _FormFillingAssessmentScreenState
    extends State<FormFillingAssessmentScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _fatherHusbandNameController =
      TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _apeController = TextEditingController();
  final TextEditingController _govtServiceController = TextEditingController();
  final TextEditingController _incomeTaxDeptController =
      TextEditingController();
  final TextEditingController _retirementDateController =
      TextEditingController();
  final TextEditingController _officeController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _basicPayController = TextEditingController();

  final List<String> _employmentOptions = [
    'Permanent',
    'Temporary',
    'Contract',
    'Probation',
    'Retired',
  ];

  String _employmentStatus = 'Permanent';
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => FormFillingAssessmentBloc(
            assessmentBloc: BlocProvider.of<AssessmentBloc>(context),
            candidateId: widget.candidateId,
            formFillingData: widget.formFillingData,
          ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child:
            BlocConsumer<FormFillingAssessmentBloc, FormFillingAssessmentState>(
              listener: (context, state) {
                // Listen for state changes that require UI feedback
                if (state.isSubmitting) {
                  setState(() {
                    _isSubmitting = true;
                  });
                }

                if (state.isCompleted) {
                  Navigator.pop(
                    context,
                    true,
                  ); // Return to assessment list with result
                }

                if (state.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error!),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                // Connect controllers to bloc on first build
                _connectControllersToBloc(context);

                return Scaffold(
                  appBar: assessmentAppBar(context),
                  body: Screenshot(
                    controller: ScreenshotController(),
                    child: Container(
                      color: Colors.grey[50],
                      child: buildWideLayout(context, state),
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }

  void _connectControllersToBloc(BuildContext context) {
    final bloc = BlocProvider.of<FormFillingAssessmentBloc>(context);

    // Only set controllers if they're empty (first build)
    if (_nameController.text.isEmpty) {
      bloc.nameController = _nameController;
      bloc.fatherHusbandNameController = _fatherHusbandNameController;
      bloc.dobController = _dobController;
      bloc.appointmentDateController = _apeController;
      bloc.govtServiceController = _govtServiceController;
      bloc.incomeTaxDeptController = _incomeTaxDeptController;
      bloc.retirementDateController = _retirementDateController;
      bloc.officeController = _officeController;
      bloc.designationController = _designationController;
      bloc.basicPayController = _basicPayController;
    }
  }

  AppBar assessmentAppBar(BuildContext context) {
    final MaterialColor blueColor = Colors.blue;

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
            _showExitConfirmation(context);
          },
        ),
      ],
    );
  }

  Widget buildWideLayout(
    BuildContext context,
    FormFillingAssessmentState state,
  ) {
    final bloc = BlocProvider.of<FormFillingAssessmentBloc>(context);
    final MaterialColor blueColor = Colors.blue;

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
                      getIconFromString(widget.formFillingData.icon),
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.title,
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
                      state.description,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.instructions,
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
                              // Replace with actual hints when available
                              widget.formFillingData.hints != null &&
                                      widget.formFillingData.hints!.isNotEmpty
                                  ? widget.formFillingData.hints![index %
                                      widget.formFillingData.hints!.length]
                                  : "Fill out the form carefully",
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
                  itemCount: widget.formFillingData.hints?.length ?? 1,
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
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.rectangle,
                                ),
                                child: Image.asset(
                                  'assets/images/company_logo.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.business,
                                      size: 60,
                                      color: blueColor[700],
                                    );
                                  },
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
                  Expanded(
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
                                    buildTableRow(
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
                                    buildTableRow(
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
                                        value: bloc.selectedGender,
                                        items:
                                            [
                                              'Male',
                                              'Female',
                                              'Transgender',
                                            ].map((String gender) {
                                              return DropdownMenuItem<String>(
                                                value: gender,
                                                child: Text(gender),
                                              );
                                            }).toList(),
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            bloc.updateGender(newValue);
                                          }
                                        },
                                      ),
                                      hasBorder: true,
                                    ),

                                    // 3. Marital Status
                                    buildTableRow(
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
                                        value: bloc.maritalStatus,
                                        items:
                                            ['Yes', 'No'].map((String status) {
                                              return DropdownMenuItem<String>(
                                                value: status,
                                                child: Text(status),
                                              );
                                            }).toList(),
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            bloc.updateMaritalStatus(newValue);
                                          }
                                        },
                                      ),
                                      hasBorder: true,
                                    ),

                                    // 4. Father's / Husband's Name
                                    buildTableRow(
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
                                    buildTableRow(
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
                                            controller: _apeController,
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
                                    buildTableRow(
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
                                                  bloc.updateEmploymentStatus(
                                                    newValue,
                                                  );
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
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                            ],
                                          ),
                                        ],
                                      ),
                                      hasBorder: true,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Submit Button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton.icon(
                                  onPressed:
                                      _isSubmitting
                                          ? resetTest
                                          : () => handleSubmit(context),
                                  icon:
                                      _isSubmitting
                                          ? const Icon(Icons.refresh)
                                          : const Icon(Icons.check_circle),
                                  label: Text(
                                    _isSubmitting ? 'RESET ' : 'SUBMIT ',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        _isSubmitting
                                            ? Colors.grey[700]
                                            : blueColor[700],
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
                              Center(
                                child: Text(
                                  '© ${DateTime.now().year} Screenify. All rights reserved.',
                                  textAlign: TextAlign.center,
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
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to build a table row
  Widget buildTableRow(String label, Widget field, {required bool hasBorder}) {
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
                  color: Colors.blue[800],
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

  void handleSubmit(BuildContext context) {
    final bloc = BlocProvider.of<FormFillingAssessmentBloc>(context);

    // Calculate score and submit assessment
    final results = bloc.calculateScore();

    // Print results to terminal as a single string (for debugging)
    debugPrint("FormFillingResponse: -> $results");
    _showSubmissionConfirmation(context, results);
  }

  void _showSubmissionConfirmation(
    BuildContext context,
    Map<String, dynamic> results,
  ) {
    // Store the bloc reference from the current context
    final bloc = BlocProvider.of<FormFillingAssessmentBloc>(context);

    AppRouter.showGlobalDialog(
      title: 'Submit Assessment?',
      message:
          'Are you sure you want to submit this assessment? You cannot make changes after submission.',
      buttonText: 'SUBMIT',
      secondaryButtonText: 'CANCEL',
      primaryCallback: () {
        // This will run when the user clicks SUBMIT
        bloc.submitAssessment(results);
      },
      secondaryCallback: () {
        // This will run when the user clicks CANCEL
        // No action needed for cancel
      },
    );
  }

  void _showExitConfirmation(BuildContext context) {
    AppRouter.showGlobalDialog(
      title: 'Exit Assessment?',
      message:
          'You can continue this assessment later. Are you sure you want to exit?',
      buttonText: 'EXIT',
      secondaryButtonText: 'CANCEL',
      primaryCallback: () {
        // This will run when the user clicks EXIT
        Navigator.pop(context, true); // Return to assessment list
      },
      secondaryCallback: () {
        // This will run when the user clicks CANCEL
        // No additional action needed as the dialog is already closed
      },
    );
  }

  void resetTest() {
    final bloc = BlocProvider.of<FormFillingAssessmentBloc>(context);
    bloc.resetForm();
  }
}
