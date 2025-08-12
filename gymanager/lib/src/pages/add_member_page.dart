import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymanager/src/config/app_colors.dart';
import 'package:gymanager/src/models/trainer_model.dart';
import 'package:gymanager/src/services/api_service.dart';
import 'package:intl/intl.dart';

class AddMemberPage extends StatefulWidget {
  const AddMemberPage({super.key});

  @override
  State<AddMemberPage> createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage> {
  // Form controllers and state variables
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String? _selectedGender;
  DateTime? _selectedDate;
  String? _selectedPlan;
  String? _selectedTrainerId;
  bool _isLoading = false;

  late Future<List<Trainer>> _trainersFuture;

  @override
  void initState() {
    super.initState();
    _trainersFuture = ApiService.getTrainers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  // --- START OF UPDATED DATE PICKER METHOD ---
  // In _AddMemberPageState class...

  Future<void> _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      // Add this builder property
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.surface, // header background color
              onPrimary: AppColors.secondaryText, // header text color
              onSurface: AppColors.primaryText, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.surface, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _selectedDate = pickedDate;
    });
  }
  // --- END OF UPDATED DATE PICKER METHOD ---

  Future<void> _saveMember() async {
    if (_nameController.text.isEmpty ||
        _selectedDate == null ||
        _selectedGender == null ||
        _selectedPlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ApiService.createMember(
        name: _nameController.text,
        gender: _selectedGender!,
        dob: _selectedDate!.toIso8601String(),
        membershipPlan: _selectedPlan!,
        height: _heightController.text,
        weight: _weightController.text,
        trainerId: _selectedTrainerId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Member added successfully!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Member'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.secondaryText,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  style: const TextStyle(color: AppColors.primaryText),
                ),
                const SizedBox(height: 24),
                FutureBuilder<List<Trainer>>(
                  future: _trainersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return const Text("Could not load trainers.");
                    }
                    final trainers = snapshot.data!;
                    return DropdownButtonFormField<String>(
                      value: _selectedTrainerId,
                      decoration: const InputDecoration(
                          labelText: 'Assign Trainer (Optional)'),
                      dropdownColor: AppColors.background,
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('None',
                              style: TextStyle(color: AppColors.primaryText)),
                        ),
                        ...trainers.map((trainer) {
                          return DropdownMenuItem(
                            value: trainer.id,
                            child: Text(trainer.name,
                                style: const TextStyle(
                                    color: AppColors.primaryText)),
                          );
                        }),
                      ],
                      onChanged: (value) =>
                          setState(() => _selectedTrainerId = value),
                      style: const TextStyle(color: AppColors.primaryText),
                    );
                  },
                ),
                const SizedBox(height: 24),
                InkWell(
                  onTap: _presentDatePicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDate == null
                              ? 'Select Date of Birth'
                              : DateFormat.yMd().format(_selectedDate!),
                          style: const TextStyle(
                              color: AppColors.primaryText, fontSize: 16),
                        ),
                        const Icon(Icons.calendar_today,
                            color: AppColors.primaryText),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(labelText: 'Gender'),
                  dropdownColor: AppColors.background,
                  items: const [
                    DropdownMenuItem(
                        value: 'Male',
                        child: Text('Male',
                            style: TextStyle(color: AppColors.primaryText))),
                    DropdownMenuItem(
                        value: 'Female',
                        child: Text('Female',
                            style: TextStyle(color: AppColors.primaryText))),
                  ],
                  onChanged: (value) => setState(() => _selectedGender = value),
                  style: const TextStyle(color: AppColors.primaryText),
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  value: _selectedPlan,
                  decoration:
                      const InputDecoration(labelText: 'Membership Plan'),
                  dropdownColor: AppColors.background,
                  items: const [
                    DropdownMenuItem(
                        value: '1-month',
                        child: Text('1 Month',
                            style: TextStyle(color: AppColors.primaryText))),
                    DropdownMenuItem(
                        value: '3-month',
                        child: Text('3 Months',
                            style: TextStyle(color: AppColors.primaryText))),
                    DropdownMenuItem(
                        value: '6-month',
                        child: Text('6 Months',
                            style: TextStyle(color: AppColors.primaryText))),
                    DropdownMenuItem(
                        value: '12-month',
                        child: Text('1 Year',
                            style: TextStyle(color: AppColors.primaryText))),
                  ],
                  onChanged: (value) => setState(() => _selectedPlan = value),
                  style: const TextStyle(color: AppColors.primaryText),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _heightController,
                  decoration: const InputDecoration(labelText: 'Height (cm)'),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.primaryText),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _weightController,
                  decoration: const InputDecoration(labelText: 'Weight (kg)'),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.primaryText),
                ),
                const SizedBox(height: 40),
                FilledButton(
                  onPressed: _isLoading ? null : _saveMember,
                  child: const Text('Save Member'),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                  child: CircularProgressIndicator(color: AppColors.accent)),
            ),
        ],
      ),
    );
  }
}
